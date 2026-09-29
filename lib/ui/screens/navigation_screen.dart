import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import '../../core/constants/app_colors.dart';
import '../../core/utils/kinematics_math.dart';
import '../../engine/alignment/vehicle_alignment_engine.dart';
import '../../engine/ai_speed/ai_speed_filter.dart';
import '../../engine/fusion/eskf_fusion_engine.dart';
import '../../engine/deficit_handler/gnss_deficit_handler.dart';
import '../../engine/map_matching/map_matching_engine.dart';
import '../../engine/sensors/live_sensor_manager.dart';
import '../widgets/minimal_hud.dart';
import '../widgets/minimal_map.dart';
import '../widgets/telemetry_bottom_sheet.dart';
import '../widgets/zero_touch_banner.dart';

/// Highly Responsive Real-Time Navigation Screen
/// Implements 7-Step Zero-Touch In-Vehicle Flow & 50Hz Live Telemetry Visualizer
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  // Map Controller
  final MapController _mapController = MapController();

  // Core Processing Engines
  final VehicleAlignmentEngine _alignmentEngine = VehicleAlignmentEngine();
  final AiSpeedFilter _aiSpeedFilter = AiSpeedFilter();
  final EskfFusionEngine _eskfEngine = EskfFusionEngine();
  final GnssDeficitHandler _deficitHandler = GnssDeficitHandler();
  final MapMatchingEngine _mapMatchingEngine = MapMatchingEngine();
  final LiveSensorManager _liveSensorManager = LiveSensorManager();

  StreamSubscription<LiveTelemetryData>? _liveSensorSub;

  // Real-time Navigation Output States
  LatLng _anchorPosition = const LatLng(0, 0);
  LatLng _currentDisplayedPosition = const LatLng(0, 0);
  double _currentHeadingDeg = 0.0;
  bool _hasInitialGnssFix = false;
  
  // Real-time 50Hz Changing Raw Sensor Vectors
  vm.Vector3 _rawAccel = vm.Vector3(0, 0, 9.81);
  vm.Vector3 _rawGyro = vm.Vector3.zero();
  vm.Vector3 _rawMag = vm.Vector3.zero();
  double _liveGForce = 1.0;
  double _liveTurnRateDeg = 0.0;
  
  final List<LatLng> _estimatedPath = [];

  @override
  void initState() {
    super.initState();
    _startOriginalLiveSensors();
  }

  @override
  void dispose() {
    _liveSensorSub?.cancel();
    _liveSensorManager.dispose();
    super.dispose();
  }

  Future<void> _startOriginalLiveSensors() async {
    await _liveSensorManager.startSensors();

    double lastTimestampMs = DateTime.now().millisecondsSinceEpoch.toDouble();

    _liveSensorSub?.cancel();
    _liveSensorSub = _liveSensorManager.telemetryStream.listen((LiveTelemetryData packet) {
      double dt = (packet.timestampMs - lastTimestampMs) / 1000.0;
      if (dt <= 0.001 || dt > 0.5) dt = 0.02; // Default to 50Hz (20ms) interval
      lastTimestampMs = packet.timestampMs;

      _processOriginalTelemetryStep(
        timestampMs: packet.timestampMs,
        rawAccel: packet.rawAccel,
        rawGyro: packet.rawGyro,
        rawMag: packet.rawMag,
        gnssPosition: packet.gnssPosition,
        gnssSpeedMs: packet.gnssSpeedMs,
        hdop: packet.hdop,
        satCount: packet.satCount,
        hasValidGnssFix: packet.hasGnssFix,
        dt: dt,
      );
    });
  }

  void _processOriginalTelemetryStep({
    required double timestampMs,
    required vm.Vector3 rawAccel,
    required vm.Vector3 rawGyro,
    required vm.Vector3 rawMag,
    required LatLng? gnssPosition,
    required double gnssSpeedMs,
    required double hdop,
    required int satCount,
    required bool hasValidGnssFix,
    required double dt,
  }) {
    // 1. Establish anchor origin upon receiving first real physical GNSS fix
    if (gnssPosition != null && !_hasInitialGnssFix) {
      _hasInitialGnssFix = true;
      _anchorPosition = gnssPosition;
      _currentDisplayedPosition = gnssPosition;
      _eskfEngine.reinitialize(vm.Vector3.zero(), vm.Vector3(0, gnssSpeedMs, 0), 0.0);
    }

    // 2. Step 1-3: Auto Zero-Touch In-Vehicle Alignment (Phone Mount -> Vehicle Driving Frame)
    _alignmentEngine.updateAlignment(
      rawAccel,
      rawGyro,
      isMovingForward: gnssSpeedMs > 0.5,
    );
    vm.Vector3 vehicleAccel = _alignmentEngine.transformToVehicleFrame(rawAccel);
    vm.Vector3 vehicleGyro = _alignmentEngine.transformToVehicleFrame(rawGyro);

    double gForce = rawAccel.length / 9.81;
    double turnRateDeg = vehicleGyro.z * 180.0 / math.pi;

    // 3. AI Speed & Vibration Filter Engine
    double predictedSpeedMs = _aiSpeedFilter.processImu(
      vehicleAccel: vehicleAccel,
      vehicleGyro: vehicleGyro,
      dt: dt,
      gnssSpeedMs: hasValidGnssFix ? gnssSpeedMs : null,
    );

    // 4. GNSS Deficit Handler (Step 5: Pure Inertial Tunnel Switch <50ms)
    IdrNavigationMode currentMode = _deficitHandler.evaluateStatus(
      currentTimeMs: timestampMs,
      hdop: hdop,
      satCount: satCount,
      hasValidGnssFix: hasValidGnssFix,
      currentSpeedMs: predictedSpeedMs,
      dt: dt,
    );

    // 5. 15-State Error-State Kalman Filter (ESKF) Sensor Fusion
    _eskfEngine.predict(
      vehicleAccel: vehicleAccel,
      vehicleGyro: vehicleGyro,
      dt: dt,
      isStationary: _aiSpeedFilter.isStationary,
      predictedSpeedMs: predictedSpeedMs,
    );

    if (currentMode == IdrNavigationMode.gnssAidedIns && gnssPosition != null) {
      vm.Vector3 gnssEnu = KinematicsMath.wgs84ToEnu(gnssPosition, _anchorPosition);
      vm.Vector3 gnssVel = vm.Vector3(
        gnssSpeedMs * math.sin(_eskfEngine.attitudeEuler.z),
        gnssSpeedMs * math.cos(_eskfEngine.attitudeEuler.z),
        0.0,
      );
      _eskfEngine.correctGnss(gnssPosEnu: gnssEnu, gnssVelEnu: gnssVel);
    }

    // 6. Kinematic Constraints & Dynamic Road Snapping
    LatLng rawEskfPos = _hasInitialGnssFix
        ? KinematicsMath.enuToWgs84(_eskfEngine.positionEnu, _anchorPosition)
        : (gnssPosition ?? _currentDisplayedPosition);
        
    double headingDeg = _eskfEngine.headingDeg;

    LatLng finalPosition = _mapMatchingEngine.snapToRoad(
      rawPosition: rawEskfPos,
      currentHeadingDeg: headingDeg,
      isDeadReckoning: currentMode == IdrNavigationMode.pureDeadReckoning,
    );

    // Update real-time 50Hz UI display
    if (mounted && (finalPosition.latitude != 0 || finalPosition.longitude != 0)) {
      setState(() {
        _currentDisplayedPosition = finalPosition;
        _currentHeadingDeg = headingDeg;
        _rawAccel = rawAccel;
        _rawGyro = rawGyro;
        _rawMag = rawMag;
        _liveGForce = gForce;
        _liveTurnRateDeg = turnRateDeg;

        if (predictedSpeedMs > 0.05 || (gForce - 1.0).abs() > 0.05) {
          _estimatedPath.add(finalPosition);
          if (_estimatedPath.length > 500) {
            _estimatedPath.removeAt(0);
          }
        }
      });

      _mapController.move(finalPosition, _mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Minimal Vector Map Layer
          MinimalMap(
            mapController: _mapController,
            currentPosition: _currentDisplayedPosition,
            headingDeg: _currentHeadingDeg,
            estimatedPath: _estimatedPath,
            groundTruthPath: const [],
            navigationMode: _deficitHandler.currentMode,
          ),

          // Top Header: Minimal Floating HUD Pill & Zero-Touch Flow Banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MinimalHud(
                  navigationMode: _deficitHandler.currentMode,
                  speedKmph: _aiSpeedFilter.estimatedSpeedKmph,
                  driftEstimateMeters: _deficitHandler.maxDriftEstimateM,
                  satCount: _deficitHandler.satelliteCount,
                  isPotholeDetected: _aiSpeedFilter.isPotholeDetected,
                  isLiveSensorMode: true,
                  liveGForce: _liveGForce,
                  liveTurnRateDeg: _liveTurnRateDeg,
                ),

                // Zero-Touch Flow Progress Banner (Step 1 -> 7)
                ZeroTouchBanner(
                  alignmentEngine: _alignmentEngine,
                  navigationMode: _deficitHandler.currentMode,
                ),
              ],
            ),
          ),

          // Bottom Real-Time 50Hz Live Telemetry & Mode Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TelemetryBottomSheet(
              isLiveSensorMode: true,
              isPlaying: true,
              currentProgress: 1.0,
              replaySpeedMultiplier: 1.0,
              forceTunnelMode: _deficitHandler.isDeadReckoning,
              alignmentEngine: _alignmentEngine,
              aiSpeedFilter: _aiSpeedFilter,
              rawAccel: _rawAccel,
              rawGyro: _rawGyro,
              rawMag: _rawMag,
              currentPos: _currentDisplayedPosition,
              currentSpeedKmph: _aiSpeedFilter.estimatedSpeedKmph,
              onChangeMotionMode: (VehicleMotionMode mode) {
                setState(() {
                  _aiSpeedFilter.setMotionMode(mode);
                });
              },
              onToggleLiveMode: () {},
              onPlayPause: () {},
              onSeek: (_) {},
              onToggleReplaySpeed: () {},
              onToggleForceTunnel: () {
                setState(() => _deficitHandler.toggleForceTunnelMode());
              },
              onReset: () {
                setState(() {
                  _estimatedPath.clear();
                  _deficitHandler.reset();
                  _aiSpeedFilter.reset(0);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

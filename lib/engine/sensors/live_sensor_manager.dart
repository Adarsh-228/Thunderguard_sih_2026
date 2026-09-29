import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart';

/// Live Telemetry Packet captured from Smartphone Physical Sensors
class LiveTelemetryData {
  final double timestampMs;
  final Vector3 rawAccel;      // m/s^2
  final Vector3 rawGyro;       // rad/s
  final Vector3 rawMag;        // uT
  final LatLng? gnssPosition;   // WGS84 Lat/Lon
  final double gnssSpeedMs;    // m/s
  final double hdop;           // Estimated accuracy (m)
  final int satCount;          // Satellite count indicator
  final bool hasGnssFix;

  LiveTelemetryData({
    required this.timestampMs,
    required this.rawAccel,
    required this.rawGyro,
    required this.rawMag,
    this.gnssPosition,
    required this.gnssSpeedMs,
    required this.hdop,
    required this.satCount,
    required this.hasGnssFix,
  });
}

/// Live Sensor Manager interfacing directly with Smartphone MEMS Accelerometer,
/// Gyroscope, Magnetometer, and GNSS Hardware.
class LiveSensorManager {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  StreamSubscription<Position>? _gnssSub;

  Vector3 _lastAccel = Vector3(0, 0, 9.81);
  Vector3 _lastGyro = Vector3.zero();
  Vector3 _lastMag = Vector3.zero();

  LatLng? _lastGnssPos;
  double _lastGnssSpeedMs = 0.0;
  double _lastAccuracyM = 1.0;
  bool _hasGnssFix = false;

  bool _isListening = false;
  bool get isListening => _isListening;

  final StreamController<LiveTelemetryData> _telemetryController = StreamController<LiveTelemetryData>.broadcast();
  Stream<LiveTelemetryData> get telemetryStream => _telemetryController.stream;

  /// Start listening to smartphone physical IMU and GNSS sensor streams
  Future<bool> startSensors() async {
    if (_isListening) return true;

    // 1. Request location permissions for GNSS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) print("Location services disabled on device");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 2. Fetch instant last-known position fix to eliminate initial timeout indoors
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      try {
        Position? lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          _lastGnssPos = LatLng(lastPos.latitude, lastPos.longitude);
          _lastGnssSpeedMs = lastPos.speed > 0 ? lastPos.speed : 0.0;
          _lastAccuracyM = lastPos.accuracy;
          _hasGnssFix = true;
          _dispatchTelemetryPacket();
        } else {
          // Fallback to fast current position query
          Position currentPos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 3),
            ),
          );
          _lastGnssPos = LatLng(currentPos.latitude, currentPos.longitude);
          _lastGnssSpeedMs = currentPos.speed > 0 ? currentPos.speed : 0.0;
          _lastAccuracyM = currentPos.accuracy;
          _hasGnssFix = true;
          _dispatchTelemetryPacket();
        }
      } catch (e) {
        debugPrint("Initial position acquisition note: $e");
      }
    }

    // 3. Listen to Smartphone Accelerometer Stream (~50Hz)
    _accelSub = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (AccelerometerEvent event) {
        _lastAccel = Vector3(event.x, event.y, event.z);
        _dispatchTelemetryPacket();
      },
      onError: (e) => debugPrint("Accel error: $e"),
    );

    // 4. Listen to Smartphone Gyroscope Stream (~50Hz)
    _gyroSub = gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (GyroscopeEvent event) {
        _lastGyro = Vector3(event.x, event.y, event.z);
      },
      onError: (e) => debugPrint("Gyro error: $e"),
    );

    // 5. Listen to Smartphone Magnetometer Stream
    _magSub = magnetometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
      (MagnetometerEvent event) {
        _lastMag = Vector3(event.x, event.y, event.z);
      },
      onError: (e) => debugPrint("Mag error: $e"),
    );

    // 6. Listen to Continuous Smartphone GNSS Location Stream (1Hz - 10Hz)
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );

      _gnssSub = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position pos) {
          _lastGnssPos = LatLng(pos.latitude, pos.longitude);
          _lastGnssSpeedMs = pos.speed > 0 ? pos.speed : 0.0;
          _lastAccuracyM = pos.accuracy;
          _hasGnssFix = true;
          _dispatchTelemetryPacket();
        },
        onError: (e) {
          _hasGnssFix = false;
          debugPrint("GNSS Stream Error: $e");
        },
      );
    }

    _isListening = true;
    return true;
  }

  void _dispatchTelemetryPacket() {
    double nowMs = DateTime.now().millisecondsSinceEpoch.toDouble();

    _telemetryController.add(
      LiveTelemetryData(
        timestampMs: nowMs,
        rawAccel: Vector3.copy(_lastAccel),
        rawGyro: Vector3.copy(_lastGyro),
        rawMag: Vector3.copy(_lastMag),
        gnssPosition: _lastGnssPos,
        gnssSpeedMs: _lastGnssSpeedMs,
        hdop: _lastAccuracyM,
        satCount: _hasGnssFix ? 12 : 0,
        hasGnssFix: _hasGnssFix,
      ),
    );
  }

  /// Stop sensor subscriptions
  Future<void> stopSensors() async {
    await _accelSub?.cancel();
    await _gyroSub?.cancel();
    await _magSub?.cancel();
    await _gnssSub?.cancel();
    _isListening = false;
  }

  void dispose() {
    stopSensors();
    _telemetryController.close();
  }
}

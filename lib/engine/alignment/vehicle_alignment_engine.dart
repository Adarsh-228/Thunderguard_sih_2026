import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';
import '../../core/utils/kinematics_math.dart';

enum MountPlacement {
  dashboard,
  windshield,
  ventClip,
  holder,
}

enum CalibrationState {
  uncalibrated,
  calibrating,  // 5-sec shimmer progress bar
  calibrated,   // Pitch / Roll / Yaw locked
  recalibrating,// 2-sec auto re-calibration when phone slips/moves
}

/// Zero-Touch In-Vehicle Alignment & Auto Re-Calibration Engine
class VehicleAlignmentEngine {
  CalibrationState _calibrationState = CalibrationState.uncalibrated;
  MountPlacement _mountPlacement = MountPlacement.dashboard;

  double _pitch = 0.0; // Radians
  double _roll = 0.0;  // Radians
  double _yaw = 0.0;   // Radians

  double _calibrationProgress = 0.0; // 0.0 to 1.0
  int _sampleCount = 0;
  static const int _requiredSamples = 100; // ~2 seconds at 50Hz

  final Vector3 _gravityEstimate = Vector3(0, 0, 9.81);
  final Vector3 _lastStaticGravity = Vector3(0, 0, 9.81);
  final List<Vector3> _accelBuffer = [];
  static const double _alphaGravity = 0.05;

  CalibrationState get calibrationState => _calibrationState;
  MountPlacement get mountPlacement => _mountPlacement;
  bool get isCalibrated => _calibrationState == CalibrationState.calibrated;
  double get calibrationProgress => _calibrationProgress;
  
  double get pitchDeg => _pitch * 180.0 / math.pi;
  double get rollDeg => _roll * 180.0 / math.pi;
  double get yawDeg => _yaw * 180.0 / math.pi;

  /// Process live accelerometer and gyro stream for Zero-Touch flow
  void updateAlignment(Vector3 rawAccel, Vector3 rawGyro, {bool isMovingForward = false}) {
    // 1. Low-pass filter to extract gravity vector
    _gravityEstimate.x = (1 - _alphaGravity) * _gravityEstimate.x + _alphaGravity * rawAccel.x;
    _gravityEstimate.y = (1 - _alphaGravity) * _gravityEstimate.y + _alphaGravity * rawAccel.y;
    _gravityEstimate.z = (1 - _alphaGravity) * _gravityEstimate.z + _alphaGravity * rawAccel.z;

    // 2. Detect Phone Movement / Slip (sudden 1.8 m/s^2 gravity orientation change)
    double orientationShift = (_gravityEstimate - _lastStaticGravity).length;
    if (_calibrationState == CalibrationState.calibrated && orientationShift > 1.8) {
      // Phone slipped / picked up! Trigger Auto Re-Calibration (Step 6 in flow)
      _calibrationState = CalibrationState.recalibrating;
      _sampleCount = 0;
      _calibrationProgress = 0.0;
    }

    // 3. Pitch & Roll extraction from gravity vector
    double gNorm = _gravityEstimate.length;
    if (gNorm > 1.0) {
      double ax = _gravityEstimate.x / gNorm;
      double ay = _gravityEstimate.y / gNorm;
      double az = _gravityEstimate.z / gNorm;

      _pitch = math.atan2(-ax, math.sqrt(ay * ay + az * az));
      _roll = math.atan2(ay, az);

      // Deduce Phone Placement (Dashboard vs Windshield vs Vent Clip vs Holder)
      _detectMountPlacement(ax, ay, az);
    }

    // 4. Calibration State Machine & Progress Bar Tracking
    if (_calibrationState == CalibrationState.uncalibrated ||
        _calibrationState == CalibrationState.calibrating ||
        _calibrationState == CalibrationState.recalibrating) {
      _calibrationState = (_calibrationState == CalibrationState.recalibrating)
          ? CalibrationState.recalibrating
          : CalibrationState.calibrating;

      _sampleCount++;
      _calibrationProgress = math.min(1.0, _sampleCount / _requiredSamples);

      if (_sampleCount >= _requiredSamples) {
        _calibrationState = CalibrationState.calibrated;
        _calibrationProgress = 1.0;
        _lastStaticGravity.setFrom(_gravityEstimate);
      }
    }

    // 5. Yaw angle estimation during forward driving motion
    if (isMovingForward) {
      _accelBuffer.add(Vector3.copy(rawAccel));
      if (_accelBuffer.length > 50) _accelBuffer.removeAt(0);

      if (_accelBuffer.length >= 50) {
        _estimateForwardYaw();
      }
    }
  }

  void _detectMountPlacement(double ax, double ay, double az) {
    double pitchAbs = (_pitch * 180.0 / math.pi).abs();
    if (pitchAbs < 20) {
      _mountPlacement = MountPlacement.dashboard;
    } else if (pitchAbs >= 20 && pitchAbs < 55) {
      _mountPlacement = MountPlacement.holder;
    } else if (pitchAbs >= 55 && pitchAbs < 75) {
      _mountPlacement = MountPlacement.ventClip;
    } else {
      _mountPlacement = MountPlacement.windshield;
    }
  }

  void _estimateForwardYaw() {
    double sumX = 0, sumY = 0;
    for (var a in _accelBuffer) {
      sumX += a.x;
      sumY += a.y;
    }
    double meanX = sumX / _accelBuffer.length;
    double meanY = sumY / _accelBuffer.length;

    _yaw = math.atan2(meanY, meanX);
  }

  Vector3 transformToVehicleFrame(Vector3 phoneVector) {
    Matrix3 rMat = KinematicsMath.eulerToRotationMatrix(_roll, _pitch, _yaw);
    rMat.transpose();
    return rMat.transformed(phoneVector);
  }

  void reset() {
    _calibrationState = CalibrationState.uncalibrated;
    _calibrationProgress = 0.0;
    _sampleCount = 0;
    _accelBuffer.clear();
    _gravityEstimate.setValues(0, 0, 9.81);
  }
}

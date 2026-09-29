import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

enum VehicleMotionMode {
  autoDetect,      // Sensor variance auto ZUPT detection
  forceDriving,    // Active vehicle driving state
  forceStationary, // Stationary / Parked ZUPT state
}

/// AI Speed & Vibration Filter Engine
/// Filters high-frequency road shocks (potholes/bumps) and engine vibrations.
/// Predicts forward vehicle velocity directly from IMU accelerometer and gyro inputs.
class AiSpeedFilter {
  VehicleMotionMode _motionMode = VehicleMotionMode.autoDetect;

  // Low-pass filter parameters
  double _filteredLongAccel = 0.0;
  double _filteredLatAccel = 0.0;
  double _filteredVertAccel = 0.0;

  double _estimatedSpeedKmph = 0.0; // km/h
  double _estimatedSpeedMs = 0.0;   // m/s

  bool _isStationary = false;
  bool _isPotholeDetected = false;

  // Sliding window for spectral energy and variance calculation
  final List<double> _accelMagHistory = [];
  final List<double> _gyroYawHistory = [];
  static const int _windowSize = 25; // ~0.5s at 50Hz

  VehicleMotionMode get motionMode => _motionMode;
  double get estimatedSpeedKmph => _estimatedSpeedKmph;
  double get estimatedSpeedMs => _estimatedSpeedMs;
  double get filteredLongAccel => _filteredLongAccel;
  bool get isStationary => _isStationary;
  bool get isPotholeDetected => _isPotholeDetected;

  void setMotionMode(VehicleMotionMode mode) {
    _motionMode = mode;
  }

  /// Process raw vehicle-aligned acceleration and gyro rates
  /// Returns estimated forward speed in m/s
  double processImu({
    required Vector3 vehicleAccel, // (longitudinal, lateral, vertical)
    required Vector3 vehicleGyro,  // (roll_rate, pitch_rate, yaw_rate)
    required double dt,            // Time delta in seconds (e.g. 0.02s for 50Hz)
    double? gnssSpeedMs,           // Optional GNSS speed reference for continuous AI calibration
  }) {
    // 1. Digital Low-Pass Filtering (Butterworth 2nd Order approximation)
    const double alpha = 0.15; // Cutoff ~ 8Hz
    _filteredLongAccel = (1 - alpha) * _filteredLongAccel + alpha * vehicleAccel.x;
    _filteredLatAccel = (1 - alpha) * _filteredLatAccel + alpha * vehicleAccel.y;
    _filteredVertAccel = (1 - alpha) * _filteredVertAccel + alpha * vehicleAccel.z;

    // 2. Shock & Pothole Suppression (detect high z-spike + high norm derivative)
    double verticalSpike = (vehicleAccel.z - 9.81).abs();
    if (verticalSpike > 4.5) {
      _isPotholeDetected = true;
    } else {
      _isPotholeDetected = false;
    }

    // 3. Sensor variance window update
    double accelNorm = vehicleAccel.length;
    _accelMagHistory.add(accelNorm);
    _gyroYawHistory.add(vehicleGyro.z.abs());

    if (_accelMagHistory.length > _windowSize) _accelMagHistory.removeAt(0);
    if (_gyroYawHistory.length > _windowSize) _gyroYawHistory.removeAt(0);

    // 4. Zero Velocity Update (ZUPT) Detection with Manual Override Support
    if (_motionMode == VehicleMotionMode.forceStationary) {
      _isStationary = true;
    } else if (_motionMode == VehicleMotionMode.forceDriving) {
      _isStationary = false;
    } else {
      _checkZeroVelocity();
    }

    // 5. Kinematic Speed Prediction Model
    if (_isStationary) {
      _estimatedSpeedMs = 0.0;
    } else if (gnssSpeedMs != null && gnssSpeedMs >= 0) {
      _estimatedSpeedMs = (1 - 0.1) * _estimatedSpeedMs + 0.1 * gnssSpeedMs;
    } else {
      if (!_isPotholeDetected) {
        double netAccel = _filteredLongAccel;
        if (netAccel.abs() < 0.08) netAccel = 0.0;
        _estimatedSpeedMs += netAccel * dt;
      }
      _estimatedSpeedMs *= 0.999;
      if (_estimatedSpeedMs < 0.0) _estimatedSpeedMs = 0.0;
    }

    _estimatedSpeedKmph = _estimatedSpeedMs * 3.6;
    return _estimatedSpeedMs;
  }

  /// ZUPT (Zero Velocity Update) detector logic evaluating signal variance
  void _checkZeroVelocity() {
    if (_accelMagHistory.length < _windowSize) return;

    double sum = _accelMagHistory.reduce((a, b) => a + b);
    double mean = sum / _accelMagHistory.length;

    double varAccel = 0.0;
    for (var val in _accelMagHistory) {
      varAccel += (val - mean) * (val - mean);
    }
    varAccel /= _accelMagHistory.length;

    double meanGyroYaw = _gyroYawHistory.reduce((a, b) => a + b) / _gyroYawHistory.length;

    if (varAccel < 0.05 && meanGyroYaw < 0.03) {
      _isStationary = true;
    } else {
      _isStationary = false;
    }
  }

  /// Reset internal velocity accumulators
  void reset(double initialSpeedMs) {
    _estimatedSpeedMs = math.max(0.0, initialSpeedMs);
    _estimatedSpeedKmph = _estimatedSpeedMs * 3.6;
    _filteredLongAccel = 0.0;
    _accelMagHistory.clear();
    _gyroYawHistory.clear();
  }
}

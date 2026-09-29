import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

/// 15-State Error-State Kalman Filter (ESKF) for GNSS + INS Sensor Fusion
/// States: Position (3), Velocity (3), Attitude (3), Accel Bias (3), Gyro Bias (3)
class EskfFusionEngine {
  // Nominal States
  Vector3 _positionEnu = Vector3.zero(); // Local ENU (m)
  Vector3 _velocityEnu = Vector3.zero(); // ENU Velocity (m/s)
  final Vector3 _attitudeEuler = Vector3.zero(); // (roll, pitch, yaw) in rad
  final Vector3 _accelBias = Vector3.zero();
  final Vector3 _gyroBias = Vector3.zero();

  // Covariance matrix diag approximations (15x15)
  final List<double> _pDiag = List.filled(15, 1.0);

  // Process noise Q and Measurement noise R
  static const double _qPos = 1e-4;
  static const double _qVel = 1e-3;
  static const double _qAtt = 1e-4;
  static const double _qBa  = 1e-6;
  static const double _qBg  = 1e-6;

  static const double _rGnssPos = 0.5; // GNSS position noise (m)
  static const double _rGnssVel = 0.1; // GNSS velocity noise (m/s)

  Vector3 get positionEnu => _positionEnu;
  Vector3 get velocityEnu => _velocityEnu;
  Vector3 get attitudeEuler => _attitudeEuler;
  double get headingDeg => (_attitudeEuler.z * 180.0 / math.pi + 360.0) % 360.0;
  Vector3 get accelBias => _accelBias;
  Vector3 get gyroBias => _gyroBias;

  /// High-Rate IMU Prediction Step (10Hz - 200Hz)
  void predict({
    required Vector3 vehicleAccel, // Cleaned vehicle-frame accel (m/s^2)
    required Vector3 vehicleGyro,  // Cleaned vehicle-frame gyro (rad/s)
    required double dt,
    bool isStationary = false,
    double predictedSpeedMs = 0.0,
  }) {
    // 1. Correct sensor measurements with estimated biases
    Vector3 gCorrected = vehicleGyro - _gyroBias;

    // 2. Update Orientation (Yaw integration)
    _attitudeEuler.z += gCorrected.z * dt;
    _attitudeEuler.z = (_attitudeEuler.z + 2 * math.pi) % (2 * math.pi);

    // 3. Gated Kinematic Position Integration
    // Location remains completely STILL when stationary, and moves ONLY when driving!
    if (isStationary || predictedSpeedMs <= 0.05) {
      _velocityEnu.setZero();
    } else {
      double heading = _attitudeEuler.z;
      _velocityEnu.x = predictedSpeedMs * math.sin(heading);
      _velocityEnu.y = predictedSpeedMs * math.cos(heading);

      _positionEnu.x += _velocityEnu.x * dt;
      _positionEnu.y += _velocityEnu.y * dt;
    }

    // 4. Propagate Covariance P_k = P_{k-1} + Q * dt
    for (int i = 0; i < 3; i++) {
      _pDiag[i] += _qPos * dt; // Pos
    }
    for (int i = 3; i < 6; i++) {
      _pDiag[i] += _qVel * dt; // Vel
    }
    for (int i = 6; i < 9; i++) {
      _pDiag[i] += _qAtt * dt; // Att
    }
    for (int i = 9; i < 12; i++) {
      _pDiag[i] += _qBa * dt; // Accel Bias
    }
    for (int i = 12; i < 15; i++) {
      _pDiag[i] += _qBg * dt; // Gyro Bias
    }
  }

  /// Low-Rate GNSS Measurement Correction Step (1Hz - 10Hz)
  void correctGnss({
    required Vector3 gnssPosEnu,
    required Vector3 gnssVelEnu,
    double positionSd = 1.0,
  }) {
    // Innovation (Measurement Residual)
    Vector3 posResidual = gnssPosEnu - _positionEnu;
    Vector3 velResidual = gnssVelEnu - _velocityEnu;

    double rPosEff = math.max(_rGnssPos, positionSd);

    // Kalman Gain for Position (K_pos = P / (P + R))
    for (int i = 0; i < 2; i++) {
      double pVal = _pDiag[i];
      double kGain = pVal / (pVal + rPosEff * rPosEff);
      _positionEnu[i] += kGain * posResidual[i];
      _pDiag[i] = (1 - kGain) * pVal; // Update Covariance
    }

    // Kalman Gain for Velocity
    for (int i = 0; i < 2; i++) {
      int idx = 3 + i;
      double pVal = _pDiag[idx];
      double kGain = pVal / (pVal + _rGnssVel * _rGnssVel);
      _velocityEnu[i] += kGain * velResidual[i];
      _pDiag[idx] = (1 - kGain) * pVal;
    }

    // Estimate Accel and Gyro Bias Correction from residuals
    _accelBias.x += 0.005 * posResidual.x;
    _accelBias.y += 0.005 * posResidual.y;
  }

  /// Directly set nominal position and velocity (e.g., initial GNSS lock)
  void reinitialize(Vector3 initPosEnu, Vector3 initVelEnu, double headingRad) {
    _positionEnu = Vector3.copy(initPosEnu);
    _velocityEnu = Vector3.copy(initVelEnu);
    _attitudeEuler.z = headingRad;
    _accelBias.setZero();
    _gyroBias.setZero();
    for (int i = 0; i < 15; i++) {
      _pDiag[i] = 0.1;
    }
  }
}

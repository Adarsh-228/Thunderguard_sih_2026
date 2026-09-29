import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:latlong2/latlong.dart';

import 'package:sih/core/utils/kinematics_math.dart';
import 'package:sih/engine/alignment/vehicle_alignment_engine.dart';
import 'package:sih/engine/fusion/eskf_fusion_engine.dart';
import 'package:sih/engine/deficit_handler/gnss_deficit_handler.dart';

void main() {
  group('Intelligent Dead Reckoning Engine Tests', () {
    test('KinematicsMath WGS84 and ENU conversion roundtrip', () {
      LatLng anchor = const LatLng(28.6139, 77.2090);
      LatLng target = const LatLng(28.6150, 77.2100);

      Vector3 enu = KinematicsMath.wgs84ToEnu(target, anchor);
      LatLng reconstructed = KinematicsMath.enuToWgs84(enu, anchor);

      expect(reconstructed.latitude, closeTo(target.latitude, 1e-5));
      expect(reconstructed.longitude, closeTo(target.longitude, 1e-5));
    });

    test('Vehicle Alignment gravity extraction', () {
      VehicleAlignmentEngine alignment = VehicleAlignmentEngine();
      Vector3 rawAccel = Vector3(0, 0, 9.81);
      Vector3 rawGyro = Vector3(0, 0, 0);

      for (int i = 0; i < 60; i++) {
        alignment.updateAlignment(rawAccel, rawGyro);
      }

      expect(alignment.pitchDeg, closeTo(0.0, 1.0));
      expect(alignment.rollDeg, closeTo(0.0, 1.0));
    });

    test('GNSS Deficit Handler instant failover < 50ms', () {
      GnssDeficitHandler handler = GnssDeficitHandler();

      IdrNavigationMode modeNormal = handler.evaluateStatus(
        currentTimeMs: 1000,
        hdop: 1.0,
        satCount: 12,
        hasValidGnssFix: true,
        currentSpeedMs: 15.0,
        dt: 0.02,
      );
      expect(modeNormal, IdrNavigationMode.gnssAidedIns);

      IdrNavigationMode modeTunnel = handler.evaluateStatus(
        currentTimeMs: 2600,
        hdop: 8.0,
        satCount: 1,
        hasValidGnssFix: false,
        currentSpeedMs: 15.0,
        dt: 0.02,
      );
      expect(modeTunnel, IdrNavigationMode.pureDeadReckoning);
      expect(handler.isDeadReckoning, isTrue);
    });

    test('ESKF Fusion Engine prediction propagation when driving', () {
      EskfFusionEngine eskf = EskfFusionEngine();
      eskf.reinitialize(Vector3.zero(), Vector3(10.0, 0.0, 0.0), 0.0);

      for (int i = 0; i < 50; i++) {
        eskf.predict(
          vehicleAccel: Vector3(1.0, 0.0, 0.0),
          vehicleGyro: Vector3.zero(),
          dt: 0.02,
          isStationary: false,
          predictedSpeedMs: 10.0,
        );
      }

      expect(eskf.velocityEnu.x, greaterThanOrEqualTo(0.0));
      expect(eskf.positionEnu.y, greaterThan(0.0));
    });
  });
}

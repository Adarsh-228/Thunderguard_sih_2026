import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';
import 'package:latlong2/latlong.dart';

/// Kinematic and Geodetic Mathematics Utilities for GNSS + INS Dead Reckoning
class KinematicsMath {
  static const double wgs84A = 6378137.0; // Semi-major axis in meters
  static const double wgs84F = 1.0 / 298.257223563; // Flattening
  static const double wgs84E2 = 2 * wgs84F - wgs84F * wgs84F; // Eccentricity squared

  /// Convert Euler angles (roll, pitch, yaw in radians) to 3x3 Rotation Matrix (Body to Vehicle/Navigation)
  static Matrix3 eulerToRotationMatrix(double roll, double pitch, double yaw) {
    double cr = math.cos(roll);
    double sr = math.sin(roll);
    double cp = math.cos(pitch);
    double sp = math.sin(pitch);
    double cy = math.cos(yaw);
    double sy = math.sin(yaw);

    // Z-Y-X rotation sequence
    double m00 = cy * cp;
    double m01 = cy * sp * sr - sy * cr;
    double m02 = cy * sp * cr + sy * sr;

    double m10 = sy * cp;
    double m11 = sy * sp * sr + cy * cr;
    double m12 = sy * sp * cr - cy * sr;

    double m20 = -sp;
    double m21 = cp * sr;
    double m22 = cp * cr;

    return Matrix3(
      m00, m01, m02,
      m10, m11, m12,
      m20, m21, m22,
    );
  }

  /// Convert WGS-84 Geodetic Coordinates (Lat, Lon, Alt) to Local ENU (East, North, Up) relative to Anchor
  static Vector3 wgs84ToEnu(LatLng point, LatLng anchor, {double pointAlt = 0, double anchorAlt = 0}) {
    double latRad = point.latitude * math.pi / 180.0;
    double lonRad = point.longitude * math.pi / 180.0;
    double refLatRad = anchor.latitude * math.pi / 180.0;
    double refLonRad = anchor.longitude * math.pi / 180.0;

    double dLat = latRad - refLatRad;
    double dLon = lonRad - refLonRad;

    // Radius of curvature in prime vertical
    double nVal = wgs84A / math.sqrt(1.0 - wgs84E2 * math.sin(refLatRad) * math.sin(refLatRad));

    double east = dLon * nVal * math.cos(refLatRad);
    double north = dLat * nVal;
    double up = pointAlt - anchorAlt;

    return Vector3(east, north, up);
  }

  /// Convert Local ENU (East, North, Up) relative to Anchor back to WGS-84 LatLng
  static LatLng enuToWgs84(Vector3 enu, LatLng anchor) {
    double refLatRad = anchor.latitude * math.pi / 180.0;
    double nVal = wgs84A / math.sqrt(1.0 - wgs84E2 * math.sin(refLatRad) * math.sin(refLatRad));

    double dLatRad = enu.y / nVal;
    double dLonRad = enu.x / (nVal * math.cos(refLatRad));

    double newLat = anchor.latitude + (dLatRad * 180.0 / math.pi);
    double newLon = anchor.longitude + (dLonRad * 180.0 / math.pi);

    return LatLng(newLat, newLon);
  }

  /// Calculate distance in meters between two LatLng points using Haversine
  static double haversineDistance(LatLng p1, LatLng p2) {
    const Distance dist = Distance();
    return dist.as(LengthUnit.Meter, p1, p2);
  }

  /// Calculate initial bearing (heading) in degrees between two LatLng points (0..360)
  static double calculateBearing(LatLng p1, LatLng p2) {
    double lat1 = p1.latitude * math.pi / 180.0;
    double lat2 = p2.latitude * math.pi / 180.0;
    double dLon = (p2.longitude - p1.longitude) * math.pi / 180.0;

    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double brgRad = math.atan2(y, x);
    double brgDeg = (brgRad * 180.0 / math.pi + 360.0) % 360.0;
    return brgDeg;
  }
}

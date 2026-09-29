import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import 'package:vector_math/vector_math_64.dart';
import '../../core/utils/kinematics_math.dart';

/// Road Segment definition for vector map snapping
class RoadSegment {
  final String id;
  final LatLng start;
  final LatLng end;
  final double headingDeg;

  RoadSegment({required this.id, required this.start, required this.end})
      : headingDeg = KinematicsMath.calculateBearing(start, end);
}

/// Advanced Map-Matching & Kinematic Constraints Engine
/// Applies Non-Holonomic Constraints (NHC) and Hidden Markov Map-Matching (HMM)
/// to snap dead-reckoning trajectory to actual road grid.
class MapMatchingEngine {
  final List<RoadSegment> _roadNetwork = [];
  RoadSegment? _activeMatchedSegment;

  List<RoadSegment> get roadNetwork => _roadNetwork;
  RoadSegment? get activeMatchedSegment => _activeMatchedSegment;

  /// Load road network nodes into map engine
  void loadRoadNetwork(List<RoadSegment> segments) {
    _roadNetwork.clear();
    _roadNetwork.addAll(segments);
  }

  /// Apply Non-Holonomic Constraints (NHC) to raw vehicle velocity
  /// Car cannot slide sideways ($v_y = 0$) or float upwards ($v_z = 0$)
  Vector3 applyNhc(Vector3 rawVehicleVel) {
    return Vector3(rawVehicleVel.x, 0.0, 0.0);
  }

  /// Snap estimated LatLng position to nearest valid road segment using HMM logic
  LatLng snapToRoad({
    required LatLng rawPosition,
    required double currentHeadingDeg,
    bool isDeadReckoning = false,
  }) {
    if (_roadNetwork.isEmpty) return rawPosition;

    RoadSegment? bestSegment;
    double bestScore = double.infinity;
    LatLng bestSnapPoint = rawPosition;

    for (var segment in _roadNetwork) {
      // Compute perpendicular projection onto road segment
      LatLng projected = _projectPointToSegment(rawPosition, segment.start, segment.end);
      double distMeters = KinematicsMath.haversineDistance(rawPosition, projected);

      // Angle error between vehicle heading and road heading
      double headingDiff = (currentHeadingDeg - segment.headingDeg).abs();
      if (headingDiff > 180.0) headingDiff = 360.0 - headingDiff;

      // HMM Emission & Transition Penalty Score
      // Lower score = higher probability match
      double penalty = distMeters + (headingDiff * 0.4);

      if (penalty < bestScore) {
        bestScore = penalty;
        bestSegment = segment;
        bestSnapPoint = projected;
      }
    }

    _activeMatchedSegment = bestSegment;

    // In dead reckoning, snap to road if within 25m distance threshold
    if (isDeadReckoning && bestScore < 30.0) {
      return bestSnapPoint;
    } else if (!isDeadReckoning && bestScore < 15.0) {
      return bestSnapPoint;
    }

    return rawPosition;
  }

  /// Perpendicular projection of point P onto line segment AB
  LatLng _projectPointToSegment(LatLng p, LatLng a, LatLng b) {
    double x = p.longitude;
    double y = p.latitude;
    double x1 = a.longitude;
    double y1 = a.latitude;
    double x2 = b.longitude;
    double y2 = b.latitude;

    double dx = x2 - x1;
    double dy = y2 - y1;

    if (dx == 0 && dy == 0) return a;

    double t = ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy);
    t = math.max(0.0, math.min(1.0, t));

    return LatLng(y1 + t * dy, x1 + t * dx);
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../engine/deficit_handler/gnss_deficit_handler.dart';

/// Ultra-Clean Minimal Map View Widget with Dynamic Motion Pulse Halo
class MinimalMap extends StatelessWidget {
  final MapController mapController;
  final LatLng currentPosition;
  final double headingDeg;
  final List<LatLng> estimatedPath;
  final List<LatLng> groundTruthPath;
  final IdrNavigationMode navigationMode;

  const MinimalMap({
    super.key,
    required this.mapController,
    required this.currentPosition,
    required this.headingDeg,
    required this.estimatedPath,
    required this.groundTruthPath,
    required this.navigationMode,
  });

  @override
  Widget build(BuildContext context) {
    bool isDr = navigationMode == IdrNavigationMode.pureDeadReckoning;
    Color pathColor = isDr ? AppColors.tunnelActive : AppColors.accentBlue;

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentPosition,
        initialZoom: 17.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        // Dark Map Tile Layer (CartoDB Dark Voyager / OSM with valid User-Agent)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.sih',
          tileBuilder: (context, tileWidget, tile) {
            // Apply dark grey filter to standard map tiles for sleek dark aesthetic
            return ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                -0.2, 0.0, 0.0, 0.0, 255,
                0.0, -0.2, 0.0, 0.0, 255,
                0.0, 0.0, -0.2, 0.0, 255,
                0.0, 0.0, 0.0, 1.0, 0,
              ]),
              child: tileWidget,
            );
          },
        ),

        // Ground Truth Reference Path Layer
        if (groundTruthPath.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: groundTruthPath,
                strokeWidth: 3.5,
                color: AppColors.groundTruthPath.withValues(alpha: 0.5),
              ),
            ],
          ),

        // Estimated GNSS + INS Dead Reckoning Trajectory Path Layer
        if (estimatedPath.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: estimatedPath,
                strokeWidth: 4.5,
                color: pathColor,
              ),
            ],
          ),

        // Vehicle Location Marker with Motion Pulse Ring & Heading Arrow Rotation
        MarkerLayer(
          markers: [
            Marker(
              point: currentPosition,
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Motion Pulse Halo Outer Ring
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: pathColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Rotating Heading Direction Arrow Icon
                  Transform.rotate(
                    angle: headingDeg * math.pi / 180.0,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: pathColor, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: pathColor.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.navigation_rounded,
                        color: pathColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

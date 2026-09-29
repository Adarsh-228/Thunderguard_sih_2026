import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../engine/alignment/vehicle_alignment_engine.dart';
import '../../engine/deficit_handler/gnss_deficit_handler.dart';

/// Zero-Touch In-Vehicle Flow Banner
/// Implements the exact 7-Step Zero-Touch Navigation User Flow:
/// 1. Open App (Location Granted)
/// 2. Place Phone Anywhere (Dashboard, Vent Clip, Windshield, Holder)
/// 3. Just Drive Normally - 5 sec Shimmer Progress
/// 4. ✓ Calibrated - Pitch / Roll / Yaw Locked
/// 5. Pure Inertial Tunnel Mode
/// 6. Auto Re-Calibration on Phone Slip
class ZeroTouchBanner extends StatelessWidget {
  final VehicleAlignmentEngine alignmentEngine;
  final IdrNavigationMode navigationMode;

  const ZeroTouchBanner({
    super.key,
    required this.alignmentEngine,
    required this.navigationMode,
  });

  @override
  Widget build(BuildContext context) {
    CalibrationState state = alignmentEngine.calibrationState;
    MountPlacement placement = alignmentEngine.mountPlacement;
    bool isDr = navigationMode == IdrNavigationMode.pureDeadReckoning;

    Color bannerColor;
    String statusTitle;
    String statusSubtitle;
    IconData statusIcon;

    if (isDr) {
      bannerColor = AppColors.tunnelActive;
      statusTitle = "⑤ Pure Inertial Mode (Automatic)";
      statusSubtitle = "AI Speed Filter + NHC + OSM Map-Matching — No Drift";
      statusIcon = Icons.tune_rounded;
    } else if (state == CalibrationState.recalibrating) {
      bannerColor = AppColors.accentBlue;
      statusTitle = "⑥ Auto Re-Calibration (2–3 sec)";
      statusSubtitle = "Phone moved/slipped · Re-locking Pitch/Roll/Yaw";
      statusIcon = Icons.screen_rotation_rounded;
    } else if (state == CalibrationState.calibrated) {
      bannerColor = AppColors.gnssActive;
      statusTitle = "✓ Calibrated — Ready to Navigate";
      statusSubtitle = "Pitch: ${alignmentEngine.pitchDeg.toStringAsFixed(1)}° | Roll: ${alignmentEngine.rollDeg.toStringAsFixed(1)}° | Yaw: ${alignmentEngine.yawDeg.toStringAsFixed(1)}°";
      statusIcon = Icons.check_circle_rounded;
    } else {
      bannerColor = AppColors.accentBlue;
      statusTitle = "③ Just Drive Normally — Auto Calibrating (5s)";
      statusSubtitle = "No setup required · Place phone anywhere in vehicle";
      statusIcon = Icons.directions_car_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: bannerColor.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Status Icon, Title, and Placement Badge
          Row(
            children: [
              Icon(statusIcon, color: bannerColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusTitle,
                  style: TextStyle(
                    color: bannerColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Step 2: Placement Detector Pill (Dashboard / Vent Clip / Windshield / Holder)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGrey, width: 0.8),
                ),
                child: Text(
                  _getPlacementLabel(placement),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Subtitle text
          Text(
            statusSubtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),

          // Step 3: Shimmer Progress Bar during Calibration
          if (state == CalibrationState.calibrating || state == CalibrationState.recalibrating) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: alignmentEngine.calibrationProgress,
                backgroundColor: AppColors.cardSurface,
                valueColor: AlwaysStoppedAnimation<Color>(bannerColor),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getPlacementLabel(MountPlacement placement) {
    switch (placement) {
      case MountPlacement.dashboard:
        return "📍 Dashboard";
      case MountPlacement.windshield:
        return "🪟 Windshield";
      case MountPlacement.ventClip:
        return "🌬️ Vent Clip";
      case MountPlacement.holder:
        return "📱 Mobile Holder";
    }
  }
}

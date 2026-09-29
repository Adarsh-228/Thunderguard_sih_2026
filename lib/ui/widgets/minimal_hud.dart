import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../engine/deficit_handler/gnss_deficit_handler.dart';

/// Minimal, Zero-Clutter Floating HUD Pill with Live IMU Motion Feedback
class MinimalHud extends StatelessWidget {
  final IdrNavigationMode navigationMode;
  final double speedKmph;
  final double driftEstimateMeters;
  final int satCount;
  final bool isPotholeDetected;
  final bool isLiveSensorMode;
  final double liveGForce;
  final double liveTurnRateDeg;

  const MinimalHud({
    super.key,
    required this.navigationMode,
    required this.speedKmph,
    required this.driftEstimateMeters,
    required this.satCount,
    required this.isPotholeDetected,
    required this.isLiveSensorMode,
    this.liveGForce = 1.0,
    this.liveTurnRateDeg = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    bool isDr = navigationMode == IdrNavigationMode.pureDeadReckoning;
    Color modeColor = isDr ? AppColors.tunnelActive : AppColors.gnssActive;
    String modeLabel = isDr ? "TUNNEL / DEAD RECKONING" : "GNSS + INS AIDED";

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: AppColors.borderGrey, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Mode Indicator Badge & Live G-Force Motion Meter
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isPotholeDetected ? AppColors.warningRed : modeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isPotholeDetected ? AppColors.warningRed : modeColor).withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          modeLabel,
                          style: TextStyle(
                            color: modeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isLiveSensorMode ? AppColors.accentBlue.withValues(alpha: 0.2) : AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isLiveSensorMode ? AppColors.accentBlue : AppColors.borderGrey,
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            "LIVE HARDWARE",
                            style: TextStyle(
                              color: AppColors.accentBlue,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          "IMU: ${liveGForce.toStringAsFixed(2)}g",
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Turn: ${liveTurnRateDeg >= 0 ? '+' : ''}${liveTurnRateDeg.toStringAsFixed(0)}°/s",
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Speed Indicator
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  speedKmph.toStringAsFixed(0),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                const Text(
                  "km/h",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

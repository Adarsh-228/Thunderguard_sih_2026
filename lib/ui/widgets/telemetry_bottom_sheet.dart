import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../engine/alignment/vehicle_alignment_engine.dart';
import '../../engine/ai_speed/ai_speed_filter.dart';

/// Lightweight Bottom Control Bar & Real-Time Sensor Telemetry Drawer
/// Shows 50Hz high-frequency live changing sensor values (IMU 3-axis accel, gyro, mag, speed, pitch/roll/yaw)
class TelemetryBottomSheet extends StatefulWidget {
  final bool isLiveSensorMode;
  final bool isPlaying;
  final double currentProgress;
  final double replaySpeedMultiplier;
  final bool forceTunnelMode;
  final VehicleAlignmentEngine alignmentEngine;
  final AiSpeedFilter aiSpeedFilter;
  final Vector3 rawAccel;
  final Vector3 rawGyro;
  final Vector3 rawMag;
  final LatLng currentPos;
  final double currentSpeedKmph;
  final ValueChanged<VehicleMotionMode> onChangeMotionMode;
  final VoidCallback onToggleLiveMode;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSeek;
  final VoidCallback onToggleReplaySpeed;
  final VoidCallback onToggleForceTunnel;
  final VoidCallback onReset;

  const TelemetryBottomSheet({
    super.key,
    required this.isLiveSensorMode,
    required this.isPlaying,
    required this.currentProgress,
    required this.replaySpeedMultiplier,
    required this.forceTunnelMode,
    required this.alignmentEngine,
    required this.aiSpeedFilter,
    required this.rawAccel,
    required this.rawGyro,
    required this.rawMag,
    required this.currentPos,
    required this.currentSpeedKmph,
    required this.onChangeMotionMode,
    required this.onToggleLiveMode,
    required this.onPlayPause,
    required this.onSeek,
    required this.onToggleReplaySpeed,
    required this.onToggleForceTunnel,
    required this.onReset,
  });

  @override
  State<TelemetryBottomSheet> createState() => _TelemetryBottomSheetState();
}

class _TelemetryBottomSheetState extends State<TelemetryBottomSheet> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    VehicleMotionMode currentMotionMode = widget.aiSpeedFilter.motionMode;

    return Container(
      padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 12.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        border: Border(top: BorderSide(color: AppColors.borderGrey, width: 1.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle & Expand Toggle
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          "LIVE TELEMETRY (50Hz SENSORS)",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded ? "Collapse" : "Live 3-Axis",
                            style: const TextStyle(
                              color: AppColors.accentBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                            color: AppColors.accentBlue,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Vehicle Motion Mode Selector Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "MODE: ",
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                _buildModeChip(
                  label: "AUTO",
                  isSelected: currentMotionMode == VehicleMotionMode.autoDetect,
                  color: AppColors.accentBlue,
                  onTap: () => widget.onChangeMotionMode(VehicleMotionMode.autoDetect),
                ),
                const SizedBox(width: 4),
                _buildModeChip(
                  label: "DRIVING",
                  isSelected: currentMotionMode == VehicleMotionMode.forceDriving,
                  color: AppColors.gnssActive,
                  onTap: () => widget.onChangeMotionMode(VehicleMotionMode.forceDriving),
                ),
                const SizedBox(width: 4),
                _buildModeChip(
                  label: "STATIONARY",
                  isSelected: currentMotionMode == VehicleMotionMode.forceStationary,
                  color: AppColors.warningRed,
                  onTap: () => widget.onChangeMotionMode(VehicleMotionMode.forceStationary),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Controls Row (Outage Simulation Trigger)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Live Sensor Active Indicator Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gnssActive.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gnssActive, width: 1.0),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors, color: AppColors.gnssActive, size: 12),
                      SizedBox(width: 4),
                      Text(
                        "LIVE HARDWARE",
                        style: TextStyle(
                          color: AppColors.gnssActive,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Outage Test Simulation Trigger
                FilterChip(
                  label: Text(
                    widget.forceTunnelMode ? "TUNNEL ACTIVE" : "SIMULATE TUNNEL",
                    style: TextStyle(
                      color: widget.forceTunnelMode ? AppColors.tunnelActive : AppColors.textPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: widget.forceTunnelMode,
                  onSelected: (_) => widget.onToggleForceTunnel(),
                  backgroundColor: AppColors.cardSurface,
                  selectedColor: AppColors.tunnelActive.withValues(alpha: 0.25),
                  checkmarkColor: AppColors.tunnelActive,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: BorderSide(
                    color: widget.forceTunnelMode ? AppColors.tunnelActive : AppColors.borderGrey,
                  ),
                ),
              ],
            ),

            // Expandable High-Frequency Real-Time Telemetry Data Grid (50Hz Live Numbers)
            if (_isExpanded) ...[
              const Divider(color: AppColors.borderGrey, height: 14),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Grid Row 1: Raw Accelerometer 3-Axis (m/s^2)
                    Row(
                      children: [
                        _buildLiveNumberCard("Accel X", "${widget.rawAccel.x.toStringAsFixed(2)} m/s²", AppColors.accentBlue),
                        const SizedBox(width: 6),
                        _buildLiveNumberCard("Accel Y", "${widget.rawAccel.y.toStringAsFixed(2)} m/s²", AppColors.accentBlue),
                        const SizedBox(width: 6),
                        _buildLiveNumberCard("Accel Z", "${widget.rawAccel.z.toStringAsFixed(2)} m/s²", AppColors.accentBlue),
                        const SizedBox(width: 6),
                        _buildLiveNumberCard("G-Force", "${(widget.rawAccel.length / 9.81).toStringAsFixed(2)} g", AppColors.gnssActive),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Grid Row 2: Raw Gyroscope 3-Axis (deg/s)
                    Row(
                      children: [
                        _buildLiveNumberCard("Gyro Roll", "${(widget.rawGyro.x * 180 / 3.14159).toStringAsFixed(1)}°/s", AppColors.tunnelActive),
                        const SizedBox(width: 6),
                        _buildLiveNumberCard("Gyro Pitch", "${(widget.rawGyro.y * 180 / 3.14159).toStringAsFixed(1)}°/s", AppColors.tunnelActive),
                        const SizedBox(width: 6),
                        _buildLiveNumberCard("Gyro Yaw", "${(widget.rawGyro.z * 180 / 3.14159).toStringAsFixed(1)}°/s", AppColors.tunnelActive),
                        const SizedBox(width: 6),
                        _buildLiveNumberCard("Speed", "${widget.currentSpeedKmph.toStringAsFixed(1)} km/h", AppColors.textPrimary),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Grid Row 3: Orientation Angles & GPS Coordinates
                    Row(
                      children: [
                        _buildLiveNumberCard("Pitch Angle", "${widget.alignmentEngine.pitchDeg.toStringAsFixed(1)}°", AppColors.textSecondary),
                        const SizedBox(width: 6),
                        _buildLiveNumberCard("Roll Angle", "${widget.alignmentEngine.rollDeg.toStringAsFixed(1)}°", AppColors.textSecondary),
                        const SizedBox(width: 6),
                        _buildLiveNumberCard("Yaw Angle", "${widget.alignmentEngine.yawDeg.toStringAsFixed(1)}°", AppColors.textSecondary),
                        const SizedBox(width: 6),
                        _buildLiveNumberCard("Latitude", widget.currentPos.latitude.toStringAsFixed(4), AppColors.accentBlue),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.borderGrey,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLiveNumberCard(String title, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey, width: 0.8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 8, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

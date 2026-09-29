import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/tg_colors.dart';
import '../widgets/tg_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TGColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: TGColors.lightning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bolt,
                        color: TGColors.lightning, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text('ThunderGuard',
                      style: TextStyle(
                          color: TGColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(width: 6),
                  const LiveDot(size: 6),
                  const Spacer(),
                  const Icon(Icons.notifications_outlined,
                      color: TGColors.textMuted, size: 20),
                ],
              ),
            ),

            // ── Radar Map ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TGCard(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: 190,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF080E1C), Color(0xFF0D1F3C)],
                            ),
                          ),
                          child: CustomPaint(
                              painter: _MapPainter(), child: Container()),
                        ),
                        AnimatedBuilder(
                          animation: _scanCtrl,
                          builder: (_, __) =>
                              CustomPaint(painter: _ScanPainter(_scanCtrl.value)),
                        ),
                        // Storm blobs
                        const _Cell(left: 55, top: 45,
                            color: TGColors.severityEmergency, label: 'Patna'),
                        const _Cell(right: 50, top: 85,
                            color: TGColors.severityWarning, label: 'BBSR'),
                        const _Cell(left: 105, bottom: 45,
                            color: TGColors.severityWatch, label: 'Ranchi'),
                        // Corner chip
                        Positioned(
                          top: 8, right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: TGColors.background.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: TGColors.cardBorder),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.radar,
                                    color: TGColors.chartBlue, size: 11),
                                SizedBox(width: 4),
                                Text('Doppler',
                                    style: TextStyle(
                                        color: TGColors.textMuted,
                                        fontSize: 9)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Stats ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                      child: _MiniStat('3', 'Storms',
                          Icons.thunderstorm_outlined,
                          TGColors.severityEmergency)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _MiniStat('87%', 'Max LSPS',
                          Icons.bolt, TGColors.lightning)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _MiniStat('33', 'Radars',
                          Icons.radar, TGColors.chartBlue)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _MiniStat('12', 'Districts',
                          Icons.location_on_outlined,
                          TGColors.severityWarning)),
                ],
              ),
            ),

            // ── Alert Cards ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Text('ACTIVE ALERTS',
                      style: TextStyle(
                          color: TGColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8)),
                  const SizedBox(width: 8),
                  SeverityBadge(
                      label: '3', color: TGColors.severityEmergency),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: const [
                  _AlertRow(
                      district: 'Patna, Bihar',
                      severity: 'EMERGENCY',
                      color: TGColors.severityEmergency,
                      lsps: 87,
                      eta: '18 min'),
                  SizedBox(height: 8),
                  _AlertRow(
                      district: 'Bhubaneswar, Odisha',
                      severity: 'WARNING',
                      color: TGColors.severityWarning,
                      lsps: 64,
                      eta: '42 min'),
                  SizedBox(height: 8),
                  _AlertRow(
                      district: 'Ranchi, Jharkhand',
                      severity: 'WATCH',
                      color: TGColors.severityWatch,
                      lsps: 41,
                      eta: '1h 20m'),
                  SizedBox(height: 12),
                  // Data Sources
                  _SourceRow(icon: Icons.radar, label: 'Doppler (DWR)',
                      status: 'LIVE', color: TGColors.online),
                  SizedBox(height: 6),
                  _SourceRow(icon: Icons.satellite_alt, label: 'INSAT-3DR',
                      status: 'LIVE', color: TGColors.online),
                  SizedBox(height: 6),
                  _SourceRow(icon: Icons.flash_on, label: 'LLDN',
                      status: 'LIVE', color: TGColors.online),
                  SizedBox(height: 6),
                  _SourceRow(icon: Icons.cloud_outlined, label: 'NWP/WRF',
                      status: 'SYNC', color: TGColors.severityWarning),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mini Stat Box ────────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _MiniStat(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return TGCard(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.w800)),
          Text(label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: TGColors.textMuted, fontSize: 9)),
        ],
      ),
    );
  }
}

// ─── Alert Row ────────────────────────────────────────────────────────────────
class _AlertRow extends StatelessWidget {
  final String district;
  final String severity;
  final Color color;
  final int lsps;
  final String eta;
  const _AlertRow({
    required this.district,
    required this.severity,
    required this.color,
    required this.lsps,
    required this.eta,
  });

  @override
  Widget build(BuildContext context) {
    return TGCard(
      borderColor: color.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.bolt, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(district,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: TGColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                Text('LSPS $lsps% · ETA $eta',
                    style: const TextStyle(
                        color: TGColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
          SeverityBadge(label: severity, color: color),
        ],
      ),
    );
  }
}

// ─── Source Row ───────────────────────────────────────────────────────────────
class _SourceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final Color color;
  const _SourceRow(
      {required this.icon,
      required this.label,
      required this.status,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: TGColors.textMuted, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: TGColors.textSecondary, fontSize: 11)),
        ),
        LiveDot(color: color, size: 6),
        const SizedBox(width: 4),
        Text(status,
            style: TextStyle(
                color: color, fontSize: 9, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ─── Storm Cell ───────────────────────────────────────────────────────────────
class _Cell extends StatelessWidget {
  final double? left, right, top, bottom;
  final Color color;
  final String label;
  const _Cell({this.left, this.right, this.top, this.bottom,
      required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left, right: right, top: top, bottom: bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.25),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Icon(Icons.bolt, color: color, size: 12),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 7, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1A2744).withValues(alpha: 0.5)
      ..strokeWidth = 0.7;
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    final blob = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    blob.color = TGColors.severityEmergency.withValues(alpha: 0.2);
    canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.36), 28, blob);
    blob.color = TGColors.severityWarning.withValues(alpha: 0.18);
    canvas.drawCircle(Offset(size.width * 0.70, size.height * 0.52), 24, blob);
    blob.color = TGColors.severityWatch.withValues(alpha: 0.15);
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.72), 20, blob);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ScanPainter extends CustomPainter {
  final double p;
  const _ScanPainter(this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final angle = p * 2 * math.pi - math.pi / 2;
    final sweep = Paint()
      ..style = PaintingStyle.fill
      ..shader = SweepGradient(
        startAngle: angle - 0.7,
        endAngle: angle,
        colors: [Colors.transparent, TGColors.chartBlue.withValues(alpha: 0.1)],
        transform: GradientRotation(angle - 0.7),
      ).createShader(Rect.fromCircle(
          center: center, radius: math.max(size.width, size.height)));
    canvas.drawCircle(
        center, math.max(size.width, size.height), sweep);
    final line = Paint()
      ..color = TGColors.chartBlue.withValues(alpha: 0.4)
      ..strokeWidth = 1.2;
    canvas.drawLine(center,
        Offset(center.dx + math.cos(angle) * size.width,
            center.dy + math.sin(angle) * size.height),
        line);
  }

  @override
  bool shouldRepaint(_ScanPainter o) => o.p != p;
}

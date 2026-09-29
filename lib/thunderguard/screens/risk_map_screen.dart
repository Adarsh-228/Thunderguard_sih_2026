import 'package:flutter/material.dart';
import '../core/tg_colors.dart';
import '../widgets/tg_widgets.dart';

class RiskMapScreen extends StatefulWidget {
  const RiskMapScreen({super.key});
  @override
  State<RiskMapScreen> createState() => _RiskMapScreenState();
}

class _RiskMapScreenState extends State<RiskMapScreen> {
  int _horizonIdx = 0;
  final List<String> _horizons = ['0–30m', '30–60m', '60–90m', '90–180m'];

  final List<_D> _districts = [
    _D('Patna', 'Bihar', 87, TGColors.riskExtreme, 'EMERGENCY'),
    _D('Muzaffarpur', 'Bihar', 72, TGColors.riskHigh, 'WARNING'),
    _D('Bhubaneswar', 'Odisha', 64, TGColors.riskHigh, 'WARNING'),
    _D('Ranchi', 'Jharkhand', 41, TGColors.riskMedium, 'WATCH'),
    _D('Kolkata', 'W. Bengal', 38, TGColors.riskMedium, 'WATCH'),
    _D('Gaya', 'Bihar', 29, TGColors.riskMedium, 'WATCH'),
    _D('Darbhanga', 'Bihar', 18, TGColors.riskLow, 'CLEAR'),
    _D('Jamshedpur', 'Jharkhand', 12, TGColors.riskLow, 'CLEAR'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TGColors.background,
      appBar: AppBar(
        title: const Text('Risk Map'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(children: [
              const LiveDot(size: 6),
              const SizedBox(width: 4),
              const Text('LIVE',
                  style: TextStyle(
                      color: TGColors.online,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizon chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              itemCount: _horizons.length,
              itemBuilder: (_, i) {
                final sel = i == _horizonIdx;
                return GestureDetector(
                  onTap: () => setState(() => _horizonIdx = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: sel
                          ? TGColors.lightning.withValues(alpha: 0.15)
                          : TGColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel
                              ? TGColors.lightning
                              : TGColors.cardBorder),
                    ),
                    child: Text(_horizons[i],
                        style: TextStyle(
                            color: sel
                                ? TGColors.lightning
                                : TGColors.textSecondary,
                            fontSize: 11,
                            fontWeight: sel
                                ? FontWeight.w700
                                : FontWeight.w500)),
                  ),
                );
              },
            ),
          ),

          // Map
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TGCard(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF080E1C), Color(0xFF0C1726)],
                          ),
                        ),
                        child: CustomPaint(
                          painter: _MapMockPainter(_districts),
                          child: Container(),
                        ),
                      ),
                      // Legend
                      Positioned(
                        right: 8, top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TGColors.background.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: TGColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Leg(TGColors.riskExtreme, '>80%'),
                              _Leg(TGColors.riskHigh, '60–80%'),
                              _Leg(TGColors.riskMedium, '30–60%'),
                              _Leg(TGColors.riskLow, '<30%'),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: TGColors.background.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(_horizons[_horizonIdx],
                              style: const TextStyle(
                                  color: TGColors.lightning,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('DISTRICTS',
                    style: TextStyle(
                        color: TGColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8)),
                const Spacer(),
                Text('${_districts.length} monitored',
                    style: const TextStyle(
                        color: TGColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _districts.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _DistrictRow(d: _districts[i], rank: i + 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistrictRow extends StatelessWidget {
  final _D d;
  final int rank;
  const _DistrictRow({required this.d, required this.rank});

  @override
  Widget build(BuildContext context) {
    return TGCard(
      borderColor: d.color.withValues(alpha: 0.25),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Text('#$rank',
              style: TextStyle(
                  color: d.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: TGColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                Text(d.state,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: TGColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SeverityBadge(label: d.severity, color: d.color),
              const SizedBox(height: 2),
              Text('${d.lsps}%',
                  style: TextStyle(
                      color: d.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Leg extends StatelessWidget {
  final Color color;
  final String label;
  const _Leg(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: TGColors.textSecondary, fontSize: 9)),
        ],
      ),
    );
  }
}

class _D {
  final String name, state, severity;
  final int lsps;
  final Color color;
  const _D(this.name, this.state, this.lsps, this.color, this.severity);
}

class _MapMockPainter extends CustomPainter {
  final List<_D> ds;
  const _MapMockPainter(this.ds);

  @override
  void paint(Canvas canvas, Size size) {
    final g = Paint()
      ..color = const Color(0xFF1A2744).withValues(alpha: 0.4)
      ..strokeWidth = 0.7;
    for (double x = 0; x < size.width; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), g);
    }
    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), g);
    }

    final positions = [
      Offset(size.width * 0.35, size.height * 0.28),
      Offset(size.width * 0.38, size.height * 0.22),
      Offset(size.width * 0.64, size.height * 0.55),
      Offset(size.width * 0.42, size.height * 0.55),
      Offset(size.width * 0.70, size.height * 0.68),
      Offset(size.width * 0.37, size.height * 0.40),
      Offset(size.width * 0.30, size.height * 0.24),
      Offset(size.width * 0.50, size.height * 0.62),
    ];

    final bp = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    final dp = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < ds.length && i < positions.length; i++) {
      bp.color = ds[i].color.withValues(alpha: 0.3);
      canvas.drawCircle(positions[i], 22, bp);
      dp.color = ds[i].color;
      canvas.drawCircle(positions[i], 4, dp);

      final tp = TextPainter(
        text: TextSpan(
            text: ds[i].name,
            style: TextStyle(
                color: ds[i].color, fontSize: 7, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 60);
      tp.paint(canvas, positions[i] + Offset(-tp.width / 2, 6));
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

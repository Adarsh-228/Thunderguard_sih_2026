import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/tg_colors.dart';
import '../widgets/tg_widgets.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  final List<FlSpot> _radar = [
    const FlSpot(0, 18), const FlSpot(1, 35), const FlSpot(2, 52),
    const FlSpot(3, 61), const FlSpot(4, 68), const FlSpot(5, 74),
    const FlSpot(6, 71), const FlSpot(7, 63), const FlSpot(8, 58),
  ];
  final List<FlSpot> _flash = [
    const FlSpot(0, 2), const FlSpot(1, 11), const FlSpot(2, 24),
    const FlSpot(3, 33), const FlSpot(4, 41), const FlSpot(5, 55),
    const FlSpot(6, 49), const FlSpot(7, 38), const FlSpot(8, 30),
  ];
  final List<FlSpot> _cape = [
    const FlSpot(0, 800), const FlSpot(1, 1200), const FlSpot(2, 1850),
    const FlSpot(3, 2100), const FlSpot(4, 2250), const FlSpot(5, 2480),
    const FlSpot(6, 2300), const FlSpot(7, 2050), const FlSpot(8, 1800),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TGColors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Radar'),
            Tab(text: 'Lightning'),
            Tab(text: 'Atmosphere'),
          ],
          labelColor: TGColors.lightning,
          unselectedLabelColor: TGColors.textMuted,
          indicatorColor: TGColors.lightning,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ChartTab(
            title: 'Reflectivity (dBZ)',
            spots: _radar,
            color: TGColors.chartBlue,
            maxY: 80,
            yLabel: 'dBZ',
            metrics: const [
              _Metric('74', 'Peak dBZ', TGColors.severityEmergency),
              _Metric('33', 'Nodes', TGColors.chartBlue),
              _Metric('5m', 'Scan interval', TGColors.chartGreen),
            ],
          ),
          _ChartTab(
            title: 'Flash Density (/5 min)',
            spots: _flash,
            color: TGColors.lightning,
            maxY: 65,
            yLabel: 'fl',
            isBar: true,
            metrics: const [
              _Metric('55', 'Peak flash', TGColors.lightning),
              _Metric('342', 'Total today', TGColors.chartOrange),
              _Metric('4', 'Sensors', TGColors.chartGreen),
            ],
          ),
          _AtmTab(cape: _cape),
        ],
      ),
    );
  }
}

// ─── Generic Chart Tab ────────────────────────────────────────────────────────
class _ChartTab extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;
  final Color color;
  final double maxY;
  final String yLabel;
  final bool isBar;
  final List<_Metric> metrics;

  const _ChartTab({
    required this.title,
    required this.spots,
    required this.color,
    required this.maxY,
    required this.yLabel,
    this.isBar = false,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Text(title,
            style: const TextStyle(
                color: TGColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
        const SizedBox(height: 10),
        TGCard(
          child: SizedBox(
            height: 180,
            child: isBar ? _bar(spots, color, maxY) : _line(spots, color, maxY),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: metrics.map((m) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: TGCard(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(m.value,
                        style: TextStyle(
                            color: m.color,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    Text(m.label,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: TGColors.textMuted, fontSize: 9)),
                  ],
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 10),
        // Model accuracy
        TGCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MODEL ACCURACY',
                  style: TextStyle(
                      color: TGColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
              const SizedBox(height: 10),
              _AccRow('POD', 0.78, TGColors.online),
              const SizedBox(height: 6),
              _AccRow('FAR', 0.22, TGColors.online),
              const SizedBox(height: 6),
              _AccRow('CSI', 0.51, TGColors.online),
            ],
          ),
        ),
      ],
    );
  }

  Widget _line(List<FlSpot> spots, Color color, double maxY) {
    return LineChart(LineChartData(
      gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: TGColors.divider, strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      titlesData: _titles(maxY),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withValues(alpha: 0.25), Colors.transparent],
            ),
          ),
        ),
      ],
      minY: 0,
      maxY: maxY,
    ));
  }

  Widget _bar(List<FlSpot> spots, Color color, double maxY) {
    return BarChart(BarChartData(
      gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: TGColors.divider, strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      titlesData: _titles(maxY),
      barGroups: spots.asMap().entries.map((e) => BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.y,
                color: color,
                width: 16,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4)),
              )
            ],
          )).toList(),
      maxY: maxY,
    ));
  }

  FlTitlesData _titles(double maxY) => FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: maxY / 4,
            getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(
                    color: TGColors.textMuted, fontSize: 8)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 18,
            getTitlesWidget: (v, _) => Text('${(v * 30).toInt()}m',
                style: const TextStyle(
                    color: TGColors.textMuted, fontSize: 8)),
          ),
        ),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
      );
}

// ─── Accuracy Row ─────────────────────────────────────────────────────────────
class _AccRow extends StatelessWidget {
  final String label;
  final double val;
  final Color color;
  const _AccRow(this.label, this.val, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 32,
            child: Text(label,
                style: const TextStyle(
                    color: TGColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600))),
        Expanded(
          child: GradientProgressBar(
              value: val,
              colors: [color.withValues(alpha: 0.4), color]),
        ),
        const SizedBox(width: 8),
        Text('${(val * 100).toInt()}%',
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ─── Atmosphere Tab ────────────────────────────────────────────────────────────
class _AtmTab extends StatelessWidget {
  final List<FlSpot> cape;
  const _AtmTab({required this.cape});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('CAPE (J/kg)',
            style: TextStyle(
                color: TGColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
        const SizedBox(height: 10),
        TGCard(
          child: SizedBox(
            height: 180,
            child: LineChart(LineChartData(
              gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: TGColors.divider, strokeWidth: 1)),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 800,
                    getTitlesWidget: (v, _) => Text(
                        '${(v / 1000).toStringAsFixed(1)}k',
                        style: const TextStyle(
                            color: TGColors.textMuted, fontSize: 8)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 18,
                    getTitlesWidget: (v, _) => Text(
                        '${(v * 30).toInt()}m',
                        style: const TextStyle(
                            color: TGColors.textMuted, fontSize: 8)),
                  ),
                ),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: cape,
                  isCurved: true,
                  gradient: const LinearGradient(colors: [
                    TGColors.chartOrange,
                    TGColors.severityEmergency,
                  ]),
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        TGColors.chartOrange.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
              minY: 0,
              maxY: 3000,
              extraLinesData: ExtraLinesData(horizontalLines: [
                HorizontalLine(
                    y: 1000,
                    color: TGColors.severityWatch.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                        show: true,
                        labelResolver: (_) => ' Watch',
                        style: const TextStyle(
                            color: TGColors.severityWatch,
                            fontSize: 8))),
                HorizontalLine(
                    y: 2000,
                    color: TGColors.severityEmergency.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                        show: true,
                        labelResolver: (_) => ' Extreme',
                        style: const TextStyle(
                            color: TGColors.severityEmergency,
                            fontSize: 8))),
              ]),
            )),
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: const [
            _AtmCard('2480 J/kg', 'Peak CAPE', TGColors.chartOrange),
            _AtmCard('18 m/s', 'Wind Shear', TGColors.chartBlue),
            _AtmCard('-85 J/kg', 'CIN', TGColors.chartPurple),
            _AtmCard('72%', 'Rel. Humidity', TGColors.chartGreen),
          ],
        ),
      ],
    );
  }
}

class _AtmCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _AtmCard(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return TGCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
          Text(label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: TGColors.textMuted, fontSize: 9)),
        ],
      ),
    );
  }
}

class _Metric {
  final String value, label;
  final Color color;
  const _Metric(this.value, this.label, this.color);
}

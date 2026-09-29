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
  final List<String> _tabs = ['Radar', 'Lightning', 'Atmosphere', 'Model'];

  // Mock reflectivity data (6h, 5-min interval)
  final List<FlSpot> _reflectivity = [
    const FlSpot(0, 18), const FlSpot(1, 22), const FlSpot(2, 35),
    const FlSpot(3, 48), const FlSpot(4, 52), const FlSpot(5, 61),
    const FlSpot(6, 55), const FlSpot(7, 68), const FlSpot(8, 74),
    const FlSpot(9, 71), const FlSpot(10, 63), const FlSpot(11, 58),
  ];
  final List<FlSpot> _lightningFlash = [
    const FlSpot(0, 2), const FlSpot(1, 5), const FlSpot(2, 11),
    const FlSpot(3, 18), const FlSpot(4, 24), const FlSpot(5, 33),
    const FlSpot(6, 28), const FlSpot(7, 41), const FlSpot(8, 55),
    const FlSpot(9, 49), const FlSpot(10, 38), const FlSpot(11, 30),
  ];
  final List<FlSpot> _cape = [
    const FlSpot(0, 800), const FlSpot(1, 950), const FlSpot(2, 1200),
    const FlSpot(3, 1600), const FlSpot(4, 1850), const FlSpot(5, 2100),
    const FlSpot(6, 1950), const FlSpot(7, 2250), const FlSpot(8, 2480),
    const FlSpot(9, 2300), const FlSpot(10, 2050), const FlSpot(11, 1800),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    _tab.addListener(() => setState(() {}));
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
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
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
          _RadarTab(reflectivity: _reflectivity),
          _LightningTab(flashData: _lightningFlash),
          _AtmosphereTab(cape: _cape),
          _ModelAccuracyTab(),
        ],
      ),
    );
  }
}

// ─── Radar Tab ────────────────────────────────────────────────────────────────
class _RadarTab extends StatelessWidget {
  final List<FlSpot> reflectivity;
  const _RadarTab({required this.reflectivity});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(
          title: 'RADAR REFLECTIVITY (dBZ)',
          subtitle: 'Past 6 hours · Patna radar cell',
          trailing: SeverityBadge(
              label: '74 dBZ PEAK', color: TGColors.severityEmergency),
        ),
        const SizedBox(height: 12),
        TGCard(
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                      color: TGColors.divider, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}',
                          style: const TextStyle(
                              color: TGColors.textMuted, fontSize: 9)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, m) => Text(
                          '${(v * 30).toInt()}m',
                          style: const TextStyle(
                              color: TGColors.textMuted, fontSize: 9)),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: reflectivity,
                    isCurved: true,
                    color: TGColors.chartBlue,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          TGColors.chartBlue.withOpacity(0.3),
                          TGColors.chartBlue.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 80,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Threshold indicator
        TGCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reflectivity Thresholds',
                  style: TextStyle(
                      color: TGColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _ThresholdRow('< 30 dBZ', 'Light rain', TGColors.riskLow, 0.38),
              const SizedBox(height: 8),
              _ThresholdRow(
                  '30–50 dBZ', 'Moderate storms', TGColors.riskMedium, 0.62),
              const SizedBox(height: 8),
              _ThresholdRow('50–65 dBZ', 'Severe', TGColors.riskHigh, 0.82),
              const SizedBox(height: 8),
              _ThresholdRow(
                  '> 65 dBZ', 'Extreme / Hail', TGColors.riskExtreme, 1.0),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _RadarNodeGrid(),
      ],
    );
  }
}

class _ThresholdRow extends StatelessWidget {
  final String range;
  final String label;
  final Color color;
  final double fill;
  const _ThresholdRow(this.range, this.label, this.color, this.fill);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(range,
              style: const TextStyle(
                  color: TGColors.textSecondary, fontSize: 10)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientProgressBar(
                  value: fill, colors: [color.withOpacity(0.5), color]),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(label,
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _RadarNodeGrid extends StatelessWidget {
  final List<Map<String, dynamic>> nodes = const [
    {'name': 'Patna', 'status': true, 'hdop': '92 dBZ'},
    {'name': 'Kolkata', 'status': true, 'hdop': '58 dBZ'},
    {'name': 'Mumbai', 'status': true, 'hdop': '31 dBZ'},
    {'name': 'Chennai', 'status': true, 'hdop': '22 dBZ'},
    {'name': 'Bhopal', 'status': false, 'hdop': '--'},
    {'name': 'Hyderabad', 'status': true, 'hdop': '45 dBZ'},
  ];

  const _RadarNodeGrid();

  @override
  Widget build(BuildContext context) {
    return TGCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'RADAR NODE STATUS'),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: nodes.length,
            itemBuilder: (_, i) {
              final n = nodes[i];
              final online = n['status'] as bool;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TGColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: online
                          ? TGColors.online.withOpacity(0.3)
                          : TGColors.offline.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        LiveDot(
                            color:
                                online ? TGColors.online : TGColors.offline,
                            size: 5),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(n['name'] as String,
                              style: const TextStyle(
                                  color: TGColors.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    Text(n['hdop'] as String,
                        style: TextStyle(
                            color: online
                                ? TGColors.chartBlue
                                : TGColors.textMuted,
                            fontSize: 9)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Lightning Tab ────────────────────────────────────────────────────────────
class _LightningTab extends StatelessWidget {
  final List<FlSpot> flashData;
  const _LightningTab({required this.flashData});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(
          title: 'FLASH DENSITY (flashes/5 min)',
          subtitle: 'LLDN network · Bihar cluster',
        ),
        const SizedBox(height: 12),
        TGCard(
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                      color: TGColors.divider, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}',
                          style: const TextStyle(
                              color: TGColors.textMuted, fontSize: 9)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, m) => Text(
                          '${(v * 30).toInt()}m',
                          style: const TextStyle(
                              color: TGColors.textMuted, fontSize: 9)),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: flashData.asMap().entries.map((e) {
                  final frac = e.value.y / 60.0;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.y,
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            TGColors.lightning.withOpacity(0.4),
                            TGColors.lightning,
                          ],
                        ),
                        width: 14,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                maxY: 65,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Flash stats
        Row(
          children: [
            Expanded(
              child: StatTile(
                value: '55',
                label: 'Peak Flash/5min',
                icon: Icons.bolt,
                color: TGColors.lightning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                value: '342',
                label: 'Total Today',
                icon: Icons.flash_on,
                color: TGColors.chartOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TGCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'LLDN SENSOR STATUS'),
              const SizedBox(height: 12),
              _SensorRow(
                  name: 'Patna Station 1',
                  lat: '25.6°N',
                  lon: '85.1°E',
                  online: true,
                  hz: '1 Hz'),
              const Divider(height: 16, color: TGColors.divider),
              _SensorRow(
                  name: 'Muzaffarpur',
                  lat: '26.1°N',
                  lon: '85.4°E',
                  online: true,
                  hz: '1 Hz'),
              const Divider(height: 16, color: TGColors.divider),
              _SensorRow(
                  name: 'Darbhanga',
                  lat: '26.2°N',
                  lon: '85.9°E',
                  online: false,
                  hz: '--'),
              const Divider(height: 16, color: TGColors.divider),
              _SensorRow(
                  name: 'Gaya Station',
                  lat: '24.7°N',
                  lon: '84.9°E',
                  online: true,
                  hz: '1 Hz'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SensorRow extends StatelessWidget {
  final String name, lat, lon, hz;
  final bool online;
  const _SensorRow(
      {required this.name,
      required this.lat,
      required this.lon,
      required this.online,
      required this.hz});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LiveDot(
            color: online ? TGColors.online : TGColors.offline, size: 7),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: TGColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Text('$lat  $lon',
                  style: const TextStyle(
                      color: TGColors.textMuted, fontSize: 10)),
            ],
          ),
        ),
        Text(hz,
            style: TextStyle(
                color: online ? TGColors.lightning : TGColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ─── Atmosphere Tab ────────────────────────────────────────────────────────────
class _AtmosphereTab extends StatelessWidget {
  final List<FlSpot> cape;
  const _AtmosphereTab({required this.cape});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(
          title: 'CAPE (J/kg)',
          subtitle: 'Convective Available Potential Energy',
        ),
        const SizedBox(height: 12),
        TGCard(
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                      color: TGColors.divider, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}',
                          style: const TextStyle(
                              color: TGColors.textMuted, fontSize: 8)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, m) => Text(
                          '${(v * 30).toInt()}m',
                          style: const TextStyle(
                              color: TGColors.textMuted, fontSize: 9)),
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
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          TGColors.chartOrange.withOpacity(0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 2800,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 1000,
                      color: TGColors.severityWatch.withOpacity(0.6),
                      strokeWidth: 1.5,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (_) => ' Watch',
                          style: const TextStyle(
                              color: TGColors.severityWatch, fontSize: 9)),
                    ),
                    HorizontalLine(
                      y: 2000,
                      color: TGColors.severityEmergency.withOpacity(0.6),
                      strokeWidth: 1.5,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (_) => ' Emergency',
                          style: const TextStyle(
                              color: TGColors.severityEmergency,
                              fontSize: 9)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: const [
            StatTile(
              value: '2480',
              unit: ' J/kg',
              label: 'Peak CAPE',
              icon: Icons.whatshot,
              color: TGColors.chartOrange,
            ),
            StatTile(
              value: '18',
              unit: ' m/s',
              label: '0–6km Wind Shear',
              icon: Icons.air,
              color: TGColors.chartBlue,
            ),
            StatTile(
              value: '-85',
              unit: ' J/kg',
              label: 'CIN (Inhibition)',
              icon: Icons.compress,
              color: TGColors.chartPurple,
            ),
            StatTile(
              value: '72',
              unit: '%',
              label: 'Relative Humidity',
              icon: Icons.water_drop_outlined,
              color: TGColors.chartGreen,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Model Accuracy Tab ───────────────────────────────────────────────────────
class _ModelAccuracyTab extends StatelessWidget {
  const _ModelAccuracyTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(
          title: 'MODEL PERFORMANCE',
          subtitle: 'Validation on IMD 2015–2025 archive',
        ),
        const SizedBox(height: 12),
        // Score cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 1.1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: const [
            _MetricCard(
                label: 'POD',
                value: '0.78',
                target: '>0.75',
                color: TGColors.online),
            _MetricCard(
                label: 'FAR',
                value: '0.22',
                target: '<0.30',
                color: TGColors.online),
            _MetricCard(
                label: 'CSI',
                value: '0.51',
                target: '>0.45',
                color: TGColors.online),
          ],
        ),
        const SizedBox(height: 12),
        TGCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'ACCURACY BY HORIZON'),
              const SizedBox(height: 14),
              _HorizonAccuracyRow('0–30 min', 0.91, TGColors.online),
              const SizedBox(height: 10),
              _HorizonAccuracyRow('30–60 min', 0.82, TGColors.online),
              const SizedBox(height: 10),
              _HorizonAccuracyRow('60–90 min', 0.71, TGColors.severityWarning),
              const SizedBox(height: 10),
              _HorizonAccuracyRow(
                  '90–180 min', 0.58, TGColors.severityWarning),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TGCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'MODEL COMPONENTS'),
              const SizedBox(height: 12),
              _ModelRow('ConvLSTM', 'Radar nowcasting (spatial-temporal)',
                  TGColors.chartBlue, '92ms'),
              const Divider(height: 16, color: TGColors.divider),
              _ModelRow('U-Net Segmentation',
                  'Storm cell boundary detection', TGColors.chartPurple, '38ms'),
              const Divider(height: 16, color: TGColors.divider),
              _ModelRow('XGBoost Ensemble',
                  'Lightning probability scoring', TGColors.lightning, '12ms'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String target;
  final Color color;
  const _MetricCard(
      {required this.label,
      required this.value,
      required this.target,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return TGCard(
      padding: const EdgeInsets.all(12),
      borderColor: color.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: TGColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          Text('Target: $target',
              style: const TextStyle(
                  color: TGColors.textMuted, fontSize: 9)),
        ],
      ),
    );
  }
}

class _HorizonAccuracyRow extends StatelessWidget {
  final String label;
  final double accuracy;
  final Color color;
  const _HorizonAccuracyRow(this.label, this.accuracy, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: const TextStyle(
                  color: TGColors.textSecondary, fontSize: 11)),
        ),
        Expanded(
          child: GradientProgressBar(
            value: accuracy,
            colors: [color.withOpacity(0.5), color],
          ),
        ),
        const SizedBox(width: 10),
        Text('${(accuracy * 100).toInt()}%',
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ModelRow extends StatelessWidget {
  final String name;
  final String desc;
  final Color color;
  final String latency;
  const _ModelRow(this.name, this.desc, this.color, this.latency);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: TGColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Text(desc,
                  style: const TextStyle(
                      color: TGColors.textMuted, fontSize: 10)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(latency,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

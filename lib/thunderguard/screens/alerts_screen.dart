import 'package:flutter/material.dart';
import '../core/tg_colors.dart';
import '../widgets/tg_widgets.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _filter = 'ALL';
  final List<String> _filters = ['ALL', 'EMERGENCY', 'WARNING', 'WATCH'];

  final List<_AlertItem> _alerts = [
    _AlertItem(
      id: 'TG-2026-0042',
      district: 'Patna',
      state: 'Bihar',
      severity: 'EMERGENCY',
      color: TGColors.severityEmergency,
      lsps: 87,
      message:
          'Severe thunderstorm cell detected 45km NW of Patna. Lightning strike probability critical. Immediate evacuation of outdoor workers advised.',
      time: '02:08 AM',
      eta: '18 min',
      icon: Icons.warning_rounded,
      channels: ['SMS', 'App', 'IMD Dashboard'],
      acknowledged: false,
    ),
    _AlertItem(
      id: 'TG-2026-0041',
      district: 'Muzaffarpur',
      state: 'Bihar',
      severity: 'WARNING',
      color: TGColors.severityWarning,
      lsps: 72,
      message:
          'Active storm cell moving SE at 48 km/h. Convective towers identified in INSAT imagery. Prepare district emergency teams.',
      time: '01:52 AM',
      eta: '34 min',
      icon: Icons.thunderstorm,
      channels: ['SMS', 'App'],
      acknowledged: false,
    ),
    _AlertItem(
      id: 'TG-2026-0040',
      district: 'Bhubaneswar',
      state: 'Odisha',
      severity: 'WARNING',
      color: TGColors.severityWarning,
      lsps: 64,
      message:
          'Bay of Bengal moisture surge increasing instability. CAPE values exceeding 2000 J/kg. Storm development likely within 1 hour.',
      time: '01:35 AM',
      eta: '42 min',
      icon: Icons.thunderstorm,
      channels: ['SMS', 'App', 'IMD Dashboard'],
      acknowledged: true,
    ),
    _AlertItem(
      id: 'TG-2026-0039',
      district: 'Ranchi',
      state: 'Jharkhand',
      severity: 'WATCH',
      color: TGColors.severityWatch,
      lsps: 41,
      message:
          'Conditions favorable for thunderstorm development. Monitor LLDN flash density. Coal mine operations: increase vigilance.',
      time: '01:14 AM',
      eta: '1h 20m',
      icon: Icons.visibility,
      channels: ['App'],
      acknowledged: false,
    ),
    _AlertItem(
      id: 'TG-2026-0038',
      district: 'Kolkata',
      state: 'West Bengal',
      severity: 'WATCH',
      color: TGColors.severityWatch,
      lsps: 38,
      message:
          'Weak convective signature detected in radar composite. Probability of isolated lightning activity moderate.',
      time: '00:58 AM',
      eta: '1h 45m',
      icon: Icons.visibility,
      channels: ['App'],
      acknowledged: true,
    ),
  ];

  List<_AlertItem> get _filtered => _filter == 'ALL'
      ? _alerts
      : _alerts.where((a) => a.severity == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TGColors.background,
      appBar: AppBar(
        title: const Text('Alert Feed'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SeverityBadge(
                label:
                    '${_alerts.where((a) => !a.acknowledged).length} NEW',
                color: TGColors.severityEmergency,
                icon: Icons.notifications_active),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filters ──────────────────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = f == _filter;
                final color = f == 'EMERGENCY'
                    ? TGColors.severityEmergency
                    : f == 'WARNING'
                        ? TGColors.severityWarning
                        : f == 'WATCH'
                            ? TGColors.severityWatch
                            : TGColors.lightning;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: active
                          ? color.withOpacity(0.15)
                          : TGColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: active ? color : TGColors.cardBorder),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: active ? color : TGColors.textSecondary,
                        fontSize: 12,
                        fontWeight: active
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Summary Strip ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: TGColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TGColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryChip(
                      count: '1',
                      label: 'EMERGENCY',
                      color: TGColors.severityEmergency),
                  _VertDivider(),
                  _SummaryChip(
                      count: '2',
                      label: 'WARNING',
                      color: TGColors.severityWarning),
                  _VertDivider(),
                  _SummaryChip(
                      count: '2',
                      label: 'WATCH',
                      color: TGColors.severityWatch),
                ],
              ),
            ),
          ),

          // ── Alert List ──────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AlertDetailCard(
                  alert: _filtered[i],
                  onAcknowledge: () => setState(() {
                    _filtered[i].acknowledged = true;
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertDetailCard extends StatelessWidget {
  final _AlertItem alert;
  final VoidCallback onAcknowledge;
  const _AlertDetailCard(
      {required this.alert, required this.onAcknowledge});

  @override
  Widget build(BuildContext context) {
    return TGCard(
      borderColor: alert.acknowledged
          ? TGColors.cardBorder
          : alert.color.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: alert.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: alert.color.withOpacity(0.3)),
                ),
                child: Icon(alert.icon, color: alert.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${alert.district}, ${alert.state}',
                          style: const TextStyle(
                            color: TGColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (!alert.acknowledged)
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: alert.color,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        SeverityBadge(
                            label: alert.severity, color: alert.color),
                        const SizedBox(width: 6),
                        Text(alert.time,
                            style: const TextStyle(
                                color: TGColors.textMuted,
                                fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Message
          Text(
            alert.message,
            style: const TextStyle(
                color: TGColors.textSecondary, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 10),
          // Meta row
          Row(
            children: [
              Icon(Icons.bolt, size: 12, color: TGColors.lightning),
              const SizedBox(width: 3),
              Text('LSPS: ${alert.lsps}%',
                  style: TextStyle(
                      color: TGColors.lightning,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Icon(Icons.timer_outlined,
                  size: 11, color: TGColors.textMuted),
              const SizedBox(width: 3),
              Text('ETA: ${alert.eta}',
                  style: const TextStyle(
                      color: TGColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          GradientProgressBar(
            value: alert.lsps / 100.0,
            colors: [alert.color.withOpacity(0.4), alert.color],
          ),
          const SizedBox(height: 10),
          // Channels + Ack
          Row(
            children: [
              Wrap(
                spacing: 6,
                children: alert.channels
                    .map((c) => _ChannelBadge(label: c))
                    .toList(),
              ),
              const Spacer(),
              if (!alert.acknowledged)
                GestureDetector(
                  onTap: onAcknowledge,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: TGColors.lightning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: TGColors.lightning.withOpacity(0.4)),
                    ),
                    child: const Text('ACK',
                        style: TextStyle(
                            color: TGColors.lightning,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                )
              else
                const Text('✓ Acknowledged',
                    style: TextStyle(
                        color: TGColors.online,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text('ID: ${alert.id}',
              style: const TextStyle(
                  color: TGColors.textMuted, fontSize: 9)),
        ],
      ),
    );
  }
}

class _ChannelBadge extends StatelessWidget {
  final String label;
  const _ChannelBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: TGColors.surfaceElevated,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: TGColors.cardBorder),
      ),
      child: Text(label,
          style: const TextStyle(
              color: TGColors.textMuted, fontSize: 9)),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  const _SummaryChip(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(
                color: TGColors.textMuted,
                fontSize: 9,
                letterSpacing: 0.5)),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 32, color: TGColors.divider);
  }
}

class _AlertItem {
  final String id;
  final String district;
  final String state;
  final String severity;
  final Color color;
  final int lsps;
  final String message;
  final String time;
  final String eta;
  final IconData icon;
  final List<String> channels;
  bool acknowledged;

  _AlertItem({
    required this.id,
    required this.district,
    required this.state,
    required this.severity,
    required this.color,
    required this.lsps,
    required this.message,
    required this.time,
    required this.eta,
    required this.icon,
    required this.channels,
    required this.acknowledged,
  });
}

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

  final List<_A> _alerts = [
    _A('TG-0042', 'Patna, Bihar', 'EMERGENCY',
        TGColors.severityEmergency, 87, '18 min', false),
    _A('TG-0041', 'Muzaffarpur, Bihar', 'WARNING',
        TGColors.severityWarning, 72, '34 min', false),
    _A('TG-0040', 'Bhubaneswar, Odisha', 'WARNING',
        TGColors.severityWarning, 64, '42 min', true),
    _A('TG-0039', 'Ranchi, Jharkhand', 'WATCH',
        TGColors.severityWatch, 41, '1h 20m', false),
    _A('TG-0038', 'Kolkata, W. Bengal', 'WATCH',
        TGColors.severityWatch, 38, '1h 45m', true),
  ];

  List<_A> get _filtered => _filter == 'ALL'
      ? _alerts
      : _alerts.where((a) => a.severity == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final unread = _alerts.where((a) => !a.acked).length;
    return Scaffold(
      backgroundColor: TGColors.background,
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          if (unread > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SeverityBadge(
                  label: '$unread NEW',
                  color: TGColors.severityEmergency,
                  icon: Icons.notifications_active),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: active
                          ? color.withValues(alpha: 0.15)
                          : TGColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: active ? color : TGColors.cardBorder),
                    ),
                    child: Text(f,
                        style: TextStyle(
                            color: active ? color : TGColors.textSecondary,
                            fontSize: 11,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500)),
                  ),
                );
              },
            ),
          ),

          // Summary bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TGCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SummaryChip('1', 'EMERGENCY',
                      TGColors.severityEmergency),
                  Container(
                      width: 1, height: 28, color: TGColors.divider),
                  _SummaryChip('2', 'WARNING',
                      TGColors.severityWarning),
                  Container(
                      width: 1, height: 28, color: TGColors.divider),
                  _SummaryChip('2', 'WATCH', TGColors.severityWatch),
                ],
              ),
            ),
          ),

          // Alert list
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AlertCard(
                  a: _filtered[i],
                  onAck: () => setState(() => _filtered[i].acked = true),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final _A a;
  final VoidCallback onAck;
  const _AlertCard({required this.a, required this.onAck});

  @override
  Widget build(BuildContext context) {
    return TGCard(
      borderColor: a.acked
          ? TGColors.cardBorder
          : a.color.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: a.color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(a.district,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: TGColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
              if (!a.acked)
                Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: a.color)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              SeverityBadge(label: a.severity, color: a.color),
              const SizedBox(width: 8),
              Text('LSPS ${a.lsps}%',
                  style: TextStyle(
                      color: a.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('ETA ${a.eta}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: TGColors.textMuted, fontSize: 10)),
              ),
              if (!a.acked)
                GestureDetector(
                  onTap: onAck,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: TGColors.lightning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: TGColors.lightning.withValues(alpha: 0.3)),
                    ),
                    child: const Text('ACK',
                        style: TextStyle(
                            color: TGColors.lightning,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                )
              else
                const Text('✓ ACK',
                    style: TextStyle(
                        color: TGColors.online,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          GradientProgressBar(
            value: a.lsps / 100.0,
            colors: [a.color.withValues(alpha: 0.4), a.color],
          ),
          const SizedBox(height: 4),
          Text(a.id,
              style: const TextStyle(
                  color: TGColors.textMuted, fontSize: 9)),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String count, label;
  final Color color;
  const _SummaryChip(this.count, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count,
            style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        Text(label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: TGColors.textMuted,
                fontSize: 8,
                letterSpacing: 0.3)),
      ],
    );
  }
}

class _A {
  final String id, district, severity;
  final Color color;
  final int lsps;
  final String eta;
  bool acked;
  _A(this.id, this.district, this.severity, this.color, this.lsps,
      this.eta, this.acked);
}

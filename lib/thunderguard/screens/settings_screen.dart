import 'package:flutter/material.dart';
import '../core/tg_colors.dart';
import '../widgets/tg_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sms = true;
  bool _push = true;
  bool _dash = true;
  bool _emergency = false;
  bool _auto = true;
  double _threshold = 40.0;
  String _role = 'IMD Forecaster';
  String _interval = '5 min';

  static const List<String> _roles = [
    'IMD Forecaster',
    'District Official',
    'Field Worker',
    'Mine Supervisor',
    'Research Analyst',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TGColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('SAVE',
                style: TextStyle(
                    color: TGColors.lightning,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Profile card
          TGCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      TGColors.lightning.withValues(alpha: 0.8),
                      TGColors.chartOrange.withValues(alpha: 0.8),
                    ]),
                  ),
                  child: const Icon(Icons.person,
                      color: TGColors.background, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Adarsh Kumar',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: TGColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                      Text(_role,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: TGColors.textSecondary, fontSize: 11)),
                      Row(children: [
                        const LiveDot(size: 5),
                        const SizedBox(width: 4),
                        const Text('v1.0-beta',
                            style: TextStyle(
                                color: TGColors.textMuted, fontSize: 9)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          _Label('USER ROLE'),
          const SizedBox(height: 6),
          TGCard(
            child: Column(
              children: _roles.map((r) {
                final sel = r == _role;
                return InkWell(
                  onTap: () => setState(() => _role = r),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          sel
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: sel
                              ? TGColors.lightning
                              : TGColors.textMuted,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(r,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: sel
                                      ? TGColors.textPrimary
                                      : TGColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: sel
                                      ? FontWeight.w600
                                      : FontWeight.w400)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),
          _Label('ALERT CHANNELS'),
          const SizedBox(height: 6),
          TGCard(
            child: Column(children: [
              _Toggle(Icons.sms_outlined, 'SMS', _sms,
                  TGColors.chartGreen, (v) => setState(() => _sms = v)),
              const Divider(height: 1, color: TGColors.divider),
              _Toggle(Icons.notifications_outlined, 'Push', _push,
                  TGColors.chartBlue, (v) => setState(() => _push = v)),
              const Divider(height: 1, color: TGColors.divider),
              _Toggle(Icons.dashboard_outlined, 'Dashboard', _dash,
                  TGColors.chartPurple, (v) => setState(() => _dash = v)),
            ]),
          ),

          const SizedBox(height: 14),
          _Label('LSPS THRESHOLD'),
          const SizedBox(height: 6),
          TGCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune,
                        color: TGColors.textMuted, size: 14),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Min. Strike Probability',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: TGColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text('${_threshold.toInt()}%',
                        style: const TextStyle(
                            color: TGColors.lightning,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: TGColors.lightning,
                    inactiveTrackColor: TGColors.divider,
                    thumbColor: TGColors.lightning,
                    overlayColor:
                        TGColors.lightning.withValues(alpha: 0.1),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: _threshold,
                    min: 10,
                    max: 90,
                    divisions: 16,
                    onChanged: (v) => setState(() => _threshold = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['Any', 'Watch', 'Warning', 'Emergency']
                      .map((t) => Text(t,
                          style: const TextStyle(
                              color: TGColors.textMuted,
                              fontSize: 8)))
                      .toList(),
                ),
                const Divider(height: 16, color: TGColors.divider),
                _Toggle(Icons.emergency_outlined, 'Emergency Only',
                    _emergency, TGColors.severityEmergency,
                    (v) => setState(() => _emergency = v)),
              ],
            ),
          ),

          const SizedBox(height: 14),
          _Label('REFRESH'),
          const SizedBox(height: 6),
          TGCard(
            child: Column(children: [
              _Toggle(Icons.autorenew, 'Auto-Refresh', _auto,
                  TGColors.online, (v) => setState(() => _auto = v)),
              const Divider(height: 1, color: TGColors.divider),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  const Icon(Icons.timer_outlined,
                      color: TGColors.textMuted, size: 14),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Interval',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: TGColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                  DropdownButton<String>(
                    value: _interval,
                    dropdownColor: TGColors.surfaceElevated,
                    style: const TextStyle(
                        color: TGColors.lightning,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                    underline: const SizedBox(),
                    items: ['1 min', '5 min', '10 min', '30 min']
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _interval = v!),
                  ),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 14),
          _Label('SYSTEM INFO'),
          const SizedBox(height: 6),
          TGCard(
            child: Column(children: [
              _Info('Problem ID', 'SIH26072'),
              _Info('Team', 'Debuggers_26'),
              _Info('Theme', 'Disaster Mgmt'),
              _Info('ML Stack', 'PyTorch · XGBoost'),
              _Info('Backend', 'FastAPI · PostGIS'),
              _Info('Version', 'v1.0.0-beta'),
            ]),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(text,
            style: const TextStyle(
                color: TGColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0)),
      );
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;
  const _Toggle(this.icon, this.label, this.value, this.color, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: TGColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: color,
          activeTrackColor: color.withValues(alpha: 0.25),
          inactiveTrackColor: TGColors.divider,
          inactiveThumbColor: TGColors.textMuted,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ]),
    );
  }
}

class _Info extends StatelessWidget {
  final String label, value;
  const _Info(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        Expanded(
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: TGColors.textSecondary, fontSize: 11)),
        ),
        const SizedBox(width: 8),
        Text(value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: TGColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

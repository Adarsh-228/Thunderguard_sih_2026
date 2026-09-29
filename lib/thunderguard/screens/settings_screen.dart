import 'package:flutter/material.dart';
import '../core/tg_colors.dart';
import '../widgets/tg_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _smsAlerts = true;
  bool _pushAlerts = true;
  bool _dashboardAlerts = true;
  bool _emergencyOnly = false;
  bool _autoRefresh = true;
  double _lspsThreshold = 40.0;
  String _role = 'IMD Forecaster';
  String _updateInterval = '5 min';

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
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile ──────────────────────────────────────────────────────
          TGCard(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        TGColors.lightning.withOpacity(0.8),
                        TGColors.chartOrange.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: const Icon(Icons.person,
                      color: TGColors.background, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Adarsh Kumar',
                          style: TextStyle(
                              color: TGColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(_role,
                          style: const TextStyle(
                              color: TGColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const LiveDot(size: 6),
                          const SizedBox(width: 5),
                          const Text('ThunderGuard v1.0-beta',
                              style: TextStyle(
                                  color: TGColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: TGColors.textMuted, size: 18),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Role ─────────────────────────────────────────────────────────
          const _SectionLabel(label: 'USER ROLE'),
          const SizedBox(height: 8),
          TGCard(
            child: Column(
              children: [
                'IMD Forecaster',
                'District Official',
                'Field Worker',
                'Mine Supervisor',
                'Research Analyst',
              ].map((r) {
                final selected = r == _role;
                return GestureDetector(
                  onTap: () => setState(() => _role = r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 11, horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: TGColors.divider, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? TGColors.lightning
                              : TGColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(r,
                            style: TextStyle(
                                color: selected
                                    ? TGColors.textPrimary
                                    : TGColors.textSecondary,
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── Alert Channels ────────────────────────────────────────────────
          const _SectionLabel(label: 'ALERT CHANNELS'),
          const SizedBox(height: 8),
          TGCard(
            child: Column(
              children: [
                _ToggleRow(
                  icon: Icons.sms_outlined,
                  label: 'SMS Gateway',
                  subtitle: 'via IMD telecom network',
                  value: _smsAlerts,
                  color: TGColors.chartGreen,
                  onChanged: (v) => setState(() => _smsAlerts = v),
                ),
                const Divider(height: 1, color: TGColors.divider),
                _ToggleRow(
                  icon: Icons.notifications_outlined,
                  label: 'Push Notifications',
                  subtitle: 'Mobile app real-time alerts',
                  value: _pushAlerts,
                  color: TGColors.chartBlue,
                  onChanged: (v) => setState(() => _pushAlerts = v),
                ),
                const Divider(height: 1, color: TGColors.divider),
                _ToggleRow(
                  icon: Icons.dashboard_outlined,
                  label: 'IMD Dashboard',
                  subtitle: 'Forecaster web interface',
                  value: _dashboardAlerts,
                  color: TGColors.chartPurple,
                  onChanged: (v) =>
                      setState(() => _dashboardAlerts = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Alert Thresholds ──────────────────────────────────────────────
          const _SectionLabel(label: 'ALERT THRESHOLDS'),
          const SizedBox(height: 8),
          TGCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune,
                        color: TGColors.textMuted, size: 16),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Minimum LSPS Threshold',
                              style: TextStyle(
                                  color: TGColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text(
                              'Alert fires when Lightning Strike Probability ≥ threshold',
                              style: TextStyle(
                                  color: TGColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    Text(
                      '${_lspsThreshold.toInt()}%',
                      style: const TextStyle(
                          color: TGColors.lightning,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: TGColors.lightning,
                    inactiveTrackColor: TGColors.divider,
                    thumbColor: TGColors.lightning,
                    overlayColor: TGColors.lightning.withOpacity(0.12),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _lspsThreshold,
                    min: 10,
                    max: 90,
                    divisions: 16,
                    onChanged: (v) =>
                        setState(() => _lspsThreshold = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _thresholdLabel('10%', 'Any'),
                    _thresholdLabel('40%', 'Watch'),
                    _thresholdLabel('60%', 'Warning'),
                    _thresholdLabel('80%', 'Emergency'),
                  ],
                ),
                const Divider(height: 20, color: TGColors.divider),
                _ToggleRow(
                  icon: Icons.emergency_outlined,
                  label: 'Emergency Only Mode',
                  subtitle: 'Only notify for EMERGENCY severity',
                  value: _emergencyOnly,
                  color: TGColors.severityEmergency,
                  onChanged: (v) =>
                      setState(() => _emergencyOnly = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Data Refresh ──────────────────────────────────────────────────
          const _SectionLabel(label: 'DATA REFRESH'),
          const SizedBox(height: 8),
          TGCard(
            child: Column(
              children: [
                _ToggleRow(
                  icon: Icons.autorenew,
                  label: 'Auto-Refresh',
                  subtitle: 'Pull latest radar & model data',
                  value: _autoRefresh,
                  color: TGColors.online,
                  onChanged: (v) =>
                      setState(() => _autoRefresh = v),
                ),
                const Divider(height: 1, color: TGColors.divider),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: TGColors.textMuted, size: 16),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('Update Interval',
                            style: TextStyle(
                                color: TGColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                      DropdownButton<String>(
                        value: _updateInterval,
                        dropdownColor: TGColors.surfaceElevated,
                        style: const TextStyle(
                            color: TGColors.lightning,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                        underline: const SizedBox(),
                        items: ['1 min', '5 min', '10 min', '30 min']
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _updateInterval = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── System Info ───────────────────────────────────────────────────
          const _SectionLabel(label: 'SYSTEM'),
          const SizedBox(height: 8),
          TGCard(
            child: Column(
              children: [
                _InfoRow(label: 'Problem Statement ID', value: 'SIH26072'),
                const Divider(height: 1, color: TGColors.divider),
                _InfoRow(label: 'Team', value: 'Debuggers_26'),
                const Divider(height: 1, color: TGColors.divider),
                _InfoRow(label: 'Theme', value: 'Disaster Management'),
                const Divider(height: 1, color: TGColors.divider),
                _InfoRow(
                    label: 'Model Inference', value: 'PyTorch · XGBoost'),
                const Divider(height: 1, color: TGColors.divider),
                _InfoRow(label: 'API Backend', value: 'FastAPI · PostGIS'),
                const Divider(height: 1, color: TGColors.divider),
                _InfoRow(label: 'Radar Integration', value: 'IMD DWR · HDF5'),
                const Divider(height: 1, color: TGColors.divider),
                _InfoRow(label: 'App Version', value: 'v1.0.0-beta'),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label,
        style: const TextStyle(
          color: TGColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: TGColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        color: TGColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.25),
            inactiveTrackColor: TGColors.divider,
            inactiveThumbColor: TGColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: TGColors.textSecondary, fontSize: 12)),
          ),
          Text(value,
              style: const TextStyle(
                  color: TGColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

Widget _thresholdLabel(String value, String label) {
  return Column(
    children: [
      Text(value,
          style: const TextStyle(
              color: TGColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600)),
      Text(label,
          style: const TextStyle(
              color: TGColors.textMuted, fontSize: 8)),
    ],
  );
}

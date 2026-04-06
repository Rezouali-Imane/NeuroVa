import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool darkTheme = true;
  bool haptic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _section('Preferences'),
          _card(
            child: Column(
              children: [
                _switchTile('Notifications', notifications, (v) => setState(() => notifications = v)),
                _divider(),
                _switchTile('Dark Theme', darkTheme, (v) => setState(() => darkTheme = v)),
                _divider(),
                _switchTile('Haptic Feedback', haptic, (v) => setState(() => haptic = v)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _section('General'),
          _card(
            child: Column(
              children: [
                _menuTile('Language', 'English (US)'),
                _divider(),
                _menuTile('Privacy', 'Data & permissions'),
                _divider(),
                _menuTile('Help & FAQ', 'Get support'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => context.go('/profile'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2A2440),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Back To Profile'),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Syne',
            color: Colors.white.withOpacity(0.35),
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      );

  Widget _card({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1628),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2440)),
        ),
        child: child,
      );

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Syne',
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFFB284BE),
      ),
    );
  }

  Widget _menuTile(String title, String subtitle) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Syne',
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.38), fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {},
    );
  }

  Widget _divider() => Container(
        margin: const EdgeInsets.only(left: 16, right: 16),
        height: 1,
        color: const Color(0xFF2A2440),
      );
}

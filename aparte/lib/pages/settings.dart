import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const Settings({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  Future<void> deleteAccountDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deleted (demo only)')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTheme(bool value) async {
    setState(() {
      isDarkMode = value;
    });
    widget.onThemeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('General'),
          _settingsTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            trailing: Switch(
              value: isDarkMode,
              onChanged: _updateTheme,
              activeColor: Colors.blueAccent,
            ),
          ),
          const Divider(),
          _sectionTitle('Account'),
          _settingsTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            iconColor: Colors.redAccent,
            onTap: deleteAccountDialog,
          ),
          const Divider(),
          _sectionTitle('About'),
          _settingsTile(
            icon: Icons.info_outline,
            title: 'About the App',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Aparte Hotels',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.hotel, color: Colors.blue),
              children: [
                const Text(
                  'Aparte is a hotel booking app that helps users discover, explore, and book hotels easily.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.blueAccent),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
      onTap: onTap,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 12, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

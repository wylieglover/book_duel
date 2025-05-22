// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/session_service.dart';
import '../../../../core/theme/theme_provider.dart';
import '../widgets/feedback_widget.dart';
import '../widgets/privacy_policy_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications') ?? false;
    final info = await PackageInfo.fromPlatform();
    _version = '${info.version}+${info.buildNumber} (web build)';
    setState(() {});
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() => _notificationsEnabled = value);
    // TODO: hook into your notification logic
  }

  Future<void> _inviteFriend() async {
    await SharePlus.instance.share(
      ShareParams(
        text: 'Join me on Book Duel! Read, challenge friends, and track your progress: https://bookduel.app',
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset App'),
        content: const Text('Are you sure you want to clear all local data?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await SessionService().leaveSession();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Local data cleared')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
         backgroundColor: theme.currentTheme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        // custom black back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: theme.currentTheme.appBarTheme.titleTextStyle,
        ),
      ),
      body: ListView(
        children: [
          // Dark Mode Toggle
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SwitchListTile(
              secondary: const Icon(Icons.brightness_6),
              title: const Text('Dark Mode'),
              value: theme.isDarkMode,
              onChanged: theme.toggleTheme,
            ),
          ),

          // Notifications Toggle
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
          ),

          const Divider(),

          // Invite a Friend
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Invite a Friend'),
              onTap: _inviteFriend,
            ),
          ),

          // Send Feedback (bottom sheet)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Send Feedback'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const FeedbackWidget(),
                );
              },
            ),
          ),

          // Privacy Policy (bottom sheet)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const PrivacyPolicyWidget(),
                );
              },
            ),
          ),

          const Divider(),

          // Reset Local Data
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset Local Data'),
              onTap: _confirmReset,
            ),
          ),
          
          const Divider(),

          // App Version
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: Text(_version),
          ),
        ],
      ),
    );
  }
}

// favfeedr_flutter/lib/ui/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:favfeedr_flutter/services/subscription_service.dart';
import 'package:favfeedr_flutter/services/settings_service.dart'; // New import
import 'package:favfeedr_flutter/ui/manage_subscriptions_screen.dart'; // Import ManageSubscriptionsScreen
import 'package:favfeedr_flutter/ui/manage_groups_screen.dart';


class SettingsScreen extends StatefulWidget {
  final Function toggleThemeMode;
  final ThemeMode themeMode;
  final SubscriptionService subscriptionService; // New
  final Function onSubscriptionsChanged; // New
  final SettingsService settingsService; // NEW

  const SettingsScreen({
    super.key,
    required this.toggleThemeMode,
    required this.themeMode,
    required this.subscriptionService, // New
    required this.onSubscriptionsChanged, // New
    required this.settingsService, // NEW
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Add state for slider value
  late int _maxItemsPerChannel;
  late String _videoLayoutMode; // New state variable

  @override
  void initState() {
    super.initState();
    _maxItemsPerChannel = 8; // Initialize with a default value
    _videoLayoutMode = SettingsService.defaultVideoLayoutMode; // Initialize with default
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _maxItemsPerChannel = await widget.settingsService.getMaxItemsPerChannel();
    _videoLayoutMode = await widget.settingsService.getVideoLayoutMode(); // Load new setting
    setState(() {}); // Rebuild UI with loaded settings
  }

  void _setMaxItemsPerChannel(int value) async {
    await widget.settingsService.setMaxItemsPerChannel(value);
    setState(() {
      _maxItemsPerChannel = value;
    });
    // Trigger data reload on HomeScreen to apply new setting
    widget.onSubscriptionsChanged();
  }

  void _setVideoLayoutMode(String? value) async {
    if (value != null) {
      await widget.settingsService.setVideoLayoutMode(value);
      setState(() {
        _videoLayoutMode = value;
      });
      widget.onSubscriptionsChanged(); // Trigger data reload on HomeScreen
    }
  }

  void _manageSubscriptions() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManageSubscriptionsScreen(
          subscriptionService: widget.subscriptionService,
          onSubscriptionsChanged: widget.onSubscriptionsChanged,
        ),
      ),
    );
  }

  void _manageGroups() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManageGroupsScreen(
          subscriptionService: widget.subscriptionService,
        ),
      ),
    );
  }

  void _clearSubscriptions() {
    widget.subscriptionService.clearChannels();
    widget.onSubscriptionsChanged(); // Notify HomeScreen to reload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All subscriptions cleared.')),
    );
  }

  void _exportSubscriptions() async {
    final success = await widget.subscriptionService.exportSubscriptionsToJson();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscriptions exported successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export cancelled or failed.')),
      );
    }
  }

  void _importSubscriptions() async {
    final success = await widget.subscriptionService.importSubscriptionsFromJson();
    if (success) {
      widget.onSubscriptionsChanged(); // Reload HomeScreen data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscriptions imported successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import cancelled or failed.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: widget.themeMode == ThemeMode.dark,
            onChanged: (bool value) {
              widget.toggleThemeMode();
            },
          ),
          ListTile(
            leading: const Icon(Icons.subscriptions),
            title: const Text('Manage Subscriptions'),
            onTap: _manageSubscriptions,
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Manage Groups'),
            onTap: _manageGroups,
          ),
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Clear All Subscriptions'),
            onTap: _clearSubscriptions,
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Subscriptions (JSON)'),
            onTap: _exportSubscriptions,
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import Subscriptions (JSON)'),
            onTap: _importSubscriptions,
          ),
          // New Slider for Max Items Per Channel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Max Items Per Channel: $_maxItemsPerChannel',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _maxItemsPerChannel.toDouble(),
                  min: 1.0,
                  max: 20.0, // Arbitrary max value, can be adjusted
                  divisions: 19, // max - min
                  label: _maxItemsPerChannel.round().toString(),
                  onChanged: (double value) {
                    _setMaxItemsPerChannel(value.round());
                  },
                ),
              ],
            ),
          ),
          // New section for Video Layout Mode
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video Layout',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                RadioListTile<String>(
                  title: const Text('List View'),
                  value: 'list',
                  groupValue: _videoLayoutMode,
                  onChanged: _setVideoLayoutMode,
                ),
                RadioListTile<String>(
                  title: const Text('Grid View'),
                  value: 'grid',
                  groupValue: _videoLayoutMode,
                  onChanged: _setVideoLayoutMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

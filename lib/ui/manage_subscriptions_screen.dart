// favfeedr_flutter/lib/ui/manage_subscriptions_screen.dart
import 'package:flutter/material.dart';
import 'package:favfeedr_flutter/models/channel.dart';
import 'package:favfeedr_flutter/services/subscription_service.dart';

class ManageSubscriptionsScreen extends StatefulWidget {
  final SubscriptionService subscriptionService;
  final Function onSubscriptionsChanged; // Callback to notify HomeScreen

  const ManageSubscriptionsScreen({
    super.key,
    required this.subscriptionService,
    required this.onSubscriptionsChanged,
  });

  @override
  State<ManageSubscriptionsScreen> createState() => _ManageSubscriptionsScreenState();
}

class _ManageSubscriptionsScreenState extends State<ManageSubscriptionsScreen> {
  late List<Channel> _channels;
  List<String> _groups = [];

  @override
  void initState() {
    super.initState();
    _channels = widget.subscriptionService.channels;
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await widget.subscriptionService.getGroups();
    setState(() {
      _groups = groups;
    });
  }

  void _removeChannel(String channelId) {
    setState(() {
      widget.subscriptionService.removeChannel(channelId);
      _channels = widget.subscriptionService.channels;
      widget.onSubscriptionsChanged(); // Notify HomeScreen to reload
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Channel removed.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
    );
  }

  void _updateChannelGroup(Channel channel, String? group) {
    final updatedChannel = Channel(
      id: channel.id,
      name: channel.name,
      group: group,
      lastSeenPostDate: channel.lastSeenPostDate,
      newVideoIds: channel.newVideoIds,
    );
    widget.subscriptionService.removeChannel(channel.id);
    widget.subscriptionService.addChannel(updatedChannel, group: group);
    setState(() {
      _channels = widget.subscriptionService.channels;
    });
    widget.onSubscriptionsChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subscriptions'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: _channels.isEmpty
          ? Center(child: Text('No subscriptions found.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))))
          : ListView.separated(
              itemCount: _channels.length,
              separatorBuilder: (context, index) => Divider(color: Theme.of(context).dividerColor, height: 1),
              itemBuilder: (context, index) {
                final channel = _channels[index];
                return ListTile(
                  tileColor: Theme.of(context).cardColor,
                  title: Text(channel.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(channel.id, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: channel.group,
                        hint: const Text('No Group'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('No Group'),
                          ),
                          ..._groups.map((group) {
                            return DropdownMenuItem<String>(
                              value: group,
                              child: Text(group),
                            );
                          }).toList(),
                        ],
                        onChanged: (group) {
                          _updateChannelGroup(channel, group);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
                        onPressed: () => _removeChannel(channel.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

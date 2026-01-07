// favfeedr_flutter/lib/ui/channel_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:favfeedr_flutter/models/channel.dart';

class ChannelSelectionScreen extends StatefulWidget {
  final List<Channel> channelsFromCsv;
  final List<Channel> alreadySubscribedChannels;

  const ChannelSelectionScreen({
    super.key,
    required this.channelsFromCsv,
    required this.alreadySubscribedChannels,
  });

  @override
  State<ChannelSelectionScreen> createState() => _ChannelSelectionScreenState();
}

class _ChannelSelectionScreenState extends State<ChannelSelectionScreen> {
  late Map<String, bool> _selectedChannels;
  late Set<String> _alreadySubscribedIds;
  final TextEditingController _searchController = TextEditingController();
  List<Channel> _filteredChannels = [];

  @override
  void initState() {
    super.initState();
    _alreadySubscribedIds = widget.alreadySubscribedChannels.map((c) => c.id).toSet();
    _selectedChannels = {
      for (var channel in widget.channelsFromCsv)
        channel.id: !_alreadySubscribedIds.contains(channel.id),
    };
    _filteredChannels = widget.channelsFromCsv; // Initialize with all channels

    _searchController.addListener(_filterChannels);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterChannels);
    _searchController.dispose();
    super.dispose();
  }

  void _filterChannels() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredChannels = widget.channelsFromCsv.where((channel) {
        return channel.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _selectAll() {
    setState(() {
      for (var channel in _filteredChannels) { // Apply to filtered channels
        if (!_alreadySubscribedIds.contains(channel.id)) {
          _selectedChannels[channel.id] = true;
        }
      }
    });
  }

  void _deselectAll() {
    setState(() {
      for (var channel in _filteredChannels) { // Apply to filtered channels
        _selectedChannels[channel.id] = false;
      }
    });
  }

  void _importSelected() {
    final List<Channel> channelsToImport = [];
    for (var channel in widget.channelsFromCsv) { // Iterate all channels to check selection
      if (_selectedChannels[channel.id] == true && !_alreadySubscribedIds.contains(channel.id)) {
        channelsToImport.add(channel);
      }
    }
    Navigator.of(context).pop(channelsToImport);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Channels to Import'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Use theme color
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor, // Use theme color
        elevation: Theme.of(context).appBarTheme.elevation, // Use theme elevation
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 16), // Increased height for padding
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search channels...',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                border: InputBorder.none, // Removed outline border for a cleaner look
                filled: true,
                fillColor: Theme.of(context).cardColor, // Use theme card color
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Use theme color
              cursorColor: Theme.of(context).hintColor,
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _selectAll,
            icon: const Icon(Icons.select_all),
            label: const Text('Select All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 8), // Add some spacing
          ElevatedButton.icon(
            onPressed: _deselectAll,
            icon: const Icon(Icons.deselect),
            label: const Text('Deselect All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 8), // Add some spacing
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredChannels.length, // Use filtered channels
        itemBuilder: (context, index) {
          final channel = _filteredChannels[index]; // Use filtered channels
          final isSubscribed = _alreadySubscribedIds.contains(channel.id);
          return CheckboxListTile(
            tileColor: Theme.of(context).cardColor, // Use theme card color
            title: Text(channel.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)), // Use theme color
            subtitle: isSubscribed ? Text('Already subscribed', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))) : null,
            value: _selectedChannels[channel.id],
            onChanged: isSubscribed
                ? null
                : (bool? value) {
                    setState(() {
                      _selectedChannels[channel.id] = value ?? false;
                    });
                  },
            activeColor: Theme.of(context).hintColor,
            checkColor: Theme.of(context).colorScheme.onPrimary, // Ensure checkmark is visible
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importSelected,
        label: const Text('Import Selected'),
        icon: const Icon(Icons.check),
        backgroundColor: Theme.of(context).primaryColor, // Use theme primary color
        foregroundColor: Theme.of(context).colorScheme.onPrimary, // Use theme onPrimary color
      ),
    );
  }
}

// favfeedr_flutter/lib/ui/home_screen.dart
import 'package:favfeedr_flutter/ui/channel_selection_screen.dart';
import 'package:favfeedr_flutter/ui/manage_subscriptions_screen.dart'; // Import ManageSubscriptionsScreen
import 'package:flutter/material.dart';
import 'package:favfeedr_flutter/models/channel.dart';
import 'package:favfeedr_flutter/models/video_item.dart';
import 'package:favfeedr_flutter/services/rss_service.dart';
import 'package:favfeedr_flutter/services/settings_service.dart'; // New import
import 'package:favfeedr_flutter/services/subscription_service.dart';
import 'package:favfeedr_flutter/ui/about_screen.dart';
import 'package:favfeedr_flutter/ui/settings_screen.dart';
import 'package:favfeedr_flutter/ui/widgets/channel_header.dart';
import 'package:favfeedr_flutter/ui/widgets/video_list_item.dart';
import 'package:favfeedr_flutter/ui/widgets/video_grid_item.dart'; // New import

class HomeScreen extends StatefulWidget {
  final SubscriptionService subscriptionService;
  final RssService rssService;
  final Function toggleThemeMode; // New callback
  final ThemeMode themeMode;
  final SettingsService settingsService; // NEW

  const HomeScreen({
    super.key,
    required this.subscriptionService,
    required this.rssService,
    required this.toggleThemeMode, // Accept the callback
    required this.themeMode,
    required this.settingsService, // NEW
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Channel> _channels = [];
  Map<String, List<Channel>> _groupedChannels = {};
  Map<String, List<VideoItem>> _allVideos = {};
  Map<String, bool> _channelLoadingStatus = {};
  late String _videoLayoutMode; // New state variable

  @override
  void initState() {
    super.initState();
    _loadSettingsAndData(); // New method to load both settings and data
  }

  Future<void> _loadSettingsAndData() async {
    _videoLayoutMode = await widget.settingsService.getVideoLayoutMode(); // Load layout setting
    await _loadData(); // Call existing data loading logic
  }

  Future<void> _loadData() async {
    setState(() {
      _channelLoadingStatus.clear(); // Clear previous status
    });

    try {
      await widget.subscriptionService.loadChannels();
      _channels = widget.subscriptionService.channels;

      // Group channels
      _groupedChannels = {};
      for (var channel in _channels) {
        final group = channel.group ?? 'Uncategorized';
        if (!_groupedChannels.containsKey(group)) {
          _groupedChannels[group] = [];
        }
        _groupedChannels[group]!.add(channel);
      }

      if (_channels.isEmpty) {
        setState(() {}); // Empty setState to trigger rebuild if needed
        return;
      }

      // Initialize loading status for all channels
      _channels.forEach((channel) {
        _channelLoadingStatus[channel.id] = true;
      });

      // Fetch videos concurrently and update channel.newVideoIds
      Map<String, List<VideoItem>> fetchedVideos = {};
      await Future.wait(_channels.map((channel) async {
        try {
          final result = await widget.rssService.fetchVideosForChannel(channel);
          final List<VideoItem> videos = result['videos'];
          final List<String> newVideoIds = result['newVideoIds'];

          // Update the channel object directly with newVideoIds
          channel.newVideoIds = newVideoIds;
          fetchedVideos[channel.id] = videos;

        } catch (e) {
          print('Error fetching videos for ${channel.name}: $e');
        }
      }));

      // After fetching all videos, save the updated channels (with newVideoIds)
      await widget.subscriptionService.saveChannels();

      setState(() {
        _allVideos = fetchedVideos;
      });
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _importSubscriptions() async {
    // No longer using _isLoading or _errorMessage for global state
    setState(() {}); // Trigger a rebuild to reflect potential changes
    try {
      final List<Channel> channelsFromCsv = await widget.subscriptionService.parseChannelsFromCsv();
      if (channelsFromCsv.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No channels found in the selected file.')),
        );
        return;
      }

      // Navigate to selection screen
      final List<Channel>? channelsToImport = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChannelSelectionScreen(
            channelsFromCsv: channelsFromCsv,
            alreadySubscribedChannels: _channels,
          ),
        ),
      );

      if (channelsToImport != null && channelsToImport.isNotEmpty) {
        for (var channel in channelsToImport) {
          widget.subscriptionService.addChannel(channel);
        }
        await _loadSettingsAndData(); // Reload all data and settings after import
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${channelsToImport.length} new channels.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing: $e')),
      );
    } finally {
      // _isLoading and _errorMessage are no longer global state variables
      // Rebuild to reflect any changes if necessary, e.g., if new channels were added but data failed to load
      setState(() {});
    }
  }

  void _clearSubscriptions() {
    widget.subscriptionService.clearChannels();
    setState(() {
      _channels = [];
      _allVideos = {};
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All subscriptions cleared.')),
    );
  }

  // Callback to mark a video as seen
  void _markVideoAsSeen(String videoId, String channelId) {
    setState(() {
      final channel = _channels.firstWhere((c) => c.id == channelId);
      if (channel.newVideoIds.contains(videoId)) {
        channel.newVideoIds.remove(videoId);
        widget.subscriptionService.saveChannels(); // Save updated channel state
      }
      // If no more new videos, update lastSeenPostDate
      if (channel.newVideoIds.isEmpty && _allVideos.containsKey(channelId)) {
        final List<VideoItem> channelVideos = _allVideos[channelId]!;
        if (channelVideos.isNotEmpty) {
          final latestVideoDate = channelVideos.map((v) => v.publishedDate).reduce((a, b) => a.isAfter(b) ? a : b);
          channel.lastSeenPostDate = latestVideoDate;
          widget.subscriptionService.saveChannels();
        }
      }
    });
  }

  void _markAllChannelVideosAsSeen(String channelId) {
    setState(() {
      final channel = _channels.firstWhere((c) => c.id == channelId);
      if (channel.newVideoIds.isNotEmpty) {
        channel.newVideoIds.clear();
        widget.subscriptionService.saveChannels();
      }
      // If no more new videos, update lastSeenPostDate
      if (_allVideos.containsKey(channelId) && _allVideos[channelId]!.isNotEmpty) {
        final List<VideoItem> channelVideos = _allVideos[channelId]!;
        final latestVideoDate = channelVideos.map((v) => v.publishedDate).reduce((a, b) => a.isAfter(b) ? a : b);
        channel.lastSeenPostDate = latestVideoDate;
        widget.subscriptionService.saveChannels();
      }
    });
  }

  void _manageSubscriptions() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManageSubscriptionsScreen(
          subscriptionService: widget.subscriptionService,
          onSubscriptionsChanged: () => _loadData(), // Reload data when returning
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight, // Restore toolbar height for actions
        elevation: 0, // Remove shadow
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              widget.toggleThemeMode(); // Call the passed callback
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/favfeedr_icon.png', height: 64),
                  const SizedBox(height: 8),
                  const Text(
                    'FavFeedr',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen(
                    toggleThemeMode: widget.toggleThemeMode,
                    themeMode: widget.themeMode,
                    subscriptionService: widget.subscriptionService,
                    onSubscriptionsChanged: _loadSettingsAndData,
                    settingsService: widget.settingsService, // NEW
                  )),
                );
              },
            ),
          ],
        ),
      ),
      body: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/favfeedr_icon.png', height: 40),
                                    const SizedBox(width: 8),
                                    Text(
                                      'FavFeedr',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Fresh videos from the channels you love.',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _importSubscriptions,
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text('Upload subscriptions.csv'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Display an explicit button to clear channels

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_channels.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.subscriptions,
                                size: 80,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No subscriptions yet. Import your YouTube subscriptions to get started!',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _importSubscriptions,
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Upload subscriptions.csv'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, groupIndex) {
                            final groupName = _groupedChannels.keys.elementAt(groupIndex);
                            final channelsInGroup = _groupedChannels[groupName]!;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8.0), // Add some spacing between groups
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white // Dark Mode: Group background is white
                                    : Colors.grey.shade800, // Light Mode: Group background is dark grey
                                borderRadius: BorderRadius.circular(12.0), // Rounded corners for aesthetics
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  groupName,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.black87 // Dark Mode: Black text on white background
                                            : Colors.white, // Light Mode: White text on dark grey background
                                      ),
                                ),
                                initiallyExpanded: true,
                                children: [ // Added list literal
                                  ...channelsInGroup.map((channel) {
                                      final videos = _allVideos[channel.id] ?? [];

                                      if (videos.isEmpty) {
                                        // Display loading indicator if channel is loading
                                        if (_channelLoadingStatus[channel.id] == true) {
                                          return const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Center(child: CircularProgressIndicator()),
                                          );
                                        }
                                        return const SizedBox.shrink(); // Don't show header if no videos
                                      }

                                      final int newPostsCount = channel.newVideoIds.length;

                                      return Card(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Theme.of(context).cardColor // Dark Mode: Channel background is dark grey (cardColor)
                                            : Colors.white, // Light Mode: Channel background is white
                                        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                        child: ExpansionTile(
                                          // Removed key: PageStorageKey(channel.id),
                                          title: ChannelHeader(
                                            channelName: channel.name,
                                            newPostsCount: newPostsCount,
                                            onMarkAllAsSeen: () => _markAllChannelVideosAsSeen(channel.id),
                                          ),
                                          initiallyExpanded: false, // Do not expand by default
                                          children: [
                                                                                        if (_videoLayoutMode == 'grid')
                                                                                          GridView.builder(
                                                                                            shrinkWrap: true, // Important to prevent unbounded height
                                                                                            physics: const NeverScrollableScrollPhysics(), // To prevent GridView from scrolling independently
                                                                                                                                                                                                                                                                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                                                                                                                                                                                                                                              crossAxisCount: 3, // Keep this for reasonable width
                                                                                                                                                                                                                                                                                              crossAxisSpacing: 8.0,
                                                                                                                                                                                                                                                                                              mainAxisSpacing: 8.0,
                                                                                                                                                                                                                                                                                              childAspectRatio: 0.7, // Decrease to increase height relative to width
                                                                                                                                                                                                                                                                                            ),                                                                                            itemCount: videos.length,
                                                                                            itemBuilder: (context, videoIndex) {
                                                                                              final video = videos[videoIndex];
                                                                                              return VideoGridItem(
                                                                                                video: video,
                                                                                                onVideoTap: _markVideoAsSeen,
                                                                                              );
                                                                                            },
                                                                                          )                                          else // List view (default)
                                            ...videos.map((video) => VideoListItem(
                                              video: video,
                                              onVideoTap: _markVideoAsSeen,
                                            )).toList(),
                                        ],
                                      ), // Closing ExpansionTile
                                    ); // Closing Card
                                  }).toList(),
                                ], // Closing list literal
                              ), // Closing ExpansionTile
                            ); // Closing Container
                          },
                          childCount: _groupedChannels.length,
                        ),
                      ),
                  ],
                ),
    );
  }
}

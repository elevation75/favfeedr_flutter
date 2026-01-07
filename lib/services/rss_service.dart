// favfeedr_flutter/lib/services/rss_service.dart
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:favfeedr_flutter/models/video_item.dart';
import 'package:favfeedr_flutter/models/channel.dart';
import 'package:favfeedr_flutter/services/settings_service.dart'; // New import

class RssService {
  final SettingsService _settingsService; // New field

  RssService(this._settingsService); // New constructor

  Future<Map<String, dynamic>> fetchVideosForChannel(Channel channel) async {
    final String rssUrl = "https://www.youtube.com/feeds/videos.xml?channel_id=${channel.id}";
    final response = await http.get(Uri.parse(rssUrl));

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final List<VideoItem> videos = [];
      final List<String> newVideoIds = [];
      final DateTime lastSeen = channel.lastSeenPostDate ?? DateTime.fromMicrosecondsSinceEpoch(0);

      final entries = document.findAllElements('entry');
      
      // Use setting from SettingsService
      final int maxItems = await _settingsService.getMaxItemsPerChannel(); // Get setting
      int count = 0;
      for (final entry in entries) {
        if (count >= maxItems) break; // Use maxItems instead of hardcoded constant

        final videoId = entry.findElements('yt:videoId').first.text;
        final title = entry.findElements('title').first.text;
        final link = entry.findElements('link').first.getAttribute('href')!;
        final published = DateTime.parse(entry.findElements('published').first.text);
        final author = entry.findElements('author').first.findElements('name').first.text;
        
        // Find thumbnail URL within media:group
        String thumbnailUrl = '';
        final mediaGroup = entry.findElements('media:group').firstOrNull;
        if (mediaGroup != null) {
          final thumbnail = mediaGroup.findElements('media:thumbnail').firstOrNull;
          if (thumbnail != null) {
            thumbnailUrl = thumbnail.getAttribute('url')?.replaceFirst('hqdefault', 'mqdefault') ?? '';
          }
        }
        
        final video = VideoItem(
          id: videoId,
          title: title,
          link: link,
          thumbnailUrl: thumbnailUrl,
          channelName: author,
          channelId: channel.id,
          publishedDate: published,
        );

        videos.add(video);

        if (video.publishedDate.isAfter(lastSeen)) {
          newVideoIds.add(video.id);
        }
        count++;
      }
      return {'videos': videos, 'newVideoIds': newVideoIds};
    } else {
      throw Exception('Failed to load RSS feed for ${channel.name}: ${response.statusCode}');
    }
  }
}

// favfeedr_flutter/lib/models/video_item.dart
class VideoItem {
  final String id;
  final String title;
  final String link;
  final String thumbnailUrl;
  final String channelName;
  final String channelId;
  final DateTime publishedDate;

  VideoItem({
    required this.id,
    required this.title,
    required this.link,
    required this.thumbnailUrl,
    required this.channelName,
    required this.channelId,
    required this.publishedDate,
  });
}

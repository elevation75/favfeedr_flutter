// favfeedr_flutter/lib/ui/widgets/video_list_item.dart
import 'package:flutter/material.dart';
import 'package:favfeedr_flutter/models/video_item.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class VideoListItem extends StatelessWidget {
  final VideoItem video;
  final Function(String videoId, String channelId)? onVideoTap; // New callback

  const VideoListItem({
    super.key,
    required this.video,
    this.onVideoTap, // Accept the callback
  });

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(video.link);
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
    // Notify parent that this video was tapped
    if (onVideoTap != null) {
      onVideoTap!(video.id, video.channelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4, // Increased elevation for a subtle shadow
      child: InkWell(
        onTap: _launchUrl, // Use the internal _launchUrl which calls onVideoTap
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  video.thumbnailUrl,
                  width: 120,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor, // Use card color as background
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/favfeedr_icon.png',
                          height: 40,
                          width: 40,
                          fit: BoxFit.contain,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), // Tint the logo
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12.0),
              // Video details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      video.channelName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      timeago.format(video.publishedDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// favfeedr_flutter/lib/ui/widgets/video_grid_item.dart
import 'package:flutter/material.dart';
import 'package:favfeedr_flutter/models/video_item.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class VideoGridItem extends StatefulWidget {
  final VideoItem video;
  final Function(String videoId, String channelId)? onVideoTap;

  const VideoGridItem({
    super.key,
    required this.video,
    this.onVideoTap,
  });

  @override
  State<VideoGridItem> createState() => _VideoGridItemState();
}

class _VideoGridItemState extends State<VideoGridItem> {
  bool _isHovered = false;

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(widget.video.link);
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
    if (widget.onVideoTap != null) {
      widget.onVideoTap!(widget.video.id, widget.video.channelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          clipBehavior: Clip.antiAlias, // Ensures content is clipped to card shape
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: _isHovered ? 10 : 4, // Increased elevation on hover
          child: InkWell(
            onTap: _launchUrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.network(
                    widget.video.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).cardColor,
                        child: Center(
                          child: Image.asset(
                            'assets/favfeedr_icon.png',
                            height: 40,
                            width: 40,
                            fit: BoxFit.contain,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        widget.video.channelName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        timeago.format(widget.video.publishedDate),
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
      ),
    );
  }
}

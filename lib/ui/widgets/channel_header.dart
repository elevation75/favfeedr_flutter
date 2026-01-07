// favfeedr_flutter/lib/ui/widgets/channel_header.dart
import 'package:flutter/material.dart';

class ChannelHeader extends StatelessWidget {
  final String channelName;
  final int? newPostsCount;
  final VoidCallback? onMarkAllAsSeen; // New callback

  const ChannelHeader({
    super.key,
    required this.channelName,
    this.newPostsCount,
    this.onMarkAllAsSeen, // New
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded( // Wrap Text in Expanded to make room for the icon
            child: Text(
              channelName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              overflow: TextOverflow.ellipsis, // Add overflow handling
            ),
          ),
          if (newPostsCount != null && newPostsCount! > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '$newPostsCount new',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          if (newPostsCount != null && newPostsCount! > 0 && onMarkAllAsSeen != null) // Show icon only if new posts and callback provided
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              color: Theme.of(context).primaryColor,
              onPressed: onMarkAllAsSeen,
              tooltip: 'Mark all as seen',
            ),
        ],
      ),
    );
  }
}

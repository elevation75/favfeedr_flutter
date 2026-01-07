// favfeedr_flutter/lib/models/channel.dart
class Channel {
  final String id;
  final String name;
  final String? group; // New property
  DateTime? lastSeenPostDate;
  List<String> newVideoIds; // IDs of videos considered 'new'

  Channel({
    required this.id,
    required this.name,
    this.group, // New property
    this.lastSeenPostDate,
    List<String>? newVideoIds,
  }) : newVideoIds = newVideoIds ?? [];

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      name: json['name'],
      group: json['group'], // New property
      lastSeenPostDate: json['last_seen_post_date'] != null
          ? DateTime.parse(json['last_seen_post_date'])
          : null,
      newVideoIds: List<String>.from(json['new_video_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'group': group, // New property
      'last_seen_post_date': lastSeenPostDate?.toIso8601String(),
      'new_video_ids': newVideoIds,
    };
  }
}

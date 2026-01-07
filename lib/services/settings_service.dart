// favfeedr_flutter/lib/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _maxItemsPerChannelKey = 'max_items_per_channel';
  static const int _defaultMaxItemsPerChannel = 8;
  static const String _videoLayoutModeKey = 'video_layout_mode'; // New
  static const String defaultVideoLayoutMode = 'list'; // New

  Future<int> getMaxItemsPerChannel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_maxItemsPerChannelKey) ?? _defaultMaxItemsPerChannel;
  }

  Future<void> setMaxItemsPerChannel(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxItemsPerChannelKey, value);
  }

  // New methods for video layout mode
  Future<String> getVideoLayoutMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_videoLayoutModeKey) ?? defaultVideoLayoutMode; // Corrected
  }

  Future<void> setVideoLayoutMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_videoLayoutModeKey, value);
  }
}

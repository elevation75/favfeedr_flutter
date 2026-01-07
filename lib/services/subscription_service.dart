// favfeedr_flutter/lib/services/subscription_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // New import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart'; // This is not actually used in the current version, but might be if we switch to file-based storage.
import 'package:favfeedr_flutter/models/channel.dart';
// import 'package:csv/csv.dart'; // No longer needed
import 'package:file_picker/file_picker.dart';

class SubscriptionService {
  static const String _channelsKey = 'subscribed_channels';
  static const String _groupsKey = 'groups';
  List<Channel> _channels = [];

  List<Channel> get channels => _channels;

  Future<void> loadChannels() async {
    final prefs = await SharedPreferences.getInstance();
    final String? channelsJson = prefs.getString(_channelsKey);

    if (channelsJson != null) {
      Iterable decoded = jsonDecode(channelsJson);
      _channels = List<Channel>.from(decoded.map((model) => Channel.fromJson(model)));
    } else {
      _channels = [];
    }
  }

  Future<void> saveChannels() async {
    final prefs = await SharedPreferences.getInstance();
    String channelsJson = jsonEncode(_channels.map((channel) => channel.toJson()).toList());
    await prefs.setString(_channelsKey, channelsJson);
  }

  void addChannel(Channel channel, {String? group}) {
    if (!_channels.any((c) => c.id == channel.id)) {
      final newChannel = Channel(
        id: channel.id,
        name: channel.name,
        group: group,
      );
      _channels.add(newChannel);
      saveChannels();
    }
  }

  void removeChannel(String channelId) {
    _channels.removeWhere((channel) => channel.id == channelId);
    saveChannels();
  }

  Future<List<Channel>> parseChannelsFromCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      PlatformFile platformFile = result.files.first;
      String? filePath = platformFile.path;

      if (filePath != null) {
        String fileContent = await File(filePath).readAsString();
        const splitter = LineSplitter();
        final List<String> lines = splitter.convert(fileContent);

        if (lines.isEmpty) return [];

        List<Channel> channelsFromCsv = [];
        int idIndex = -1;
        int nameIndex = -1;
        int groupIndex = -1;

        if (lines.isNotEmpty) {
          final List<String> header = lines[0].split(',');
          print('DEBUG: CSV Header: $header');

          for (int i = 0; i < header.length; i++) {
            String headerText = header[i].trim();
            if (headerText.startsWith('\uFEFF')) {
              headerText = headerText.substring(1);
            }
            
            if (headerText == 'Channel Id') {
              idIndex = i;
            } else if (headerText == 'Channel Title') {
              nameIndex = i;
            } else if (headerText == 'Group') {
              groupIndex = i;
            }
          }
        }
        
        if (idIndex == -1 || nameIndex == -1) {
          throw Exception("Invalid CSV format. Missing 'Channel Id' or 'Channel Title' columns.");
        }

        // Start from 1 to skip header row
        for (int i = 1; i < lines.length; i++) {
          final List<String> row = lines[i].split(',');
          if (row.length > idIndex && row.length > nameIndex) {
            String channelId = row[idIndex].trim();
            String channelName = row[nameIndex].trim();
            String? group = groupIndex != -1 && row.length > groupIndex ? row[groupIndex].trim() : null;

            if (channelId.isNotEmpty) {
              channelsFromCsv.add(Channel(id: channelId, name: channelName, group: group));
            }
          }
        }
        return channelsFromCsv;
      }
    }
    return [];
  }

  void clearChannels() {
    _channels.clear();
    saveChannels();
  }

  Future<List<String>> getGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final explicitGroups = prefs.getStringList(_groupsKey) ?? [];

    await loadChannels();
    final channelGroupsWithNulls = _channels.map((c) => c.group);
    final channelGroups = channelGroupsWithNulls.where((g) => g != null && g.isNotEmpty).cast<String>();

    final allGroups = {...explicitGroups, ...channelGroups}.toList();
    allGroups.sort(); // Sort for consistent ordering
    return allGroups;
  }

  Future<void> addGroup(String groupName) async {
    final prefs = await SharedPreferences.getInstance();
    final groups = prefs.getStringList(_groupsKey) ?? [];
    if (!groups.contains(groupName)) {
      groups.add(groupName);
      await prefs.setStringList(_groupsKey, groups);
    }
  }

  Future<void> renameGroup(String oldGroupName, String newGroupName) async {
    final prefs = await SharedPreferences.getInstance();
    final groups = prefs.getStringList(_groupsKey) ?? [];
    if (groups.contains(oldGroupName) && !groups.contains(newGroupName)) {
      final index = groups.indexOf(oldGroupName);
      groups[index] = newGroupName;
      await prefs.setStringList(_groupsKey, groups);

      await loadChannels();
      for (var channel in _channels) {
        if (channel.group == oldGroupName) {
          final updatedChannel = Channel(
            id: channel.id,
            name: channel.name,
            group: newGroupName,
            lastSeenPostDate: channel.lastSeenPostDate,
            newVideoIds: channel.newVideoIds,
          );
          _channels[_channels.indexOf(channel)] = updatedChannel;
        }
      }
      await saveChannels();
    }
  }

  Future<void> deleteGroup(String groupName) async {
    final prefs = await SharedPreferences.getInstance();
    final groups = prefs.getStringList(_groupsKey) ?? [];
    if (groups.contains(groupName)) {
      groups.remove(groupName);
      await prefs.setStringList(_groupsKey, groups);

      await loadChannels();
      for (var channel in _channels) {
        if (channel.group == groupName) {
          final updatedChannel = Channel(
            id: channel.id,
            name: channel.name,
            group: null,
            lastSeenPostDate: channel.lastSeenPostDate,
            newVideoIds: channel.newVideoIds,
          );
          _channels[_channels.indexOf(channel)] = updatedChannel;
        }
      }
      await saveChannels();
    }
  }

  Future<bool> exportSubscriptionsToJson() async {
    await loadChannels();
    final List<Map<String, dynamic>> channelsData = _channels.map((channel) {
      return {
        'id': channel.id,
        'name': channel.name,
        'group': channel.group,
      };
    }).toList();

    final String jsonString = jsonEncode(channelsData);
    final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

    final String? outputFile = await FilePicker.platform.saveFile(
      bytes: bytes,
      fileName: 'favfeedr_backup.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    return outputFile != null;
  }

  Future<bool> importSubscriptionsFromJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      PlatformFile platformFile = result.files.first;
      String? filePath = platformFile.path;

      if (filePath != null) {
        String fileContent = await File(filePath).readAsString();
        final List<dynamic> jsonData = jsonDecode(fileContent);

        final List<Channel> importedChannels = [];
        final Set<String> importedGroups = {};

        for (var item in jsonData) {
          try {
            final channel = Channel(
              id: item['id'],
              name: item['name'],
              group: item['group'],
            );
            importedChannels.add(channel);
            if (item['group'] != null && item['group'].isNotEmpty) {
              importedGroups.add(item['group']);
            }
          } catch (e) {
            print('Error parsing channel from JSON: $e');
            // Optionally, skip this channel or log a warning
          }
        }

        // Add imported channels
        for (var channel in importedChannels) {
          addChannel(channel, group: channel.group);
        }

        // Add imported groups to the explicit groups list
        final prefs = await SharedPreferences.getInstance();
        final existingGroups = prefs.getStringList(_groupsKey) ?? [];
        final updatedGroups = {...existingGroups, ...importedGroups}.toList();
        await prefs.setStringList(_groupsKey, updatedGroups);

        return true;
      }
    }
    return false;
  }
}

// favfeedr_flutter/lib/ui/manage_groups_screen.dart
import 'package:flutter/material.dart';
import 'package:favfeedr_flutter/services/subscription_service.dart';

class ManageGroupsScreen extends StatefulWidget {
  final SubscriptionService subscriptionService;

  const ManageGroupsScreen({super.key, required this.subscriptionService});

  @override
  State<ManageGroupsScreen> createState() => _ManageGroupsScreenState();
}

class _ManageGroupsScreenState extends State<ManageGroupsScreen> {
  List<String> _groups = [];
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await widget.subscriptionService.getGroups();
    setState(() {
      _groups = groups;
    });
  }

  void _addGroup(String groupName) {
    if (groupName.isNotEmpty && !_groups.contains(groupName)) {
      widget.subscriptionService.addGroup(groupName);
      setState(() {
        _groups.add(groupName);
      });
    }
  }

  void _renameGroup(String oldGroupName, String newGroupName) {
    if (newGroupName.isNotEmpty && !_groups.contains(newGroupName)) {
      widget.subscriptionService.renameGroup(oldGroupName, newGroupName);
      setState(() {
        final index = _groups.indexOf(oldGroupName);
        _groups[index] = newGroupName;
      });
    }
  }

  void _deleteGroup(String groupName) {
    widget.subscriptionService.deleteGroup(groupName);
    setState(() {
      _groups.remove(groupName);
    });
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Group'),
          content: TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(hintText: 'Group name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addGroup(_groupNameController.text);
                _groupNameController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameGroupDialog(String oldGroupName) {
    _groupNameController.text = oldGroupName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Group'),
          content: TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(hintText: 'Group name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _renameGroup(oldGroupName, _groupNameController.text);
                _groupNameController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteGroupDialog(String groupName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Group'),
          content: Text('Are you sure you want to delete the group "$groupName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteGroup(groupName);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Groups'),
      ),
      body: ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          return ListTile(
            title: Text(group),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showRenameGroupDialog(group);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteGroupDialog(group);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGroupDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

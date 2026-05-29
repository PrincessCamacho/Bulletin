import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../models/announcement.dart';
import '../../widgets/category_chip.dart';
import 'announcement_form_screen.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  late Announcement _announcement;

  @override
  void initState() {
    super.initState();
    _announcement = widget.announcement;
  }

  Future<void> _editAnnouncement() async {
    final updated = await Navigator.of(context).push<Announcement>(
      MaterialPageRoute(
        builder: (_) => AnnouncementFormScreen(existingAnnouncement: _announcement),
      ),
    );

    if (updated != null) {
      await updated.save();
      setState(() {
        _announcement = updated;
      });
    }
  }

  Future<void> _togglePin() async {
    _announcement.isPinned = !_announcement.isPinned;
    await _announcement.save();
    setState(() {});
  }

  Future<void> _softDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text('This announcement will be moved to the archive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    _announcement.isDeleted = true;
    _announcement.deletedAt = DateTime.now();
    await _announcement.save();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Announcement Detail'),
        actions: [
          IconButton(
            onPressed: _editAnnouncement,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: _softDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _announcement.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: _togglePin,
                      icon: Icon(
                        _announcement.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: AppColors.secondaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CategoryChip(label: _announcement.category),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('MMM d, y').format(_announcement.datePosted),
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  _announcement.body,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text('Pinned', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Switch(
                      value: _announcement.isPinned,
                      activeThumbColor: AppColors.primaryGreen,
                      onChanged: (_) => _togglePin(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

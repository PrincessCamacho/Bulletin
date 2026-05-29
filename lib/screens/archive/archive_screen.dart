import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/announcement.dart';
import '../../models/issue_report.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveEntry {
  final String id;
  final String title;
  final String type;
  final DateTime deletedAt;
  final dynamic item;

  _ArchiveEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.deletedAt,
    required this.item,
  });
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final Box<Announcement> _announcementsBox = Hive.box<Announcement>('announcements');
  final Box<IssueReport> _reportsBox = Hive.box<IssueReport>('issue_reports');

  final _filters = const [
    'All',
    AppStrings.announcements,
    AppStrings.reports,
  ];

  String _selectedFilter = 'All';
  List<_ArchiveEntry> _archivedItems = [];

  @override
  void initState() {
    super.initState();
    _loadArchive();
  }

  void _loadArchive() {
    final announcements = _announcementsBox.values.where((announcement) => announcement.isDeleted).map(
          (announcement) => _ArchiveEntry(
            id: announcement.id,
            title: announcement.title,
            type: AppStrings.announcements,
            deletedAt: announcement.deletedAt ?? DateTime.now(),
            item: announcement,
          ),
        );
    final reports = _reportsBox.values.where((report) => report.isDeleted).map(
          (report) => _ArchiveEntry(
            id: report.id,
            title: report.title,
            type: AppStrings.reports,
            deletedAt: report.deletedAt ?? DateTime.now(),
            item: report,
          ),
        );
    final items = [...announcements, ...reports];
    items.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
    setState(() {
      _archivedItems = items;
    });
  }

  List<_ArchiveEntry> get _visibleArchive {
    if (_selectedFilter == 'All') return _archivedItems;
    return _archivedItems.where((entry) => entry.type == _selectedFilter).toList();
  }

  Future<void> _restore(_ArchiveEntry entry) async {
    if (entry.item is Announcement) {
      final announcement = entry.item as Announcement;
      announcement.isDeleted = false;
      announcement.deletedAt = null;
      await announcement.save();
    } else if (entry.item is IssueReport) {
      final report = entry.item as IssueReport;
      report.isDeleted = false;
      report.deletedAt = null;
      await report.save();
    }
    _loadArchive();
  }

  Future<void> _hardDelete(_ArchiveEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.hardDelete),
        content: const Text(AppStrings.confirmDeletePermanent),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    if (entry.item is Announcement) {
      await _announcementsBox.delete(entry.id);
    } else if (entry.item is IssueReport) {
      await _reportsBox.delete(entry.id);
    }
    _loadArchive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.archive),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Row(
              children: _filters.map((filter) {
                final selected = filter == _selectedFilter;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: selected,
                      label: Text(filter),
                      onSelected: (_) => setState(() {
                        _selectedFilter = filter;
                      }),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _visibleArchive.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.archive_outlined, size: 72, color: AppColors.muted),
                          SizedBox(height: 16),
                          Text(
                            'Archive is empty. Soft-deleted items will appear here for restore or permanent removal.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _visibleArchive.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = _visibleArchive[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.title,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    Text(entry.type, style: const TextStyle(color: AppColors.muted)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Deleted: ${DateFormat('MMM d, y').format(entry.deletedAt)}',
                                  style: const TextStyle(color: AppColors.muted),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _restore(entry),
                                      child: const Text(AppStrings.restore),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton(
                                      onPressed: () => _hardDelete(entry),
                                      child: const Text(AppStrings.hardDelete),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/announcement.dart';
import '../../widgets/category_chip.dart';
import '../announcements/announcement_detail_screen.dart';
import '../announcements/announcement_form_screen.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({super.key});

  @override
  State<AnnouncementsListScreen> createState() => _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  final Box<Announcement> _box = Hive.box<Announcement>('announcements');
  final _categories = const [
    AppStrings.all,
    AppStrings.info,
    AppStrings.event,
    AppStrings.emergency,
    AppStrings.health,
  ];

  String _selectedCategory = AppStrings.all;
  List<Announcement> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    final items = _box.values.where((announcement) => !announcement.isDeleted).toList();
    items.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return b.isPinned ? 1 : -1;
      }
      return b.datePosted.compareTo(a.datePosted);
    });
    setState(() {
      _announcements = items;
    });
  }

  List<Announcement> get _filteredAnnouncements {
    if (_selectedCategory == AppStrings.all) {
      return _announcements;
    }
    return _announcements.where((announcement) => announcement.category == _selectedCategory).toList();
  }

  Future<void> _openForm({Announcement? announcement}) async {
    final result = await Navigator.of(context).push<Announcement>(
      MaterialPageRoute(
        builder: (_) => AnnouncementFormScreen(existingAnnouncement: announcement),
      ),
    );

    if (result != null) {
      await _box.put(result.id, result);
      _loadAnnouncements();
    }
  }

  Future<void> _openDetail(Announcement announcement) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnnouncementDetailScreen(announcement: announcement),
      ),
    );
    _loadAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.announcements),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final selected = category == _selectedCategory;
                return ChoiceChip(
                  selected: selected,
                  label: Text(category),
                  selectedColor: const Color.fromRGBO(15, 125, 74, 0.14),
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredAnnouncements.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.campaign_outlined, size: 72, color: AppColors.muted),
                          SizedBox(height: 16),
                          Text(
                            'No announcements yet. Create the first bulletin to keep the barangay informed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredAnnouncements.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final announcement = _filteredAnnouncements[index];
                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _openDetail(announcement),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          announcement.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      if (announcement.isPinned)
                                        const Icon(Icons.push_pin, color: AppColors.secondaryBlue, size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      CategoryChip(label: announcement.category),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat('MMM d, y').format(announcement.datePosted),
                                        style: const TextStyle(color: AppColors.muted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    announcement.body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        label: const Text('Create Announcement'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

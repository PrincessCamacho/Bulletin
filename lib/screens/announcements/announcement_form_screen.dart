import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/announcement.dart';

class AnnouncementFormScreen extends StatefulWidget {
  final Announcement? existingAnnouncement;

  const AnnouncementFormScreen({super.key, this.existingAnnouncement});

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _categories = const [
    AppStrings.info,
    AppStrings.event,
    AppStrings.emergency,
    AppStrings.health,
  ];

  String? _category;
  bool _isPinned = false;

  bool get _isEditMode => widget.existingAnnouncement != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleController.text = widget.existingAnnouncement!.title;
      _bodyController.text = widget.existingAnnouncement!.body;
      _category = widget.existingAnnouncement!.category;
      _isPinned = widget.existingAnnouncement!.isPinned;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEditMode) {
      final existing = widget.existingAnnouncement!;
      existing.title = _titleController.text.trim();
      existing.body = _bodyController.text.trim();
      existing.category = _category!;
      existing.isPinned = _isPinned;
      Navigator.of(context).pop(existing);
      return;
    }

    final newAnnouncement = Announcement(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      category: _category!,
      datePosted: DateTime.now(),
      isPinned: _isPinned,
      isDeleted: false,
    );

    Navigator.of(context).pop(newAnnouncement);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Announcement' : 'Create Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
                maxLines: 5,
                validator: (value) => value == null || value.trim().isEmpty ? 'Body is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _category = value;
                }),
                validator: (value) => value == null || value.isEmpty ? 'Category is required' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Pinned'),
                value: _isPinned,
                activeThumbColor: AppColors.primaryGreen,
                onChanged: (value) => setState(() {
                  _isPinned = value;
                }),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(_isEditMode ? 'Save' : 'Create'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/issue_report.dart';

class ReportFormScreen extends StatefulWidget {
  final IssueReport? existingReport;

  const ReportFormScreen({super.key, this.existingReport});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categories = const [
    AppStrings.road,
    AppStrings.power,
    AppStrings.water,
    AppStrings.safety,
    AppStrings.other,
  ];
  final _statuses = const [
    AppStrings.pending,
    AppStrings.inProgress,
    AppStrings.resolved,
  ];

  String? _category;
  String? _status;

  bool get _isEditMode => widget.existingReport != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleController.text = widget.existingReport!.title;
      _descriptionController.text = widget.existingReport!.description;
      _category = widget.existingReport!.category;
      _status = widget.existingReport!.status;
    } else {
      _status = AppStrings.pending;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEditMode) {
      final report = widget.existingReport!;
      report.title = _titleController.text.trim();
      report.description = _descriptionController.text.trim();
      report.category = _category!;
      report.status = _status!;
      Navigator.of(context).pop(report);
      return;
    }

    final newReport = IssueReport(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category!,
      status: _status ?? AppStrings.pending,
      dateReported: DateTime.now(),
      isDeleted: false,
    );
    Navigator.of(context).pop(newReport);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Report' : 'Create Report'),
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
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 5,
                validator: (value) => value == null || value.trim().isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
                validator: (value) => value == null || value.isEmpty ? 'Category is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: _statuses
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setState(() => _status = value),
                validator: (value) => value == null || value.isEmpty ? 'Status is required' : null,
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

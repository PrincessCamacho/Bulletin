import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/issue_report.dart';
import '../../widgets/status_badge.dart';
import 'report_form_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  final IssueReport report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late IssueReport _report;
  final _statuses = const [
    AppStrings.pending,
    AppStrings.inProgress,
    AppStrings.resolved,
  ];

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  Color _statusColor(String status) {
    switch (status) {
      case AppStrings.pending:
        return AppColors.warning;
      case AppStrings.inProgress:
        return AppColors.info;
      case AppStrings.resolved:
        return AppColors.success;
      default:
        return AppColors.muted;
    }
  }

  Future<void> _updateStatus(String? newStatus) async {
    if (newStatus == null || newStatus == _report.status) {
      return;
    }
    _report.status = newStatus;
    await _report.save();
    setState(() {});
  }

  Future<void> _editReport() async {
    final updated = await Navigator.of(context).push<IssueReport>(
      MaterialPageRoute(
        builder: (_) => ReportFormScreen(existingReport: _report),
      ),
    );
    if (updated != null) {
      await updated.save();
      setState(() {
        _report = updated;
      });
    }
  }

  Future<void> _softDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('This report will be moved to the archive.'),
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

    if (confirmed != true) return;
    _report.isDeleted = true;
    _report.deletedAt = DateTime.now();
    await _report.save();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report Detail'),
        actions: [
          IconButton(onPressed: _editReport, icon: const Icon(Icons.edit)),
          IconButton(onPressed: _softDelete, icon: const Icon(Icons.delete_outline)),
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
                Text(
                  _report.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    StatusBadge(label: _report.status, color: _statusColor(_report.status)),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMM d, y').format(_report.dateReported),
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Category: ${_report.category}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Text(
                  _report.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const Spacer(),
                const Text('Update status', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _report.status,
                  items: _statuses
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: _updateStatus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

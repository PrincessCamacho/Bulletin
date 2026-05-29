import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/issue_report.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/status_badge.dart';
import 'report_detail_screen.dart';
import 'report_form_screen.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final Box<IssueReport> _box = Hive.box<IssueReport>('issue_reports');
  final _statusFilters = const [
    AppStrings.all,
    AppStrings.pending,
    AppStrings.inProgress,
    AppStrings.resolved,
  ];
  final _categories = const [
    AppStrings.all,
    AppStrings.road,
    AppStrings.power,
    AppStrings.water,
    AppStrings.safety,
    AppStrings.other,
  ];

  String _selectedStatus = AppStrings.all;
  String _selectedCategory = AppStrings.all;
  List<IssueReport> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    final items = _box.values.where((report) => !report.isDeleted).toList();
    items.sort((a, b) => b.dateReported.compareTo(a.dateReported));
    setState(() {
      _reports = items;
    });
  }

  List<IssueReport> get _filteredReports {
    return _reports.where((report) {
      final statusMatch = _selectedStatus == AppStrings.all || report.status == _selectedStatus;
      final categoryMatch = _selectedCategory == AppStrings.all || report.category == _selectedCategory;
      return statusMatch && categoryMatch;
    }).toList();
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

  Future<void> _openForm({IssueReport? report}) async {
    final result = await Navigator.of(context).push<IssueReport>(
      MaterialPageRoute(
        builder: (_) => ReportFormScreen(existingReport: report),
      ),
    );

    if (result != null) {
      await _box.put(result.id, result);
      _loadReports();
    }
  }

  Future<void> _openDetail(IssueReport report) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportDetailScreen(report: report),
      ),
    );
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.reports),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: _categories
                        .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? AppStrings.all;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: _statusFilters
                        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? AppStrings.all;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredReports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.report_gmailerrorred_outlined, size: 72, color: AppColors.muted),
                          SizedBox(height: 16),
                          Text(
                            'No reports found. Use the button below to document community issues.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredReports.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final report = _filteredReports[index];
                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _openDetail(report),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      CategoryChip(label: report.category),
                                      const SizedBox(width: 8),
                                      StatusBadge(
                                        label: report.status,
                                        color: _statusColor(report.status),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('MMM d, y').format(report.dateReported),
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
        icon: const Icon(Icons.add),
        label: const Text('Create Report'),
      ),
    );
  }
}

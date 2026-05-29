import 'package:hive/hive.dart';

part 'issue_report.g.dart';

@HiveType(typeId: 1)
class IssueReport extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category;

  @HiveField(4)
  String status;

  @HiveField(5)
  DateTime dateReported;

  @HiveField(6)
  bool isDeleted;

  @HiveField(7)
  DateTime? deletedAt;

  IssueReport({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.dateReported,
    this.isDeleted = false,
    this.deletedAt,
  });

  IssueReport copyWith({
    String? title,
    String? description,
    String? category,
    String? status,
    DateTime? dateReported,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return IssueReport(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      dateReported: dateReported ?? this.dateReported,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

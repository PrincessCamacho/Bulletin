import 'package:hive/hive.dart';

part 'announcement.g.dart';

@HiveType(typeId: 0)
class Announcement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String body;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime datePosted;

  @HiveField(5)
  bool isPinned;

  @HiveField(6)
  bool isDeleted;

  @HiveField(7)
  DateTime? deletedAt;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.datePosted,
    this.isPinned = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  Announcement copyWith({
    String? title,
    String? body,
    String? category,
    DateTime? datePosted,
    bool? isPinned,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Announcement(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      datePosted: datePosted ?? this.datePosted,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_report.dart';

class IssueReportAdapter extends TypeAdapter<IssueReport> {
  @override
  final int typeId = 1;

  @override
  IssueReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return IssueReport(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      status: fields[4] as String,
      dateReported: fields[5] as DateTime,
      isDeleted: fields[6] as bool,
      deletedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, IssueReport obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.dateReported)
      ..writeByte(6)
      ..write(obj.isDeleted)
      ..writeByte(7)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueReportAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

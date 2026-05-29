// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

class AnnouncementAdapter extends TypeAdapter<Announcement> {
  @override
  final int typeId = 0;

  @override
  Announcement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Announcement(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      category: fields[3] as String,
      datePosted: fields[4] as DateTime,
      isPinned: fields[5] as bool,
      isDeleted: fields[6] as bool,
      deletedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Announcement obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.datePosted)
      ..writeByte(5)
      ..write(obj.isPinned)
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
      other is AnnouncementAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

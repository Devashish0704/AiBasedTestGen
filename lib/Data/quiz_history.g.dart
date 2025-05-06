// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizHistoryAdapter extends TypeAdapter<QuizHistory> {
  @override
  final int typeId = 0;

  @override
  QuizHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizHistory(
      quizId: fields[0] as String,
      quizTitle: fields[1] as String,
      quizIcon: fields[2] as String,
      difficulty: fields[3] as String,
      score: fields[4] as int,
      totalQuestions: fields[5] as int,
      accuracy: fields[6] as double,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QuizHistory obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.quizId)
      ..writeByte(1)
      ..write(obj.quizTitle)
      ..writeByte(2)
      ..write(obj.quizIcon)
      ..writeByte(3)
      ..write(obj.difficulty)
      ..writeByte(4)
      ..write(obj.score)
      ..writeByte(5)
      ..write(obj.totalQuestions)
      ..writeByte(6)
      ..write(obj.accuracy)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

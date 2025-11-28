// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'correction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Correction _$CorrectionFromJson(Map<String, dynamic> json) => Correction(
      original: json['original'] as String,
      corrected: json['corrected'] as String,
      note: json['note'] as String,
    );

Map<String, dynamic> _$CorrectionToJson(Correction instance) =>
    <String, dynamic>{
      'original': instance.original,
      'corrected': instance.corrected,
      'note': instance.note,
    };

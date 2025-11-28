import 'package:json_annotation/json_annotation.dart';

part 'correction.g.dart';

@JsonSerializable()
class Correction {
  final String original;
  final String corrected;
  final String note;

  Correction({
    required this.original,
    required this.corrected,
    required this.note,
  });

  factory Correction.fromJson(Map<String, dynamic> json) =>
      _$CorrectionFromJson(json);

  Map<String, dynamic> toJson() => _$CorrectionToJson(this);
}

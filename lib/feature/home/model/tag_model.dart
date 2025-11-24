import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_model.freezed.dart';
part 'tag_model.g.dart';

@freezed
class TagModel with _$TagModel {
  factory TagModel({
    @JsonKey(includeToJson: false) String? id,
    String? name,
  }) = _TagModel;
  TagModel._();

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);
}

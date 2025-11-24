part of 'tag_cubit.dart';

@freezed
class TagState with _$TagState {
  const factory TagState({
    @Default(Status.initial) Status status,
    @Default([]) List<TagModel> tagList,
    TagModel? currentTag,
  }) = _TagState;
}

part of 'tag_cubit.dart';

class TagState extends Equatable {
  const TagState({
    this.status = Status.initial,
    this.tagList = const [],
    this.currentTag,
  });

  final Status status;
  final List<TagModel> tagList;
  final TagModel? currentTag;

  @override
  List<Object?> get props => [status, tagList, currentTag];

  TagState copyWith({
    Status? status,
    List<TagModel>? tagList,
    TagModel? currentTag,
  }) {
    return TagState(
      status: status ?? this.status,
      tagList: tagList ?? this.tagList,
      currentTag: currentTag ?? this.currentTag,
    );
  }
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tag_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TagState {
  Status get status => throw _privateConstructorUsedError;
  List<TagModel> get tagList => throw _privateConstructorUsedError;
  TagModel? get currentTag => throw _privateConstructorUsedError;

  /// Create a copy of TagState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagStateCopyWith<TagState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagStateCopyWith<$Res> {
  factory $TagStateCopyWith(TagState value, $Res Function(TagState) then) =
      _$TagStateCopyWithImpl<$Res, TagState>;
  @useResult
  $Res call({Status status, List<TagModel> tagList, TagModel? currentTag});

  $TagModelCopyWith<$Res>? get currentTag;
}

/// @nodoc
class _$TagStateCopyWithImpl<$Res, $Val extends TagState>
    implements $TagStateCopyWith<$Res> {
  _$TagStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TagState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? tagList = null,
    Object? currentTag = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as Status,
            tagList: null == tagList
                ? _value.tagList
                : tagList // ignore: cast_nullable_to_non_nullable
                      as List<TagModel>,
            currentTag: freezed == currentTag
                ? _value.currentTag
                : currentTag // ignore: cast_nullable_to_non_nullable
                      as TagModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of TagState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TagModelCopyWith<$Res>? get currentTag {
    if (_value.currentTag == null) {
      return null;
    }

    return $TagModelCopyWith<$Res>(_value.currentTag!, (value) {
      return _then(_value.copyWith(currentTag: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TagStateImplCopyWith<$Res>
    implements $TagStateCopyWith<$Res> {
  factory _$$TagStateImplCopyWith(
    _$TagStateImpl value,
    $Res Function(_$TagStateImpl) then,
  ) = __$$TagStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Status status, List<TagModel> tagList, TagModel? currentTag});

  @override
  $TagModelCopyWith<$Res>? get currentTag;
}

/// @nodoc
class __$$TagStateImplCopyWithImpl<$Res>
    extends _$TagStateCopyWithImpl<$Res, _$TagStateImpl>
    implements _$$TagStateImplCopyWith<$Res> {
  __$$TagStateImplCopyWithImpl(
    _$TagStateImpl _value,
    $Res Function(_$TagStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TagState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? tagList = null,
    Object? currentTag = freezed,
  }) {
    return _then(
      _$TagStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as Status,
        tagList: null == tagList
            ? _value._tagList
            : tagList // ignore: cast_nullable_to_non_nullable
                  as List<TagModel>,
        currentTag: freezed == currentTag
            ? _value.currentTag
            : currentTag // ignore: cast_nullable_to_non_nullable
                  as TagModel?,
      ),
    );
  }
}

/// @nodoc

class _$TagStateImpl implements _TagState {
  const _$TagStateImpl({
    this.status = Status.initial,
    final List<TagModel> tagList = const [],
    this.currentTag,
  }) : _tagList = tagList;

  @override
  @JsonKey()
  final Status status;
  final List<TagModel> _tagList;
  @override
  @JsonKey()
  List<TagModel> get tagList {
    if (_tagList is EqualUnmodifiableListView) return _tagList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagList);
  }

  @override
  final TagModel? currentTag;

  @override
  String toString() {
    return 'TagState(status: $status, tagList: $tagList, currentTag: $currentTag)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._tagList, _tagList) &&
            (identical(other.currentTag, currentTag) ||
                other.currentTag == currentTag));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    const DeepCollectionEquality().hash(_tagList),
    currentTag,
  );

  /// Create a copy of TagState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagStateImplCopyWith<_$TagStateImpl> get copyWith =>
      __$$TagStateImplCopyWithImpl<_$TagStateImpl>(this, _$identity);
}

abstract class _TagState implements TagState {
  const factory _TagState({
    final Status status,
    final List<TagModel> tagList,
    final TagModel? currentTag,
  }) = _$TagStateImpl;

  @override
  Status get status;
  @override
  List<TagModel> get tagList;
  @override
  TagModel? get currentTag;

  /// Create a copy of TagState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagStateImplCopyWith<_$TagStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

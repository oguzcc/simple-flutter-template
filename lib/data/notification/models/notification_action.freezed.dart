// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationAction _$NotificationActionFromJson(Map<String, dynamic> json) {
  return _NotificationAction.fromJson(json);
}

/// @nodoc
mixin _$NotificationAction {
  String get notificationId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  NotificationActionType get type => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;

  /// Serializes this NotificationAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationActionCopyWith<NotificationAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationActionCopyWith<$Res> {
  factory $NotificationActionCopyWith(
    NotificationAction value,
    $Res Function(NotificationAction) then,
  ) = _$NotificationActionCopyWithImpl<$Res, NotificationAction>;
  @useResult
  $Res call({
    String notificationId,
    String title,
    String body,
    DateTime timestamp,
    NotificationActionType type,
    Map<String, dynamic> data,
  });
}

/// @nodoc
class _$NotificationActionCopyWithImpl<$Res, $Val extends NotificationAction>
    implements $NotificationActionCopyWith<$Res> {
  _$NotificationActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationId = null,
    Object? title = null,
    Object? body = null,
    Object? timestamp = null,
    Object? type = null,
    Object? data = null,
  }) {
    return _then(
      _value.copyWith(
            notificationId: null == notificationId
                ? _value.notificationId
                : notificationId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationActionType,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationActionImplCopyWith<$Res>
    implements $NotificationActionCopyWith<$Res> {
  factory _$$NotificationActionImplCopyWith(
    _$NotificationActionImpl value,
    $Res Function(_$NotificationActionImpl) then,
  ) = __$$NotificationActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String notificationId,
    String title,
    String body,
    DateTime timestamp,
    NotificationActionType type,
    Map<String, dynamic> data,
  });
}

/// @nodoc
class __$$NotificationActionImplCopyWithImpl<$Res>
    extends _$NotificationActionCopyWithImpl<$Res, _$NotificationActionImpl>
    implements _$$NotificationActionImplCopyWith<$Res> {
  __$$NotificationActionImplCopyWithImpl(
    _$NotificationActionImpl _value,
    $Res Function(_$NotificationActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationId = null,
    Object? title = null,
    Object? body = null,
    Object? timestamp = null,
    Object? type = null,
    Object? data = null,
  }) {
    return _then(
      _$NotificationActionImpl(
        notificationId: null == notificationId
            ? _value.notificationId
            : notificationId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationActionType,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationActionImpl implements _NotificationAction {
  const _$NotificationActionImpl({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = NotificationActionType.general,
    final Map<String, dynamic> data = const {},
  }) : _data = data;

  factory _$NotificationActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationActionImplFromJson(json);

  @override
  final String notificationId;
  @override
  final String title;
  @override
  final String body;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final NotificationActionType type;
  final Map<String, dynamic> _data;
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  String toString() {
    return 'NotificationAction(notificationId: $notificationId, title: $title, body: $body, timestamp: $timestamp, type: $type, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationActionImpl &&
            (identical(other.notificationId, notificationId) ||
                other.notificationId == notificationId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    notificationId,
    title,
    body,
    timestamp,
    type,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationActionImplCopyWith<_$NotificationActionImpl> get copyWith =>
      __$$NotificationActionImplCopyWithImpl<_$NotificationActionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationActionImplToJson(this);
  }
}

abstract class _NotificationAction implements NotificationAction {
  const factory _NotificationAction({
    required final String notificationId,
    required final String title,
    required final String body,
    required final DateTime timestamp,
    final NotificationActionType type,
    final Map<String, dynamic> data,
  }) = _$NotificationActionImpl;

  factory _NotificationAction.fromJson(Map<String, dynamic> json) =
      _$NotificationActionImpl.fromJson;

  @override
  String get notificationId;
  @override
  String get title;
  @override
  String get body;
  @override
  DateTime get timestamp;
  @override
  NotificationActionType get type;
  @override
  Map<String, dynamic> get data;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationActionImplCopyWith<_$NotificationActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationActionImpl _$$NotificationActionImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationActionImpl(
  notificationId: json['notificationId'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  type:
      $enumDecodeNullable(_$NotificationActionTypeEnumMap, json['type']) ??
      NotificationActionType.general,
  data: json['data'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$$NotificationActionImplToJson(
  _$NotificationActionImpl instance,
) => <String, dynamic>{
  'notificationId': instance.notificationId,
  'title': instance.title,
  'body': instance.body,
  'timestamp': instance.timestamp.toIso8601String(),
  'type': _$NotificationActionTypeEnumMap[instance.type]!,
  'data': instance.data,
};

const _$NotificationActionTypeEnumMap = {
  NotificationActionType.general: 'general',
  NotificationActionType.deepLink: 'deepLink',
  NotificationActionType.navigation: 'navigation',
};

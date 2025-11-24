import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_action.freezed.dart';
part 'notification_action.g.dart';

/// Types of notification actions
enum NotificationActionType {
  general,
  deepLink,
  navigation,
}

/// Represents a notification action to be processed
@freezed
class NotificationAction with _$NotificationAction {
  const factory NotificationAction({
    required String notificationId,
    required String title,
    required String body,
    required DateTime timestamp,
    @Default(NotificationActionType.general) NotificationActionType type,
    @Default({}) Map<String, dynamic> data,
  }) = _NotificationAction;

  factory NotificationAction.fromJson(Map<String, dynamic> json) =>
      _$NotificationActionFromJson(json);
}
import 'package:equatable/equatable.dart';

/// Types of notification actions
enum NotificationActionType {
  general,
  deepLink,
  navigation,
}

/// Represents a notification action to be processed
class NotificationAction extends Equatable {
  const NotificationAction({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = NotificationActionType.general,
    this.data = const {},
  });

  final String notificationId;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationActionType type;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [
    notificationId,
    title,
    body,
    timestamp,
    type,
    data,
  ];

  NotificationAction copyWith({
    String? notificationId,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationActionType? type,
    Map<String, dynamic>? data,
  }) {
    return NotificationAction(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      notificationId: json['notificationId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] != null
          ? NotificationActionType.values.byName(json['type'] as String)
          : NotificationActionType.general,
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'data': data,
    };
  }
}

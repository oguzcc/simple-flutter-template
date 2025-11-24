import 'package:equatable/equatable.dart';

/// Enum for different login types
enum LoginType {
  unknown,
  email,
  google,
  facebook,
  apple,
  anonymous
}

/// Social login response model with comprehensive error handling
class LoginResponseModel extends Equatable {
  const LoginResponseModel({
    required this.status,
    this.message,
    this.emailAddress,
    this.socialId,
    this.image,
    this.name,
    this.loginType = LoginType.unknown,
    this.errorCode,
    this.metadata,
  });

  final bool status;
  final String? message;
  final String? emailAddress;
  final String? socialId;
  final String? image;
  final String? name;
  final LoginType loginType;
  final String? errorCode;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [
        status,
        message,
        emailAddress,
        socialId,
        image,
        name,
        loginType,
        errorCode,
        metadata,
      ];

  LoginResponseModel copyWith({
    bool? status,
    String? message,
    String? emailAddress,
    String? socialId,
    String? image,
    String? name,
    LoginType? loginType,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    return LoginResponseModel(
      status: status ?? this.status,
      message: message ?? this.message,
      emailAddress: emailAddress ?? this.emailAddress,
      socialId: socialId ?? this.socialId,
      image: image ?? this.image,
      name: name ?? this.name,
      loginType: loginType ?? this.loginType,
      errorCode: errorCode ?? this.errorCode,
      metadata: metadata ?? this.metadata,
    );
  }

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      status: json['status'] as bool,
      message: json['message'] as String?,
      emailAddress: json['emailAddress'] as String?,
      socialId: json['socialId'] as String?,
      image: json['image'] as String?,
      name: json['name'] as String?,
      loginType: json['loginType'] != null
          ? LoginType.values.byName(json['loginType'] as String)
          : LoginType.unknown,
      errorCode: json['errorCode'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (message != null) 'message': message,
      if (emailAddress != null) 'emailAddress': emailAddress,
      if (socialId != null) 'socialId': socialId,
      if (image != null) 'image': image,
      if (name != null) 'name': name,
      'loginType': loginType.name,
      if (errorCode != null) 'errorCode': errorCode,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Success factory constructor
  factory LoginResponseModel.success({
    required String emailAddress,
    required String socialId,
    required LoginType loginType,
    String? name,
    String? image,
    String? message,
    Map<String, dynamic>? metadata,
  }) {
    return LoginResponseModel(
      status: true,
      emailAddress: emailAddress,
      socialId: socialId,
      loginType: loginType,
      name: name,
      image: image,
      message: message ?? 'Login successful',
      metadata: metadata,
    );
  }

  /// Error factory constructor
  factory LoginResponseModel.error({
    required String message,
    String? errorCode,
    LoginType? loginType,
    Map<String, dynamic>? metadata,
  }) {
    return LoginResponseModel(
      status: false,
      message: message,
      errorCode: errorCode,
      loginType: loginType ?? LoginType.unknown,
      metadata: metadata,
    );
  }

  /// Check if login was successful
  bool get isSuccess => status;

  /// Check if login failed
  bool get isError => !status;

  /// Get user display name or fallback
  String get displayName => name ?? emailAddress ?? 'Unknown User';
}

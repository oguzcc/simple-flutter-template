import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response_model.freezed.dart';
part 'login_response_model.g.dart';

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
@freezed
class LoginResponseModel with _$LoginResponseModel {
  const factory LoginResponseModel({
    required bool status,
    String? message,
    String? emailAddress,
    String? socialId,
    String? image,
    String? name,
    @Default(LoginType.unknown) LoginType loginType,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) = _LoginResponseModel;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  /// Success factory constructor
  const LoginResponseModel._();
  
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

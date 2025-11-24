import 'package:equatable/equatable.dart';

class ReqSignInDto extends Equatable {
  const ReqSignInDto({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];

  ReqSignInDto copyWith({
    String? email,
    String? password,
  }) {
    return ReqSignInDto(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  factory ReqSignInDto.fromJson(Map<String, dynamic> json) {
    return ReqSignInDto(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

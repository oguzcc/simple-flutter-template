import 'package:equatable/equatable.dart';

class ReqSignUpDto extends Equatable {
  const ReqSignUpDto({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];

  ReqSignUpDto copyWith({
    String? name,
    String? email,
    String? password,
  }) {
    return ReqSignUpDto(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  factory ReqSignUpDto.fromJson(Map<String, dynamic> json) {
    return ReqSignUpDto(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }
}

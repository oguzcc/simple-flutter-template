import 'package:daisy/data/model/user_model.dart';
import 'package:equatable/equatable.dart';

class AuthModel extends Equatable {
  const AuthModel({
    this.token,
    this.user = const UserModel(),
  });

  final String? token;
  final UserModel? user;

  @override
  List<Object?> get props => [token, user];

  AuthModel copyWith({
    String? token,
    UserModel? user,
  }) {
    return AuthModel(
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : const UserModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (token != null) 'token': token,
      if (user != null) 'user': user!.toJson(),
    };
  }
}

enum LoginType { email, google, facebook, apple, unknown }

class ResSocialLogin {

  ResSocialLogin({
    required this.status,
    this.message,
    this.emailAddress,
    this.socialId,
    this.image,
    this.name,
    this.loginType,
  });
  final bool status;
  String? message;
  String? emailAddress;
  String? socialId;
  String? image;
  String? name;
  LoginType? loginType;

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'emailAddress': emailAddress,
      'socialId': socialId,
      'image': image,
      'name': name,
    };
  }
}

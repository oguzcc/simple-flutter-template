// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginResponseModelImpl _$$LoginResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$LoginResponseModelImpl(
  status: json['status'] as bool,
  message: json['message'] as String?,
  emailAddress: json['emailAddress'] as String?,
  socialId: json['socialId'] as String?,
  image: json['image'] as String?,
  name: json['name'] as String?,
  loginType:
      $enumDecodeNullable(_$LoginTypeEnumMap, json['loginType']) ??
      LoginType.unknown,
  errorCode: json['errorCode'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$LoginResponseModelImplToJson(
  _$LoginResponseModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'message': instance.message,
  'emailAddress': instance.emailAddress,
  'socialId': instance.socialId,
  'image': instance.image,
  'name': instance.name,
  'loginType': _$LoginTypeEnumMap[instance.loginType]!,
  'errorCode': instance.errorCode,
  'metadata': instance.metadata,
};

const _$LoginTypeEnumMap = {
  LoginType.unknown: 'unknown',
  LoginType.email: 'email',
  LoginType.google: 'google',
  LoginType.facebook: 'facebook',
  LoginType.apple: 'apple',
  LoginType.anonymous: 'anonymous',
};

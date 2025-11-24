import 'package:daisy/core/manager/remote/dio_client.dart';
import 'package:daisy/core/types/typedefs.dart';
import 'package:daisy/data/dto/auth/req_sign_in_dto.dart';
import 'package:daisy/data/dto/auth/req_sign_up_dto.dart';
import 'package:daisy/data/path/auth_path.dart';

class AuthRepo implements IAuthRepo {
  AuthRepo(this._dioClient);
  final DioClient _dioClient;

  @override
  AsyncResMap signIn(ReqSignInDto req) async =>
      _dioClient.postMap(AuthPath.signIn.path, data: req.toJson());

  @override
  AsyncResMap signUp(ReqSignUpDto req) async =>
      _dioClient.postMap(AuthPath.signUp.path, data: req.toJson());
}

abstract class IAuthRepo {
  AsyncResMap signIn(ReqSignInDto req);
  AsyncResMap signUp(ReqSignUpDto req);
}

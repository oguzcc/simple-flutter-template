import 'package:daisy/core/config/app_flavor.dart';
// Add social login service import
import 'package:daisy/core/manager/firebase/social_login_service.dart';
import 'package:daisy/core/manager/remote/dio_client.dart';
import 'package:daisy/data/repo/auth_repo.dart';
import 'package:daisy/data/service/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<List<RepositoryProvider<dynamic>>> locator({
  bool isMock = false,
}) async {
  final dio = Dio();

  final providers = <RepositoryProvider<dynamic>>[
    RepositoryProvider<DioClient>(
      create: (context) =>
          DioClient(dio, AppFlavor.instance().apiOptions!, context),
    ),
    RepositoryProvider<IAuthRepo>(
      create: (context) => AuthRepo(context.read()),
    ),
    RepositoryProvider<IAuthService>(
      create: (context) => AuthService(context.read()),
    ),
    // Add social login service
    RepositoryProvider<SocialLoginService>(
      create: (context) => SocialLoginService(),
    ),
  ];
  if (isMock) {
    return [];
  } else {
    return providers;
  }
}

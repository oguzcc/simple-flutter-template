import 'package:daisy/core/config/app_flavor.dart';
import 'package:daisy/core/manager/firebase/social_login_service.dart';
import 'package:daisy/core/manager/purchase/purchase_service.dart';
import 'package:daisy/core/manager/remote/dio_client.dart';
import 'package:daisy/data/repo/auth_repo.dart';
import 'package:daisy/data/service/auth_service.dart';
import 'package:daisy/feature/auth/cubit/auth_cubit.dart';
import 'package:daisy/router/router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<List<RepositoryProvider<dynamic>>> locator({
  bool isMock = false,
}) async {
  final dio = Dio();

  final providers = <RepositoryProvider<dynamic>>[
    RepositoryProvider<DioClient>(
      create: (context) => DioClient(
        dio,
        AppFlavor.instance().apiOptions!,
        onUnauthorized: _handleUnauthorized,
      ),
    ),
    RepositoryProvider<IAuthRepo>(
      create: (context) => AuthRepo(context.read()),
    ),
    RepositoryProvider<IAuthService>(
      create: (context) => AuthService(context.read()),
    ),
    RepositoryProvider<SocialLoginService>(
      create: (context) => SocialLoginService(),
    ),
    RepositoryProvider<PurchaseService>(
      create: (context) => PurchaseService(),
    ),
  ];
  if (isMock) {
    return [];
  } else {
    return providers;
  }
}

Future<void> _handleUnauthorized() async {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return;
  try {
    await ctx.read<AuthCubit>().signOut();
  } on Object catch (_) {
    // AuthCubit not yet available in widget tree; ignore.
  }
}

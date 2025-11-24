import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:daisy/core/bloc/conn/conn_cubit.dart';
import 'package:daisy/core/bloc/lang/lang_cubit.dart';
import 'package:daisy/feature/auth/cubit/auth_cubit.dart';
import 'package:daisy/feature/home/cubit/home_cubit.dart';
import 'package:daisy/feature/home/cubit/tag_cubit.dart';
import 'package:daisy/feature/purchase/cubit/purchase_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<BlocProvider<StateStreamableSource<Object?>>> provider() {
  return <BlocProvider>[
    BlocProvider<ConnCubit>(
      create: (context) => ConnCubit(connectivity: Connectivity())..listen(),
    ),

    /// Auth Cubit with social login capability
    BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(
        context.read(), // IAuthService
        context.read(), // SocialLoginService
      ),
    ),

    /// Lang Cubit
    BlocProvider<LangCubit>(create: (context) => LangCubit()),

    /// Home Cubit
    BlocProvider<HomeCubit>(create: (context) => HomeCubit()),

    /// Tag Cubit
    BlocProvider<TagCubit>(create: (context) => TagCubit()),

    /// Purchase Cubit
    BlocProvider<PurchaseCubit>(create: (context) => PurchaseCubit()),

    /// User Cubit
  ];
}

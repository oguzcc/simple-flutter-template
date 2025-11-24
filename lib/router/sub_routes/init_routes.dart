import 'package:daisy/feature/auth/view/enhanced_login_screen.dart';
import 'package:daisy/feature/auth/view/sign_in_screen.dart';
import 'package:daisy/feature/purchase/view/purchase_screen.dart';
import 'package:daisy/feature/splash/view/onboard_screen.dart';
import 'package:daisy/feature/splash/view/splash_screen.dart';
import 'package:daisy/router/screens.dart';
import 'package:go_router/go_router.dart';

sealed class InitRoutes {
  static final routes = [
    GoRoute(
      path: Screens.splash.path,
      name: Screens.splash.name,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SplashScreen()),
    ),
    GoRoute(
      path: Screens.onboard.path,
      name: Screens.onboard.name,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: OnboardScreen()),
    ),
    GoRoute(
      path: Screens.signIn.path,
      name: Screens.signIn.name,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SignInScreen()),
    ),
    GoRoute(
      path: Screens.enhancedLogin.path,
      name: Screens.enhancedLogin.name,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: EnhancedLoginScreen()),
    ),
    GoRoute(
      path: Screens.purchase.path,
      name: Screens.purchase.name,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: PurchaseScreen()),
    ),
  ];
}

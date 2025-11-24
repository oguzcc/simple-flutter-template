import 'package:daisy/core/analytics/analytics_service.dart';
import 'package:daisy/router/bottom_navbar/bottom_navbar_stateful.dart';
import 'package:daisy/router/screens.dart';
import 'package:daisy/router/sub_routes/home_routes.dart';
import 'package:daisy/router/sub_routes/init_routes.dart';
import 'package:daisy/router/sub_routes/profile_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final goRouter = GoRouter(
  initialLocation: Screens.splash.path,
  debugLogDiagnostics: true,
  navigatorKey: rootNavigatorKey,
  observers: [AnalyticsService.instance.observer],
  redirect: (context, state) {
    // Her şey splash'dan başlar, splash karar verir
    if (state.uri.path == '/') {
      return Screens.splash.path;
    }
    return null;
  },
  routes: [
    ...InitRoutes.routes,
    // State kept
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state, navigationShell) =>
          BottomNavBarStateful(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: homeNavigatorKey,
          routes: [...HomeRoutes.routes],
        ),
        StatefulShellBranch(
          navigatorKey: profileNavigatorKey,
          routes: [...ProfileRoutes.routes],
        ),
      ],
    ),

    //* MARK: Alternative ShellRoute
    // State isn't kept
    // ShellRoute(
    //   navigatorKey: shellNavigatorKey,
    //   builder: (context, state, child) => BottomNavBar(child: child),
    //   routes: [...HomeRoutes.routes, ...ProfileRoutes.routes],
    // ),
  ],
);
// Stateful Navigator Keys
final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final rootScaffoldKey = GlobalKey<ScaffoldState>();
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class RouterNotifier extends ValueNotifier<int> {
  factory RouterNotifier() => instance;
  RouterNotifier._internal() : super(0);
  static final RouterNotifier instance = RouterNotifier._internal();

  void reset() {
    update(0);
    notifyListeners();
  }

  void update(int value) {
    if (value != this.value) {
      this.value = value;
      notifyListeners();
    }
  }
}

import 'package:daisy/core/analytics/smartlook_service.dart';
import 'package:daisy/core/config/app_flavor.dart';
import 'package:daisy/core/style/theme.dart';
import 'package:daisy/router/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smartlook/flutter_smartlook.dart';
import 'package:network_logger/network_logger.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final smartlookService = SmartlookService.instance;
    
    switch (state) {
      case AppLifecycleState.resumed:
        smartlookService.trackEvent('app_lifecycle', {'state': 'foreground'});
        break;
      case AppLifecycleState.paused:
        smartlookService.trackEvent('app_lifecycle', {'state': 'background'});
        break;
      case AppLifecycleState.detached:
        smartlookService.trackEvent('app_lifecycle', {'state': 'terminated'});
        break;
      case AppLifecycleState.hidden:
        smartlookService.trackEvent('app_lifecycle', {'state': 'hidden'});
        break;
      case AppLifecycleState.inactive:
        // Handle inactive state if needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    // Use with Google Fonts package to use downloadable fonts
    final textTheme = createTextTheme(context, 'Rubik', 'Rubik');
    final theme = MaterialTheme(textTheme);

    // Attach network logger overlay
    if (AppFlavor.instance().flavorType != FlavorType.production) {
      NetworkLoggerOverlay.attachTo(context);
    }

    return SmartlookHelperWidget(
      child: MaterialApp.router(
        title: 'Flutter Template',
        debugShowCheckedModeBanner: false,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: brightness == Brightness.light ? theme.light() : theme.dark(),
        routerConfig: goRouter,
      ),
    );
  }
}

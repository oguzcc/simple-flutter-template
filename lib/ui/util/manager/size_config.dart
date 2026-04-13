import 'package:daisy/router/router.dart';
import 'package:flutter/material.dart';

/// Ekran boyutlarını tutmak için yazıldı
class SizeConfig {
  static double _statusBarHeight = 0;
  static double _screenWidth = 0;
  static double _screenHeight = 0;

  static MediaQueryData get _mediaQueryData {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) {
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      return MediaQueryData.fromView(view);
    }

    return MediaQuery.of(ctx);
  }

  static double get screenWidth =>
      _screenWidth = _mediaQueryData.size.width == 0
      ? _screenWidth
      : _mediaQueryData.size.width;

  static double get screenHeight =>
      _screenHeight = _mediaQueryData.size.height == 0
      ? _screenHeight
      : _mediaQueryData.size.height;

  static double get blockSizeHorizontal => screenWidth / 100;

  static double get blockSizeVertical => screenHeight / 100;

  static double get _safeAreaHorizontal =>
      _mediaQueryData.padding.left + _mediaQueryData.padding.right;

  static double get _safeAreaVertical =>
      _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

  static double get safeBlockHorizontal =>
      (screenWidth - _safeAreaHorizontal) / 100;

  static double get safeBlockVertical =>
      (screenHeight - _safeAreaVertical) / 100;

  static double get statusBarHeight =>
      _statusBarHeight = _mediaQueryData.padding.top != 0
      ? _mediaQueryData.padding.top
      : _statusBarHeight;

  static EdgeInsets get safeAreaPadding => _mediaQueryData.padding;

  static double get devicePixelRatio => _mediaQueryData.devicePixelRatio;

  static double get appBarHeight => kToolbarHeight;

  static double get screenHeightTopSafeArea => screenHeight - statusBarHeight;
}

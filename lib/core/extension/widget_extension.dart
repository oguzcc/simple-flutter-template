import 'package:flutter/material.dart';

/// Beli widgetin ggörünürlük durumunu değiştirmek için kullanılır
extension WidgetExtension on Widget {
  Widget isFiltered({required bool value, required ColorFilter colorFilter}) =>
      value ? ColorFiltered(colorFilter: colorFilter, child: this) : this;

  Widget isVisible({
    required bool value,
    double? height,
    double? width,
    Widget? child,
  }) =>
      value ? this : (child ?? SizedBox(height: height, width: width));

  SliverToBoxAdapter toSliver() => SliverToBoxAdapter(child: this);
}

import 'package:daisy/ui/util/manager/size_config.dart';
import 'package:daisy/ui/util/size/app_padding.dart';
import 'package:flutter/material.dart';

class Gap extends SizedBox {
  /// Creates a gap with zero width and height.
  const Gap.shrink({super.key}) : super.shrink();

  /// Creates a gap with very small size (2 pixels).
  const Gap.xxxs({super.key}) : super(width: _v / 2, height: _v / 2);

  /// Creates a gap with very extra small size (4 pixels).
  const Gap.xxs({super.key}) : super(width: _v, height: _v);

  /// Creates a gap with extra small size (8 pixels).
  const Gap.xs({super.key}) : super(width: _v * 2, height: _v * 2);

  /// Creates a gap with small size (12 pixels).
  const Gap.sm({super.key}) : super(width: _v * 3, height: _v * 3);

  /// Creates a gap with medium size (16 pixels).
  const Gap.md({super.key}) : super(width: _v * 4, height: _v * 4);

  /// Creates a gap with medium-large size (20 pixels).
  const Gap.ml({super.key}) : super(width: _v * 5, height: _v * 5);

  /// Creates a gap with large size (24 pixels).
  const Gap.lg({super.key}) : super(width: _v * 6, height: _v * 6);

  /// Creates a gap with extra large size (28 pixels).
  const Gap.xl({super.key}) : super(width: _v * 7, height: _v * 7);

  /// Creates a gap with very extra large size (32 pixels).
  const Gap.xxl({super.key}) : super(width: _v * 8, height: _v * 8);

  /// Creates a gap with safe block vertical size.
  Gap.safeBlockVertical({super.key})
      : super(height: SizeConfig.safeBlockVertical);

  /// Creates a gap with safe block horizontal size.
  Gap.safeBlockHorizontal({super.key})
      : super(width: SizeConfig.safeBlockHorizontal);

  static const double _v = 4;
}

List<Widget> addGap(List<Widget> widgets, [Gap? gap]) {
  final spacedWidgets = <Widget>[];
  for (final widget in widgets) {
    spacedWidgets.addAll([widget, gap ?? const Gap.sm()]);
  }

  return spacedWidgets;
}

class GapColumn extends StatelessWidget {
  const GapColumn({
    required this.children,
    super.key,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.gap,
  });

  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final Gap? gap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        children: addGap(children, gap),
      ),
    );
  }
}

class GapRow extends StatelessWidget {
  const GapRow({
    required this.children,
    super.key,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.gap,
  });

  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final Gap? gap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: AppPadding.baseScaffold,
        child: Row(
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
          children: addGap(children, gap),
        ),
      ),
    );
  }
}

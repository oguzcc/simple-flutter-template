// ignore_for_file: unused_element

import 'package:flutter/material.dart';

sealed class AppPadding {
  static const baseScaffold = PaddingConstant.md();
  static const appBar = PaddingConstant.xs();
  static const button = PaddingConstant.md();
  static const card = PaddingConstant.md();
  static const dialog = PaddingConstant.xs();
  static const bottomBar = PaddingConstant.xs();
  static const tile = PaddingConstant.md();
  static const icon = PaddingConstant.xxs();
  static const bottomButton = PaddingConstant.bottomButton();

  static PaddingConstant all(int level) => PaddingConstant.all(level);
  static const btnSocial = PaddingConstant.btnSocial();

  static PaddingConstant symmetric({int levelHor = 0, int levelVer = 0}) =>
      PaddingConstant.symmetric(levelHor: levelHor, levelVer: levelVer);

  static PaddingConstant horizontal(int level) =>
      PaddingConstant.symmetricHorizontal(level);
  static PaddingConstant vertical(int level) =>
      PaddingConstant.symmetricVertical(level);

  static PaddingConstant onlyTop(int level) => PaddingConstant.onlyTop(level);
  static PaddingConstant onlyBottom(int level) =>
      PaddingConstant.onlyBottom(level);
  static PaddingConstant onlyLeft(int level) => PaddingConstant.onlyLeft(level);
  static PaddingConstant onlyRight(int level) =>
      PaddingConstant.onlyRight(level);
}

final class PaddingConstant extends EdgeInsets {
  const PaddingConstant.xxs() : super.all(_value);
  const PaddingConstant.xs() : super.all(_value * 2);
  const PaddingConstant.sm() : super.all(_value * 3);
  const PaddingConstant.md() : super.all(_value * 4);
  const PaddingConstant.lg() : super.all(_value * 5);
  const PaddingConstant.xl() : super.all(_value * 6);
  const PaddingConstant.xxl() : super.all(_value * 7);
  const PaddingConstant.xl3() : super.all(_value);

  const PaddingConstant.all(int level)
      : assert(level > 0, 'level must be greater than 0'),
        super.all(_value * level);

  const PaddingConstant.symmetric({int levelHor = 0, int levelVer = 0})
      : assert(levelHor > 0 && levelVer > 0, 'level must be greater than 0'),
        super.symmetric(
          horizontal: _value * levelHor,
          vertical: _value * levelVer,
        );
  const PaddingConstant.symmetricHorizontal(int level)
      : assert(level > 0, 'level must be greater than 0'),
        super.symmetric(horizontal: _value * level);
  const PaddingConstant.symmetricVertical(int level)
      : assert(level > 0, 'level must be greater than 0'),
        super.symmetric(vertical: _value * level);

  const PaddingConstant.onlyTop(int level)
      : assert(level > 0, 'level must be greater than 0'),
        super.only(top: _value * level);
  const PaddingConstant.onlyBottom(int level)
      : assert(level > 0, 'level must be greater than 0'),
        super.only(bottom: _value * level);
  const PaddingConstant.onlyLeft(int level)
      : assert(level > 0, 'level must be greater than 0'),
        super.only(left: _value * level);
  const PaddingConstant.onlyRight(int level)
      : assert(level > 0, 'level must be greater than 0'),
        super.only(right: _value * level);

  const PaddingConstant.btnSocial()
      : super.symmetric(horizontal: 12, vertical: 12);
  const PaddingConstant.bottomButton() : super.fromLTRB(20, 0, 20, 24);

  static const double _value = 4;
}

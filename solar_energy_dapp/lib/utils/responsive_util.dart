import 'dart:math';
import 'package:flutter/material.dart';
import 'package:solar_energy_dapp/constants/dimensions.dart';

typedef ResponsiveWidgetBuilder = Widget Function(ResponsiveUtil util);

class ResponsiveBuilder extends StatelessWidget {
  final ResponsiveUtil? util;

  final ResponsiveWidgetBuilder builder;
  const ResponsiveBuilder({Key? key,required this.builder, this.util})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(util ?? ResponsiveUtil(context: context));
  }
}

class ResponsiveUtil {
  final Size deviceSize;

  ResponsiveUtil({required BuildContext context})
      : deviceSize = MediaQuery.of(context).size;

  bool get isMobile => deviceSize.width <= widthMobile;

  bool get isDesktop => deviceSize.width >= widthDesktop;

  bool get isTablet =>
      deviceSize.width < widthDesktop && deviceSize.width > widthMobile;

  T value<T>({required T mobile, T? tablet, required T desktop}) => isMobile
      ? mobile
      : isDesktop
      ? desktop
      : (tablet ?? mobile);

  double get optimalDeviceWidth => min(deviceSize.width, widthMaxAppWidth);

  double incremental(double mobile, {double factor = 1}) => isMobile
      ? mobile
      : isDesktop
      ? mobile + (2 * factor)
      : mobile + factor;

  double get defaultSmallGap2 => value<double>(
      mobile: gapXSmall, desktop: gapXXXNormal, tablet: gapSmall);

  double get defaultSmallGap => isDesktop
      ? gapXXXNormal
      : isMobile
      ? gapXSmall
      : gapSmall;

  double get defaultGap => isDesktop
      ? gapNormal
      : isMobile
      ? gapXXNormal
      : gapXNormal;

  double get smallFontSize => isDesktop
      ? fontXSmall
      : isMobile
      ? fontXXXSmall
      : fontXXSmall;

  double get normalFontSize => isDesktop
      ? fontSmall
      : isMobile
      ? fontXXSmall
      : fontXSmall;

  double get mediumFontSize => isDesktop
      ? fontNormal
      : isMobile
      ? fontXSmall
      : fontSmall;

  double get largeFontSize => isDesktop
      ? fontLarge
      : isMobile
      ? fontSmall
      : fontNormal;
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveWidget({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= widthDesktop) {
          return desktop;
        } else if (constraints.maxWidth > widthMobile) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
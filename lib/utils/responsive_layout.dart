import 'package:flutter/material.dart';

/// レスポンシブデザインのためのブレークポイント
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// デバイスタイプを判定
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// レスポンシブヘルパークラス
class ResponsiveHelper {
  /// デバイスタイプを取得
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.desktop) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// モバイルかどうか
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// タブレットかどうか
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// デスクトップ（PC）かどうか
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// グリッド列数を取得
  static int getGridColumns(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }

  /// コンテンツの最大幅を取得
  static double getContentMaxWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 800;
      case DeviceType.desktop:
        return 1200;
    }
  }
}

/// レスポンシブレイアウトウィジェット
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// レスポンシブなパディングを提供するウィジェット
class ResponsivePadding extends StatelessWidget {
  final Widget child;

  const ResponsivePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    
    double padding;
    switch (deviceType) {
      case DeviceType.mobile:
        padding = 16.0;
        break;
      case DeviceType.tablet:
        padding = 24.0;
        break;
      case DeviceType.desktop:
        padding = 32.0;
        break;
    }

    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}

/// レスポンシブなコンテナ（最大幅制限付き）
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveHelper.getContentMaxWidth(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

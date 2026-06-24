import 'package:flutter/material.dart';

/// Utilitas untuk membuat layout yang responsif di berbagai ukuran layar HP.
///
/// Cara pakai:
/// ```dart
/// final s = AppSizes(context);
/// padding: EdgeInsets.all(s.padding)
/// fontSize: s.fontMd
/// ```
class AppSizes {
  final BuildContext context;
  late final double _width;
  late final double _height;

  AppSizes(this.context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
  }

  // ── Breakpoints ────────────────────────────────────────────────────────────
  bool get isSmall  => _width < 360;   // HP kecil (< 360dp, ex: Redmi 4A)
  bool get isMedium => _width < 414;   // HP sedang (360-413dp)
  bool get isLarge  => _width >= 414;  // HP besar (414dp+, ex: iPhone Pro Max)

  // ── Padding & Spacing ──────────────────────────────────────────────────────
  double get paddingXS => isSmall ? 8   : 10;
  double get paddingSm => isSmall ? 12  : 16;
  double get padding   => isSmall ? 16  : 20;
  double get paddingLg => isSmall ? 20  : 24;

  double get spacingXS => isSmall ? 4  : 6;
  double get spacingSm => isSmall ? 8  : 10;
  double get spacing   => isSmall ? 12 : 16;
  double get spacingLg => isSmall ? 16 : 20;
  double get spacingXL => isSmall ? 20 : 28;

  // ── Font Sizes ─────────────────────────────────────────────────────────────
  double get fontXs  => isSmall ? 10 : 11;
  double get fontSm  => isSmall ? 12 : 13;
  double get fontMd  => isSmall ? 13 : 14;
  double get fontLg  => isSmall ? 15 : 16;
  double get fontXl  => isSmall ? 17 : 18;
  double get font2xl => isSmall ? 20 : 22;
  double get font3xl => isSmall ? 23 : 26;

  // ── Icon Sizes ─────────────────────────────────────────────────────────────
  double get iconSm  => isSmall ? 18 : 20;
  double get iconMd  => isSmall ? 22 : 24;
  double get iconLg  => isSmall ? 28 : 32;
  double get iconXl  => isSmall ? 36 : 40;
  double get icon2xl => isSmall ? 44 : 48;

  // ── Border Radius ──────────────────────────────────────────────────────────
  double get radiusSm => isSmall ? 10  : 12;
  double get radiusMd => isSmall ? 14  : 16;
  double get radiusLg => isSmall ? 18  : 20;
  double get radiusXl => isSmall ? 22  : 24;
  double get radius2x => isSmall ? 26  : 28;

  // ── Card Heights ───────────────────────────────────────────────────────────
  double get cardHeightFull  => isSmall ? 95  : 115;
  double get cardHeightHalf  => isSmall ? 130 : 155;

  // ── AppBar Heights ─────────────────────────────────────────────────────────
  double get appBarExpanded  => isSmall ? 180 : 210;

  // ── Screen Dimensions ──────────────────────────────────────────────────────
  double get screenWidth  => _width;
  double get screenHeight => _height;
}

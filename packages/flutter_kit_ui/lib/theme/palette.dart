import 'package:flutter/material.dart';

/// Raw color palette — pure data, zero logic.
///
/// All values are compile-time const. No map allocation at runtime.
/// Directly access rarely used shades here: Palette.primary[30]!
///
/// See [AppBrandColors] for commonly used semantic colors.
abstract final class Palette {
  static const Map<int, Color> primary = {
    10: Color(0xFFdbe2fe),
    20: Color(0xFFbfccfe),
    30: Color(0xFF92acfe),
    40: Color(0xFF5b7dfb),
    50: Color(0xFF3a55f7),
    60: Color(0xFF2433ec),
    70: Color(0xFF1c20d9),
    80: Color(0xFF1e1db0),
    90: Color(0xFF1d208b),
    100: Color(0xFF171754),
  };

  static const Map<int, Color> secondary = {
    10: Color(0xFFcef9ff),
    20: Color(0xFFa4f3fd),
    30: Color(0xFF65e7fb),
    40: Color(0xFF3ad7f2),
    50: Color(0xFF04b5d6),
    60: Color(0xFF068fb4),
    70: Color(0xFF0d7391),
    80: Color(0xFF145e76),
    90: Color(0xFF153d64),
    100: Color(0xFF073245),
  };

  static const Map<int, Color> tertiary = {
    10: Color(0xFFf1e6ff),
    20: Color(0xFFe5d1ff),
    30: Color(0xFFd1aeff),
    40: Color(0xFFB47AFF),
    50: Color(0xFF9847ff),
    60: Color(0xFF8e3afa),
    70: Color(0xFF6d13dd),
    80: Color(0xFF5e16b3),
    90: Color(0xFF4e1390),
    100: Color(0xFF33006c),
  };

  static const Map<int, Color> fourth = {
    10: Color(0xFFfce7ff),
    20: Color(0xFFf8ceff),
    30: Color(0xFFf7a7ff),
    40: Color(0xFFf585ff),
    50: Color(0xFFe83ef7),
    60: Color(0xFFcf1edb),
    70: Color(0xFFb015b6),
    80: Color(0xFF911395),
    90: Color(0xFF4e1390),
    100: Color(0xFF33006c),
  };

  static const Map<int, Color> gray = {
    10: Color(0xFFededf1),
    20: Color(0xFFd7d9e0),
    30: Color(0xFFb4b9c5),
    40: Color(0xFF8a91a6),
    50: Color(0xFF6c748b),
    60: Color(0xFF575d72),
    70: Color(0xFF474c5d),
    80: Color(0xFF3e4250),
    90: Color(0xFF363944),
    100: Color(0xFF24252d),
  };

  static const Map<int, Color> colorGray = {
    10: Color(0xFFeaecf4),
    20: Color(0xFFd1d7e6),
    30: Color(0xFFa9b3d0),
    40: Color(0xFF7b8cb5),
    50: Color(0xFF5a6d9d),
    60: Color(0xFF475682),
    70: Color(0xFF3a466a),
    80: Color(0xFF333d59),
    90: Color(0xFF2e354c),
    100: Color(0xFF1f2333),
  };

  static const Map<int, Color> white = {
    10: Color(0xFFffffff),
    20: Color(0xFFefefef),
    30: Color(0xFFdcdcdc),
    40: Color(0xFFbdbdbd),
    50: Color(0xFF7c7c7c),
    60: Color(0xFF656565),
    70: Color(0xFF525252),
    80: Color(0xFF464646),
    90: Color(0xFF3d3d3d),
    100: Color(0xFF292929),
  };
}

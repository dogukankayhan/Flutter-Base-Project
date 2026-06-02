import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

String _toKebabCase(String input) {
  return input
      .replaceAllMapped(RegExp(r'[A-Z0-9]'), (m) => '-${m[0]!.toLowerCase()}')
      .toLowerCase();
}

enum SvgEnum {
  home,
  search,
  profile,
  settings,
  arrowLeft,
  arrowRight,
  notification,
  share,
  trash,
  star;

  /// Resolved asset path for this icon.
  String get path => 'assets/icons/${_toKebabCase(name)}.svg';

  /// Build an [SvgPicture] widget.
  Widget call({
    Key? key,
    double width = 24,
    double height = 24,
    BoxFit fit = BoxFit.contain,
    Color? color,
  }) {
    return SvgPicture.asset(
      path,
      key: key,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }
}

enum PngEnum {
  background,
  profile,
  placeholder,
  appIcon;

  /// Resolved asset path, with optional variant suffix.
  String assetPath({String? variant}) {
    final base = 'assets/images/${_toKebabCase(name)}';
    return variant != null ? '$base-$variant.png' : '$base.png';
  }

  /// Build an [Image] widget.
  Widget call({
    Key? key,
    String? variant,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
  }) {
    return Image.asset(
      assetPath(variant: variant),
      key: key,
      width: width,
      height: height,
      fit: fit,
      color: color,
      errorBuilder: (_, _, _) => SizedBox(
        width: width,
        height: height,
        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
      ),
    );
  }
}

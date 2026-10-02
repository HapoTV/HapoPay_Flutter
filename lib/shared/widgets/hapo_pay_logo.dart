import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// HapoPay brand logo widget rendering the official vector asset
/// (`assets/branding/Hapo_Pay_Logo___Secondary__NBG_.svg`).
class HapoPayLogo extends StatelessWidget {
  static const String assetPath =
      'assets/branding/Hapo_Pay_Logo___Secondary__NBG_.svg';

  /// Height of the logo.
  final double? height;

  /// Width of the logo.
  final double? width;

  /// Convenience parameter to set height (or bounding size).
  /// If [height] is not specified, [size] is used for [height].
  final double? size;

  final BoxFit fit;
  final AlignmentGeometry alignment;

  const HapoPayLogo({
    super.key,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? size ?? 48.0;
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: effectiveHeight,
      fit: fit,
      alignment: alignment,
    );
  }
}

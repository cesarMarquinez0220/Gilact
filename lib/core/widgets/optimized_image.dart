import 'package:flutter/material.dart';

/// Widget helper para optimizar imágenes con cacheWidth y cacheHeight
/// Reduce significativamente el uso de memoria al decodificar imágenes
class OptimizedImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final BorderRadius? borderRadius;
  final Color? color;
  final BlendMode? colorBlendMode;

  const OptimizedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.borderRadius,
    this.color,
    this.colorBlendMode,
  });

  /// Calcula cacheWidth basado en el ancho y devicePixelRatio
  int? _getCacheWidth(BuildContext context) {
    if (width == null) return null;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (width! * devicePixelRatio).round();
  }

  /// Calcula cacheHeight basado en la altura y devicePixelRatio
  int? _getCacheHeight(BuildContext context) {
    if (height == null) return null;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (height! * devicePixelRatio).round();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: _getCacheWidth(context),
      cacheHeight: _getCacheHeight(context),
      errorBuilder: errorBuilder,
      color: color,
      colorBlendMode: colorBlendMode,
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}


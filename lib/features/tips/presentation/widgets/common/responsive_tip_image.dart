import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../../../core/widgets/optimized_image.dart';

/// Widget helper para crear imágenes responsive de tips
/// Optimizado para performance usando OptimizedImage y ResponsiveHelper
class ResponsiveTipImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const ResponsiveTipImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Usar ResponsiveHelper para obtener dimensiones responsive
        final screenWidth = ResponsiveHelper.screenWidth(context);
        final screenHeight = ResponsiveHelper.screenHeight(context);
        final isSmallScreen =
            ResponsiveHelper.isSmall(context) ||
            ResponsiveHelper.isShortScreen(context);
        final isVerySmallScreen = ResponsiveHelper.isVeryShortScreen(context);

        // Calcular dimensiones responsive de la imagen
        final imageWidth = isVerySmallScreen
            ? screenWidth * 0.45
            : (isSmallScreen ? screenWidth * 0.50 : screenWidth * 0.55);
        final imageHeight = isVerySmallScreen
            ? screenHeight * 0.25
            : (isSmallScreen ? screenHeight * 0.30 : screenHeight * 0.35);

        // Usar OptimizedImage para mejor performance de memoria
        return OptimizedImage(
          imagePath: imagePath,
          width: imageWidth,
          height: imageHeight,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: imageWidth,
              height: imageHeight,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 48,
              ),
            );
          },
        );
      },
    );
  }
}

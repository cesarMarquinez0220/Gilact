import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../../domain/entities/educational_content.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget reutilizable para mostrar contenido educativo
class EducationalContentWidget extends StatefulWidget {
  final EducationalContent content;
  final VoidCallback? onCompleted;
  final bool showCompletionButton;

  const EducationalContentWidget({
    super.key,
    required this.content,
    this.onCompleted,
    this.showCompletionButton = true,
  });

  @override
  State<EducationalContentWidget> createState() =>
      _EducationalContentWidgetState();
}

class _EducationalContentWidgetState extends State<EducationalContentWidget> {
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.content.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen del contenido
            SizedBox(
              height: screenHeight * 0.35,
              width: screenWidth * 0.45,
              child: FadeInRight(
                duration: const Duration(milliseconds: 1000),
                delay: const Duration(milliseconds: 500),
                child: Image.asset(
                  widget.content.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.library_books,
                        color: AppColors.primary,
                        size: 64,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Contenido principal
            FadeInDown(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 500),
              child: Container(
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.5),
                      spreadRadius: 4,
                      blurRadius: 6,
                      offset: const Offset(2, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        widget.content.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Categoría
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.content.category,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Descripción
                      Text(
                        widget.content.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),

                      const SizedBox(height: 20),

                      // Contenido principal
                      Text(
                        widget.content.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),

                      const SizedBox(height: 24),

                      // Botón de completado
                      if (widget.showCompletionButton) _buildCompletionButton(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCompleted ? null : _markAsCompleted,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isCompleted ? AppColors.success : AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isCompleted ? 'Completado' : 'Marcar como Completado',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _markAsCompleted() {
    setState(() {
      _isCompleted = true;
    });

    // Mostrar snackbar de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Contenido marcado como completado!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // Llamar callback si existe
    widget.onCompleted?.call();
  }
}

/// Widget para mostrar una lista de contenido educativo
class EducationalContentListWidget extends StatelessWidget {
  final List<EducationalContent> contentList;
  final Function(EducationalContent)? onContentTap;
  final Function(EducationalContent)? onContentCompleted;

  const EducationalContentListWidget({
    super.key,
    required this.contentList,
    this.onContentTap,
    this.onContentCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (contentList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay contenido disponible',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contentList.length,
      itemBuilder: (context, index) {
        final content = contentList[index];
        return _buildContentCard(context, content);
      },
    );
  }

  Widget _buildContentCard(BuildContext context, EducationalContent content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => onContentTap?.call(content),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen del contenido
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Builder(
                  builder: (context) {
                    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
                    final cacheSize = (80 * devicePixelRatio).round();
                    return Image.asset(
                      content.imageUrl,
                      width: 80,
                      height: 80,
                      cacheWidth: cacheSize,
                      cacheHeight: cacheSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.library_books,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Información del contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            content.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (content.isCompleted)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 20,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

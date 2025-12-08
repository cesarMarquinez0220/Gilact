import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/educational_content_bloc.dart';
import '../widgets/educational_content_widget.dart';
import '../../../../core/theme/app_colors.dart';

class BeneficiosBebePage extends StatelessWidget {
  const BeneficiosBebePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficios para el Bebé'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showInfo(context),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: BlocBuilder<EducationalContentBloc, EducationalContentState>(
        builder: (context, state) {
          if (state is EducationalContentLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          } else if (state is EducationalContentFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar contenido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          } else if (state is EducationalContentLoaded) {
            // Buscar contenido específico de beneficios del bebé
            final beneficiosContent = state.content
                .where(
                  (content) =>
                      content.category.toLowerCase().contains('beneficios'),
                )
                .firstOrNull;

            if (beneficiosContent != null) {
              return EducationalContentWidget(
                content: beneficiosContent,
                onCompleted: () =>
                    _markAsCompleted(context, beneficiosContent.id),
              );
            } else {
              return _buildDefaultContent(context);
            }
          } else {
            return _buildDefaultContent(context);
          }
        },
      ),
    );
  }

  Widget _buildDefaultContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen del contenido
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.width * 0.45,
              child: Image.asset(
                "assets/tips/3_BENEFICIOS.png",
                cacheHeight: (MediaQuery.of(context).size.height * 0.35 * MediaQuery.of(context).devicePixelRatio).toInt(),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.child_care,
                      color: AppColors.primary,
                      size: 64,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Contenido del tip
            Container(
              width: double.infinity,
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
                    // Título del tip
                    const Text(
                      'Beneficios de la Lactancia para el Bebé',
                      style: TextStyle(
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
                      child: const Text(
                        'Beneficios',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Texto del tip
                    const Text(
                      'La lactancia materna proporciona múltiples beneficios para el desarrollo y la salud del bebé, incluyendo protección contra enfermedades y un mejor desarrollo cognitivo.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),

                    const SizedBox(height: 20),

                    // Beneficios principales
                    const Text(
                      'Beneficios principales:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildBenefitItem(
                      Icons.health_and_safety,
                      'Protección inmunológica',
                      'Fortalece el sistema inmunológico del bebé',
                    ),
                    _buildBenefitItem(
                      Icons.psychology,
                      'Desarrollo cognitivo',
                      'Mejora el desarrollo del cerebro y las capacidades cognitivas',
                    ),
                    _buildBenefitItem(
                      Icons.favorite,
                      'Vínculo emocional',
                      'Fortalece el vínculo entre madre e hijo',
                    ),
                    _buildBenefitItem(
                      Icons.local_hospital,
                      'Prevención de enfermedades',
                      'Reduce el riesgo de infecciones y enfermedades crónicas',
                    ),
                    _buildBenefitItem(
                      Icons.trending_up,
                      'Crecimiento óptimo',
                      'Proporciona todos los nutrientes necesarios para un crecimiento saludable',
                    ),

                    const SizedBox(height: 24),

                    // Botón de completado
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            _markAsCompleted(context, 'beneficios_bebe'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Marcar como Completado',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _markAsCompleted(BuildContext context, String contentId) {
    context.read<EducationalContentBloc>().add(
      MarkEducationalContentAsCompletedRequested(contentId: contentId),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Contenido marcado como completado!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información'),
        content: const Text(
          'Los beneficios de la lactancia materna para el bebé son múltiples y están científicamente comprobados. La leche materna es el alimento más completo y natural para el desarrollo del bebé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/educational_content_bloc.dart';
import '../widgets/educational_content_widget.dart';
import '../../../../core/theme/app_colors.dart';

class LactanciaExitosaPage extends StatelessWidget {
  const LactanciaExitosaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lactancia Exitosa'),
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
            // Buscar contenido específico de lactancia exitosa
            final lactanciaContent = state.content
                .where(
                  (content) =>
                      content.category.toLowerCase().contains('lactancia'),
                )
                .firstOrNull;

            if (lactanciaContent != null) {
              return EducationalContentWidget(
                content: lactanciaContent,
                onCompleted: () =>
                    _markAsCompleted(context, lactanciaContent.id),
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
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.47,
              child: Image.asset(
                "assets/tips/9_CONSEJO_LACTANCIA.png",
                cacheHeight: (MediaQuery.of(context).size.height * 0.4 * MediaQuery.of(context).devicePixelRatio).toInt(),
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
                      'Consejos para una Lactancia Exitosa',
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
                        'Lactancia',
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
                      'Una lactancia exitosa requiere paciencia, práctica y conocimiento. Aquí te compartimos consejos clave para que puedas disfrutar de esta experiencia única con tu bebé.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),

                    const SizedBox(height: 20),

                    // Consejos principales
                    const Text(
                      'Consejos clave:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildTipItem(
                      Icons.access_time,
                      'Paciencia y tiempo',
                      'La lactancia es un proceso que se aprende. No te desanimes si al principio es difícil.',
                    ),
                    _buildTipItem(
                      Icons.self_improvement,
                      'Posición correcta',
                      'Asegúrate de que el bebé esté bien posicionado y agarre correctamente el pezón.',
                    ),
                    _buildTipItem(
                      Icons.water_drop,
                      'Hidratación',
                      'Mantén una buena hidratación y una alimentación balanceada.',
                    ),
                    _buildTipItem(
                      Icons.support_agent,
                      'Busca apoyo',
                      'No dudes en buscar ayuda de profesionales o grupos de apoyo.',
                    ),
                    _buildTipItem(
                      Icons.schedule,
                      'Frecuencia adecuada',
                      'Alimenta al bebé cuando muestre señales de hambre, no por horarios rígidos.',
                    ),

                    const SizedBox(height: 20),

                    // Información adicional
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Recordatorio importante:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Cada madre y bebé son únicos. Lo que funciona para otros puede no funcionar para ti. Escucha a tu cuerpo y a tu bebé.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón de completado
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            _markAsCompleted(context, 'lactancia_exitosa'),
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

  Widget _buildTipItem(IconData icon, String title, String description) {
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
          'Una lactancia exitosa beneficia tanto a la madre como al bebé. Es importante tener paciencia y buscar apoyo cuando sea necesario.',
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

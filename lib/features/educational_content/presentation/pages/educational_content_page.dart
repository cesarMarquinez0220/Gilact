import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/educational_content.dart';
import '../bloc/educational_content_bloc.dart';
import '../../../../core/utils/responsive_helper.dart';

class EducationalContentPage extends StatefulWidget {
  const EducationalContentPage({super.key});

  @override
  State<EducationalContentPage> createState() => _EducationalContentPageState();
}

class _EducationalContentPageState extends State<EducationalContentPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todas';

  final List<String> _categories = [
    'Todas',
    'Alimentación',
    'Lactancia',
    'Beneficios',
    'Postura',
    'Calostro',
    'Consejos',
    'Extracción',
    'Higiene',
    'Padre',
    'Problemas',
  ];

  @override
  void initState() {
    super.initState();
    context.read<EducationalContentBloc>().add(
      const GetAllEducationalContentRequested(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contenido Educativo'),
        backgroundColor: const Color(0xFF03A696),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showStatistics,
            icon: const Icon(Icons.analytics),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: BlocBuilder<EducationalContentBloc, EducationalContentState>(
              builder: (context, state) {
                if (state is EducationalContentLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF03A696),
                      ),
                    ),
                  );
                } else if (state is EducationalContentFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
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
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<EducationalContentBloc>().add(
                              const GetAllEducationalContentRequested(),
                            );
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                } else if (state is EducationalContentLoaded) {
                  return _buildContentList(state.content);
                } else {
                  return const Center(
                    child: Text('No hay contenido disponible'),
                  );
                }
              },
            ),
          ),
                        if (content.isCompleted)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF03A696),
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

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<EducationalContentBloc>().add(
        SearchEducationalContentRequested(query: query),
      );
    } else {
      _filterByCategory();
    }
  }

  void _filterByCategory() {
    if (_selectedCategory == 'Todas') {
      context.read<EducationalContentBloc>().add(
        const GetAllEducationalContentRequested(),
      );
    } else {
      context.read<EducationalContentBloc>().add(
        GetEducationalContentByCategoryRequested(category: _selectedCategory),
      );
    }
  }

  void _showContentDetail(EducationalContent content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EducationalContentDetailPage(content: content),
      ),
    );
  }

  void _showStatistics() {
    context.read<EducationalContentBloc>().add(
      const GetEducationalContentStatisticsRequested(),
    );

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<EducationalContentBloc, EducationalContentState>(
        builder: (context, state) {
          if (state is EducationalContentStatisticsLoaded) {
            return AlertDialog(
              title: const Text('Estadísticas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total de contenido: ${state.statistics['totalContent']}',
                  ),
                  Text(
                    'Contenido completado: ${state.statistics['completedContent']}',
                  ),
                  Text(
                    'Tasa de finalización: ${state.statistics['completionRate']}%',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          }
          return const AlertDialog(content: CircularProgressIndicator());
        },
      ),
    );
  }
}

class EducationalContentDetailPage extends StatelessWidget {
  final EducationalContent content;

  const EducationalContentDetailPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context); // ~16 to 24
    final imageHeight = ResponsiveHelper.getResponsiveValue(context, small: 200, medium: 250, large: 300);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 24);
    final descFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final contentFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final categoryFontSize = ResponsiveHelper.getResponsiveFontSize(context, 14);

    return Scaffold(
      appBar: AppBar(
        title: Text(content.title),
        backgroundColor: const Color(0xFF03A696),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _markAsCompleted(context),
            icon: Icon(
              content.isCompleted
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del contenido
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  content.imageUrl,
                  width: double.infinity,
                  height: imageHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: imageHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF03A696).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.library_books,
                        color: const Color(0xFF03A696),
                        size: imageHeight * 0.32, // Relative size
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              content.title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),

            // Categoría
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF03A696).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                content.category,
                style: TextStyle(
                  fontSize: categoryFontSize,
                  color: const Color(0xFF03A696),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Descripción
            Text(
              content.description,
              style: TextStyle(
                fontSize: descFontSize,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Contenido principal
            Text(
              content.content,
              style: TextStyle(
                fontSize: contentFontSize,
                color: const Color(0xFF2C3E50),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markAsCompleted(BuildContext context) {
    if (!content.isCompleted) {
      context.read<EducationalContentBloc>().add(
        MarkEducationalContentAsCompletedRequested(contentId: content.id),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contenido marcado como completado'),
          backgroundColor: Color(0xFF03A696),
        ),
      );
    }
  }
}

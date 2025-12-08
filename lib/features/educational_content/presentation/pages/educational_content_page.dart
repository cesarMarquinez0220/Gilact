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
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar contenido...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterByCategory();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _filterByCategory();
                    },
                    selectedColor: const Color(
                      0xFF03A696,
                    ).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFF03A696),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList(List<EducationalContent> contentList) {
    if (contentList.isEmpty) {
      return const Center(child: Text('No hay contenido disponible'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contentList.length,
      itemBuilder: (context, index) {
        final content = contentList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showContentDetail(content),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Builder(
                      builder: (context) {
                        final devicePixelRatio = MediaQuery.of(
                          context,
                        ).devicePixelRatio;
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
                                color: const Color(
                                  0xFF03A696,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.library_books,
                                color: Color(0xFF03A696),
                                size: 32,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                content.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (content.isCompleted)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF03A696),
                                size: 20.0,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          content.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    final imageHeight = ResponsiveHelper.getResponsiveValue(
      context,
      small: 200,
      medium: 250,
      large: 300,
    );
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, 24);
    final descFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final contentFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final categoryFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      14,
    );

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
                child: Builder(
                  builder: (context) {
                    final devicePixelRatio = MediaQuery.of(
                      context,
                    ).devicePixelRatio;
                    final screenWidth = MediaQuery.of(context).size.width;
                    final cacheWidth = (screenWidth * devicePixelRatio).round();
                    final cacheHeight = (imageHeight * devicePixelRatio)
                        .round();
                    return Image.asset(
                      content.imageUrl,
                      width: double.infinity,
                      height: imageHeight.toDouble(),
                      cacheWidth: cacheWidth,
                      cacheHeight: cacheHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: imageHeight.toDouble(),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF03A696,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.library_books,
                            color: const Color(0xFF03A696),
                            size: imageHeight * 0.32, // Relative size (double)
                          ),
                        );
                      },
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
      BlocProvider.of<EducationalContentBloc>(
        context,
      ).add(MarkEducationalContentAsCompletedRequested(contentId: content.id));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contenido marcado como completado'),
          backgroundColor: Color(0xFF03A696),
        ),
      );
    }
  }
}

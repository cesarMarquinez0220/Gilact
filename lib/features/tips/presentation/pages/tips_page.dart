import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../bloc/tip_bloc.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    context.read<TipBloc>().add(const GetAllTipsRequested());
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeOutCubic,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _backgroundController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TipBloc, TipState>(
        builder: (context, state) {
          if (state is TipLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TipsLoaded) {
            return _buildTipsCarousel(state.tips);
          } else if (state is TipFailure) {
            return _buildErrorWidget(state.message);
          } else {
            return const Center(child: Text('No hay tips disponibles'));
          }
        },
      ),
    );
  }

  Widget _buildTipsCarousel(List<dynamic> tips) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF03A696), Color(0xFF26A69A), Color(0xFF4DB6AC)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Consejos de Lactancia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showFavoriteTips(),
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // PageView con tips
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  // Página cambiada - se puede usar para analytics o lógica adicional
                },
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  final tip = tips[index];
                  return _buildTipCard(tip, index);
                },
              ),
            ),

            // Indicador de páginas
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: tips.length,
                effect: const WormEffect(
                  dotColor: Colors.white54,
                  activeDotColor: Colors.white,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(dynamic tip, int index) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Imagen del tip
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        image: DecorationImage(
                          image: AssetImage('assets/tips/${tip.imageUrl}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Overlay para mejor legibilidad
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),

                          // Botón de favorito
                          Positioned(
                            top: 16,
                            right: 16,
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: IconButton(
                                    onPressed: () => _toggleFavorite(tip.id),
                                    icon: Icon(
                                      tip.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: tip.isFavorite
                                          ? Colors.red
                                          : Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Categoría
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF03A696),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tip.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Contenido del tip
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Text(
                              tip.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF7F8C8D),
                                height: 1.5,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
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
        );
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error al cargar tips',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<TipBloc>().add(const GetAllTipsRequested());
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(String tipId) {
    // Aquí implementarías la lógica para marcar/desmarcar como favorito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de favoritos en desarrollo')),
    );
  }

  void _showFavoriteTips() {
    context.read<TipBloc>().add(const GetFavoriteTipsRequested());

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<TipBloc, TipState>(
        builder: (context, state) {
          if (state is FavoriteTipsLoaded) {
            return AlertDialog(
              title: const Text('Tips Favoritos'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: state.favoriteTips.length,
                  itemBuilder: (context, index) {
                    final tip = state.favoriteTips[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/tips/${tip.imageUrl}',
                        ),
                      ),
                      title: Text(tip.title),
                      subtitle: Text(tip.category),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          } else {
            return const AlertDialog(content: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

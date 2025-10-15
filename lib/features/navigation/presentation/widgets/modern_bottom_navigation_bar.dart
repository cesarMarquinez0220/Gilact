import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

/// Widget para la barra de navegación inferior moderna que se adapta a la navegación nativa del sistema
class ModernBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener la altura de la barra de navegación del sistema
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final systemNavigationHeight = bottomPadding > 0 ? bottomPadding : 0;

    // Calcular el margen inferior dinámico
    final dynamicBottomMargin = systemNavigationHeight > 0
        ? systemNavigationHeight +
              16.0 // Espacio adicional si hay navegación nativa
        : 32.0; // Margen normal para dispositivos sin navegación nativa

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, dynamicBottomMargin),
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(
              alpha: 0.95,
            ), // Más opaco para mejor contraste
            Colors.white.withValues(alpha: 0.9),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 25),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Inicio'),
                _buildNavItem(
                  1,
                  Icons.favorite_outline,
                  Icons.favorite,
                  'Salud',
                ),
                _buildNavItem(2, Icons.person_outline, Icons.person, 'Perfil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: isSelected ? 80 : 60,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF03A696).withValues(alpha: 0.8),
                    const Color(0xFF03A696).withValues(alpha: 0.6),
                  ],
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF03A696).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: const Color(0xFF03A696).withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Efecto de brillo para elemento activo
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 1.0],
                    ),
                  ),
                ),
              ),

            // Contenido del botón
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: isSelected
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            child: Icon(
                              activeIcon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(
                                0xFF2C3E50,
                              ), // Texto oscuro para mejor contraste
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              inactiveIcon,
                              color: const Color(
                                0xFF7F8C8D,
                              ), // Icono gris para elementos no seleccionados
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(
                                0xFF7F8C8D,
                              ), // Texto gris para elementos no seleccionados
                              letterSpacing: 0.3,
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
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_state.dart';

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

    // Calcular tamaños responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isShortScreen = screenHeight < 700;

    // Ajustar altura según tamaño de pantalla
    final barHeight = isSmallScreen ? 80.0 : (isShortScreen ? 84.0 : 88.0);
    final horizontalMargin = isSmallScreen ? 12.0 : 16.0;

    // Calcular el margen inferior dinámico
    final dynamicBottomMargin = systemNavigationHeight > 0
        ? systemNavigationHeight +
              (isSmallScreen ? 12.0 : 16.0) // Espacio adicional según tamaño
        : (isSmallScreen ? 24.0 : 32.0); // Margen normal según tamaño

    return Container(
      margin: EdgeInsets.fromLTRB(
        horizontalMargin,
        0,
        horizontalMargin,
        dynamicBottomMargin,
      ),
      height: barHeight,
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
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 10 : 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  context,
                  0,
                  Icons.home_outlined,
                  Icons.home,
                  'navigation.home'.tr(),
                ),
                _buildNavItemWithBadge(
                  context,
                  1,
                  Icons.emoji_events_outlined,
                  Icons.emoji_events,
                  'navigation.companion'.tr(),
                ),
                _buildNavItem(
                  context,
                  2,
                  Icons.favorite_outline,
                  Icons.favorite,
                  'navigation.health'.tr(),
                ),
                _buildNavItem(
                  context,
                  3,
                  Icons.person_outline,
                  Icons.person,
                  'navigation.profile'.tr(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = currentIndex == index;

    // Calcular tamaños responsive basados en el ancho de pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Ajustar tamaños según el tamaño de pantalla
    final iconSize = isSelected
        ? (isSmallScreen ? 22.0 : 24.0)
        : (isSmallScreen ? 20.0 : 22.0);
    final fontSize = isSelected
        ? (isSmallScreen ? 10.0 : 11.0)
        : (isSmallScreen ? 9.0 : 10.0);
    final horizontalPadding = isSelected
        ? (isSmallScreen ? 14.0 : 18.0)
        : (isSmallScreen ? 10.0 : 12.0);
    final verticalPadding = isSelected
        ? (isSmallScreen ? 8.0 : 10.0)
        : (isSmallScreen ? 6.0 : 8.0);

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF03A696) : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF03A696).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
              size: iconSize,
            ),
            SizedBox(height: isSelected ? (isSmallScreen ? 2 : 3) : 0),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un item de navegación con badge rojo para logros nuevos
  Widget _buildNavItemWithBadge(
    BuildContext context,
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
  ) {
    return BlocBuilder<GamificationBloc, GamificationState>(
      builder: (context, state) {
        int newAchievementsCount = 0;
        if (state is GamificationLoaded) {
          newAchievementsCount = state.profile.newAchievements.length;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            _buildNavItem(context, index, inactiveIcon, activeIcon, label),
            // Badge rojo si hay logros nuevos
            if (newAchievementsCount > 0 && currentIndex != index)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    newAchievementsCount > 9 ? '9+' : '$newAchievementsCount',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

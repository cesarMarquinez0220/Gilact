import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_state.dart';
import '../../../../core/utils/responsive_helper.dart';

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

    // Calcular tamaños responsive usando ResponsiveHelper
    final isSmallScreen = ResponsiveHelper.isExtraSmall(context) || 
                         ResponsiveHelper.isSmall(context);
    final isShortScreen = ResponsiveHelper.isShortScreen(context);

    // Ajustar altura según tamaño de pantalla (más compacta en pantallas pequeñas)
    final barHeight = isSmallScreen ? 70.0 : (isShortScreen ? 76.0 : 82.0);
    final horizontalMargin = ResponsiveHelper.getResponsivePadding(context) * 0.75;

    // Calcular el margen inferior dinámico
    final dynamicBottomMargin = systemNavigationHeight > 0
        ? systemNavigationHeight +
              (isSmallScreen ? 8.0 : 12.0) // Espacio adicional según tamaño
        : (isSmallScreen ? 16.0 : 24.0); // Margen normal según tamaño

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
              horizontal: isSmallScreen ? 8.0 : 12.0,
              vertical: isSmallScreen ? 6.0 : 8.0,
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

    // Calcular tamaños responsive usando ResponsiveHelper
    final isSmallScreen = ResponsiveHelper.isExtraSmall(context) || 
                         ResponsiveHelper.isSmall(context);
    final isShortScreen = ResponsiveHelper.isShortScreen(context);

    // Ajustar tamaños según el tamaño de pantalla (más compactos)
    final iconSize = isSelected
        ? (isSmallScreen ? 20.0 : (isShortScreen ? 22.0 : 24.0))
        : (isSmallScreen ? 18.0 : (isShortScreen ? 20.0 : 22.0));
    final fontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      isSelected ? (isSmallScreen ? 9.0 : 10.0) : (isSmallScreen ? 8.5 : 9.5),
    );
    final horizontalPadding = isSelected
        ? (isSmallScreen ? 10.0 : (isShortScreen ? 14.0 : 16.0))
        : (isSmallScreen ? 8.0 : (isShortScreen ? 10.0 : 12.0));
    final verticalPadding = isSelected
        ? (isSmallScreen ? 4.0 : (isShortScreen ? 6.0 : 8.0))
        : (isSmallScreen ? 3.0 : (isShortScreen ? 4.0 : 6.0));

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
                size: iconSize,
              ),
            ),
            if (isSelected) SizedBox(height: isSmallScreen ? 1.0 : 2.0),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
                  letterSpacing: 0.2,
                  height: 1.0, // Reducir altura de línea para evitar overflow
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
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

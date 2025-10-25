import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/sleep_record.dart';
import '../../data/services/notification_handler.dart';
import '../widgets/sleep_quick_access_widget.dart';

/// Ejemplo de cómo integrar el sistema de notificaciones de sueño en la página principal
class HomePageWithSleepIntegration extends StatelessWidget {
  const HomePageWithSleepIntegration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Gilact - Inicio',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Widget de acceso rápido al registro de sueño
            const SleepQuickAccessWidget(),

            // Contenido existente de la página
            _buildExistingContent(),

            // Botón compacto para acceso rápido
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: SleepQuickButton()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToSettings(context),
                      icon: const Icon(Icons.settings),
                      label: const Text('Configurar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contenido Existente',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aquí puedes agregar el contenido existente de tu página principal. El sistema de notificaciones de sueño se integra perfectamente con tu UI actual.',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Ejemplo de estadísticas rápidas
          SleepStatsWidget(
            totalRecords: 15,
            totalSleepTime: const Duration(hours: 8, minutes: 30),
            mostCommonQuality: SleepQuality.good,
          ),
        ],
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/sleep_notification_settings');
  }
}

/// Ejemplo de cómo agregar el botón de acceso rápido a una AppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Gilact',
        style: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      actions: [
        // Botón de acceso rápido al registro de sueño
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SleepQuickButton(),
        ),

        // Botón de configuración
        IconButton(
          onPressed: () =>
              Navigator.of(context).pushNamed('/sleep_notification_settings'),
          icon: const Icon(Icons.settings, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Ejemplo de cómo agregar el widget a un BottomNavigationBar
class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home, 'Inicio', () {}),
              _buildNavItem(Icons.bedtime, 'Sueño', () {
                Navigator.of(context).pushNamed('/sleep_record');
              }),
              _buildNavItem(Icons.settings, 'Config', () {
                Navigator.of(context).pushNamed('/sleep_notification_settings');
              }),
              _buildNavItem(Icons.timer, 'Prueba', () async {
                await NotificationHandler.scheduleMinuteRemindersForTesting();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notificaciones cada 2 minutos programadas'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

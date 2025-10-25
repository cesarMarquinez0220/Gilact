import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../alerta_dialoge.dart';
import '../../data/services/sleep_notification_service.dart';

/// Página para configurar las notificaciones de recordatorio de sueño
class SleepNotificationSettingsPage extends StatefulWidget {
  const SleepNotificationSettingsPage({super.key});

  @override
  State<SleepNotificationSettingsPage> createState() =>
      _SleepNotificationSettingsPageState();
}

class _SleepNotificationSettingsPageState
    extends State<SleepNotificationSettingsPage>
    with TickerProviderStateMixin {
  final SleepNotificationService _notificationService =
      GetIt.instance<SleepNotificationService>();

  List<int> _selectedHours = [];
  bool _notificationsEnabled = false;
  bool _isLoading = false;
  String _babyName = 'tu bebé';

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hours = await _notificationService.getReminderHours();
      final hasReminders = await _notificationService.hasRemindersConfigured();

      setState(() {
        _selectedHours = hours;
        _notificationsEnabled = hasReminders;
      });
    } catch (e) {
      print('Error cargando configuración: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Recordatorios de Sueño',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [_buildHeader(), _buildSettingsContent()],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Icono principal
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 40,
              ),
            ),

            const SizedBox(height: 16),

            // Título
            Text(
              'Recordatorios de Sueño',
              style: GoogleFonts.quicksand(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Subtítulo
            Text(
              'Configura cuándo recibir recordatorios para registrar las horas de sueño',
              style: GoogleFonts.quicksand(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Switch de activación
              _buildEnableSwitch(),

              const SizedBox(height: 20),

              // Selector de horas
              if (_notificationsEnabled) _buildHourSelector(),

              const SizedBox(height: 20),

              // Botones de acción
              _buildActionButtons(),

              const SizedBox(height: 20),

              // Botón de prueba
              _buildTestButton(),

              const SizedBox(height: 16),

              // Botón de notificaciones cada minuto
              _buildMinuteRemindersButton(),

              const SizedBox(height: 16),

              // Botón de notificación inmediata
              _buildImmediateTestButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnableSwitch() {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _notificationsEnabled
                  ? AppColors.success.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: _notificationsEnabled ? AppColors.success : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activar Recordatorios',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recibe notificaciones para recordar registrar el sueño',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                if (!value) {
                  _selectedHours.clear();
                }
              });
            },
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildHourSelector() {
    return Container(
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.access_time,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Horarios de Recordatorio',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Selecciona las horas en las que quieres recibir recordatorios:',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Grid de horas
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(24, (index) {
              final hour = index;
              final isSelected = _selectedHours.contains(hour);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedHours.remove(hour);
                    } else {
                      _selectedHours.add(hour);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          if (_selectedHours.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recordatorios programados para ${_selectedHours.length} hora(s)',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Guardar Configuración',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _testNotification,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Probar Notificación',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildMinuteRemindersButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _scheduleMinuteReminders,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warning,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Notificaciones Cada 2 Minutos (Prueba)',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildImmediateTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _scheduleImmediateTest,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Notificación Inmediata (Prueba)',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_notificationsEnabled) {
      await _notificationService.cancelAllSleepReminders();
      DialogExample.showSuccessDialog(
        context,
        'Configuración Guardada',
        'Los recordatorios han sido desactivados.',
        () => Navigator.of(context).pop(),
      );
      return;
    }

    if (_selectedHours.isEmpty) {
      DialogExample.showErrorDialog(
        context,
        'Error de Configuración',
        'Por favor selecciona al menos una hora para los recordatorios.',
      );
      return;
    }

    try {
      await _notificationService.scheduleSleepReminders(
        reminderHours: _selectedHours,
        babyName: _babyName,
      );

      DialogExample.showSuccessDialog(
        context,
        'Configuración Guardada',
        'Los recordatorios han sido configurados exitosamente.',
        () => Navigator.of(context).pop(),
      );
    } catch (e) {
      DialogExample.showErrorDialog(
        context,
        'Error',
        'No se pudo guardar la configuración. Inténtalo nuevamente.',
      );
    }
  }

  Future<void> _testNotification() async {
    try {
      await _notificationService.showTestNotification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación de prueba enviada'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      DialogExample.showErrorDialog(
        context,
        'Error',
        'No se pudo enviar la notificación de prueba.',
      );
    }
  }

  Future<void> _scheduleMinuteReminders() async {
    try {
      await _notificationService.scheduleMinuteReminders(babyName: _babyName);

      DialogExample.showSuccessDialog(
        context,
        'Notificaciones Programadas',
        'Se han programado 10 notificaciones cada 2 minutos para pruebas. Las notificaciones aparecerán cada 2 minutos durante los próximos 20 minutos.',
        () => Navigator.of(context).pop(),
      );
    } catch (e) {
      DialogExample.showErrorDialog(
        context,
        'Error',
        'No se pudieron programar las notificaciones: $e',
      );
    }
  }

  Future<void> _scheduleImmediateTest() async {
    try {
      await _notificationService.scheduleImmediateTestNotification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación inmediata enviada - Revisa los logs'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      DialogExample.showErrorDialog(
        context,
        'Error',
        'No se pudo enviar la notificación inmediata: $e',
      );
    }
  }
}

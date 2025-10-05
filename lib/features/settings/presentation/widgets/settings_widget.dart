import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/settings_entities.dart';

class SettingsWidget extends StatefulWidget {
  final AppConfiguration configuration;
  final Function(Map<String, dynamic>) onConfigurationChanged;

  const SettingsWidget({
    super.key,
    required this.configuration,
    required this.onConfigurationChanged,
  });

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late AppConfiguration _currentConfiguration;

  @override
  void initState() {
    super.initState();
    _currentConfiguration = widget.configuration;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notificaciones
            _buildSwitchTile(
              'Notificaciones',
              'Recibir notificaciones de la aplicación',
              _currentConfiguration.notificationsEnabled,
              (value) => _updateConfiguration('notificationsEnabled', value),
              Icons.notifications_outlined,
            ),

            const SizedBox(height: 16),

            // Modo oscuro
            _buildSwitchTile(
              'Modo Oscuro',
              'Activar tema oscuro',
              _currentConfiguration.darkMode,
              (value) => _updateConfiguration('darkMode', value),
              Icons.dark_mode_outlined,
            ),

            const SizedBox(height: 16),

            // Sonido
            _buildSwitchTile(
              'Sonido',
              'Activar sonidos de la aplicación',
              _currentConfiguration.soundEnabled,
              (value) => _updateConfiguration('soundEnabled', value),
              Icons.volume_up_outlined,
            ),

            const SizedBox(height: 16),

            // Vibración
            _buildSwitchTile(
              'Vibración',
              'Activar vibración en notificaciones',
              _currentConfiguration.vibrationEnabled,
              (value) => _updateConfiguration('vibrationEnabled', value),
              Icons.vibration_outlined,
            ),

            const SizedBox(height: 16),

            // Guardar progreso automáticamente
            _buildSwitchTile(
              'Guardar Progreso',
              'Guardar progreso automáticamente',
              _currentConfiguration.autoSaveProgress,
              (value) => _updateConfiguration('autoSaveProgress', value),
              Icons.save_outlined,
            ),

            const SizedBox(height: 16),

            // Mostrar consejos
            _buildSwitchTile(
              'Mostrar Consejos',
              'Mostrar consejos y tips',
              _currentConfiguration.showTips,
              (value) => _updateConfiguration('showTips', value),
              Icons.lightbulb_outline,
            ),

            const SizedBox(height: 16),

            // Idioma
            _buildDropdownTile(
              'Idioma',
              'Seleccionar idioma de la aplicación',
              _currentConfiguration.language,
              ['es', 'en'],
              ['Español', 'English'],
              (value) => _updateConfiguration('language', value),
              Icons.language_outlined,
            ),

            const SizedBox(height: 16),

            // Tamaño de fuente
            _buildDropdownTile(
              'Tamaño de Fuente',
              'Seleccionar tamaño de fuente',
              _currentConfiguration.fontSize,
              ['small', 'medium', 'large'],
              ['Pequeño', 'Mediano', 'Grande'],
              (value) => _updateConfiguration('fontSize', value),
              Icons.text_fields_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    List<String> displayOptions,
    Function(String) onChanged,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        DropdownButton<String>(
          value: value,
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: options.asMap().entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.value,
              child: Text(
                displayOptions[entry.key],
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          underline: Container(height: 1, color: AppColors.primary),
        ),
      ],
    );
  }

  void _updateConfiguration(String key, dynamic value) {
    setState(() {
      _currentConfiguration = AppConfiguration(
        id: _currentConfiguration.id,
        userId: _currentConfiguration.userId,
        notificationsEnabled: key == 'notificationsEnabled'
            ? value
            : _currentConfiguration.notificationsEnabled,
        analyticsEnabled: key == 'analyticsEnabled'
            ? value
            : _currentConfiguration.analyticsEnabled,
        crashReportingEnabled: key == 'crashReportingEnabled'
            ? value
            : _currentConfiguration.crashReportingEnabled,
        language: key == 'language' ? value : _currentConfiguration.language,
        theme: key == 'theme' ? value : _currentConfiguration.theme,
        autoSaveProgress: key == 'autoSaveProgress'
            ? value
            : _currentConfiguration.autoSaveProgress,
        showTips: key == 'showTips' ? value : _currentConfiguration.showTips,
        darkMode: key == 'darkMode' ? value : _currentConfiguration.darkMode,
        fontSize: key == 'fontSize' ? value : _currentConfiguration.fontSize,
        soundEnabled: key == 'soundEnabled'
            ? value
            : _currentConfiguration.soundEnabled,
        vibrationEnabled: key == 'vibrationEnabled'
            ? value
            : _currentConfiguration.vibrationEnabled,
        createdAt: _currentConfiguration.createdAt,
        updatedAt: DateTime.now(),
      );
    });

    widget.onConfigurationChanged({key: value});
  }
}

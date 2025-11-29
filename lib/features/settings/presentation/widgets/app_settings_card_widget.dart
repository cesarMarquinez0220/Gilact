import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/widgets/interactive_button.dart';

/// Widget responsive para mostrar las configuraciones de la aplicación
class AppSettingsCardWidget extends StatelessWidget {
  final Map<String, dynamic> localSettings;
  final Function(String, dynamic) onSettingChanged;

  const AppSettingsCardWidget({
    super.key,
    required this.localSettings,
    required this.onSettingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final maxWidth = constraints.maxWidth > 600
            ? 600.0
            : constraints.maxWidth;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600
                ? (constraints.maxWidth - 600) / 2
                : 0,
          ),
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
              _buildSettingSwitch(
                context,
                'settings.sound'.tr(),
                'settings.soundDescription'.tr(),
                Icons.volume_up_outlined,
                localSettings['soundEnabled'] ?? true,
                (value) => onSettingChanged('soundEnabled', value),
                isSmallScreen,
              ),
              const Divider(height: 1),
              _buildSettingSwitch(
                context,
                'settings.vibration'.tr(),
                'settings.vibrationDescription'.tr(),
                Icons.vibration,
                localSettings['vibrationEnabled'] ?? true,
                (value) => onSettingChanged('vibrationEnabled', value),
                isSmallScreen,
              ),
              const Divider(height: 1),
              _buildSettingSwitch(
                context,
                'settings.autoSave'.tr(),
                'settings.autoSaveDescription'.tr(),
                Icons.save_outlined,
                localSettings['autoSaveProgress'] ?? true,
                (value) => onSettingChanged('autoSaveProgress', value),
                isSmallScreen,
              ),
              const Divider(height: 1),
              _buildSettingTile(
                context,
                'settings.language'.tr(),
                _getLanguageDisplayName(localSettings['language'] ?? 'es'),
                Icons.language,
                () => _showLanguageSelector(context),
                isSmallScreen,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingSwitch(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    bool isSmallScreen,
  ) {
    // Determinar si debemos habilitar sonido/vibración según el tipo de switch
    final isSoundSwitch = title == 'Sonido';
    final isVibrationSwitch = title == 'Vibración';

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 8 : 12,
      ),
      leading: Icon(icon, color: const Color(0xFF03A696)),
      title: Text(
        title,
        style: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: isSmallScreen ? 14 : 16,
          color: const Color(0xFF2C3E50),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.quicksand(
          fontSize: isSmallScreen ? 11 : 12,
          color: const Color(0xFF7F8C8D),
        ),
      ),
      trailing: InteractiveSwitch(
        value: value,
        onChanged: onChanged,
        enableSound:
            !isSoundSwitch, // No reproducir sonido al cambiar el switch de sonido
        enableVibration:
            !isVibrationSwitch, // No vibrar al cambiar el switch de vibración
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isSmallScreen,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 8 : 12,
      ),
      leading: Icon(icon, color: const Color(0xFF03A696)),
      title: Text(
        title,
        style: GoogleFonts.quicksand(
          fontWeight: FontWeight.w500,
          fontSize: isSmallScreen ? 14 : 16,
          color: const Color(0xFF2C3E50),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.quicksand(
          fontSize: isSmallScreen ? 11 : 12,
          color: const Color(0xFF7F8C8D),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'es':
        return 'settings.spanish'.tr();
      case 'en':
        return 'settings.english'.tr();
      default:
        return 'settings.spanish'.tr();
    }
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        // Padding solo arriba y a los lados.
        // Abajo ponemos 0 o algo pequeño fijo, porque el SafeArea se encarga del resto.
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'settings.selectLanguage'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                context,
                'es',
                'settings.spanish'.tr(),
                localSettings['language'] ?? 'es',
              ),
              _buildLanguageOption(
                context,
                'en',
                'settings.english'.tr(),
                localSettings['language'] ?? 'es',
              ),
              // Solo un pequeño espacio estético fijo al final (no calculado)
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String code,
    String name,
    String currentLanguage,
  ) {
    final isSelected = currentLanguage == code;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.language,
        color: isSelected ? const Color(0xFF03A696) : const Color(0xFF7F8C8D),
      ),
      title: Text(
        name,
        style: GoogleFonts.quicksand(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? const Color(0xFF03A696) : const Color(0xFF2C3E50),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF03A696))
          : null,
      onTap: () async {
        if (isSelected) {
          Navigator.of(context).pop();
          return;
        }

        Navigator.of(context).pop();
        onSettingChanged('language', code);

        // Cambiar idioma en EasyLocalization
        await context.setLocale(Locale(code));

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('languageChanged'.tr(namedArgs: {'language': name})),
            backgroundColor: const Color(0xFF03A696),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}

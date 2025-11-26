import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../pages/lactation_record_page.dart';
import '../pages/lactation_calendar_page.dart';
import '../pages/lactation_flow_page_enhanced.dart';
import '../../data/services/lactation_service.dart';
import '../../domain/entities/lactation_record.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

// Colores de la aplicación
class _AppColors {
  static const Color primary = Color(0xFF03A696);
}

/// Widget inteligente que decide entre popup rápido o pantalla completa
/// según el contexto y preferencias del usuario
class SmartLactationButton extends StatefulWidget {
  final DateTime? selectedDate;
  final String? existingRecordId;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const SmartLactationButton({
    super.key,
    this.selectedDate,
    this.existingRecordId,
    this.onSuccess,
    this.onCancel,
  });

  @override
  State<SmartLactationButton> createState() => _SmartLactationButtonState();
}

class _SmartLactationButtonState extends State<SmartLactationButton> {
  late LactationService _lactationService;
  final AppLogger _logger = getIt<AppLogger>();
  List<LactationRecord> _preloadedRecords = [];
  bool _isDataPreloaded = false;
  bool _isPreloading = false;

  @override
  void initState() {
    super.initState();
    _lactationService = LactationService(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
    _preloadData();
  }

  Future<void> _preloadData() async {
    if (_isPreloading) return;

    if (mounted) {
      setState(() {
        _isPreloading = true;
      });
    }

    try {
      _logger.d('SmartLactationButton: Precargando datos...');

      // Precargar datos del día actual
      final today = widget.selectedDate ?? DateTime.now();
      final dayRecords = await _lactationService.getRecordsForDate(today);

      // Precargar datos del mes para el calendario
      final monthRecords = await _lactationService.getRecordsForMonth(today);

      _logger.d(
        'SmartLactationButton: dayRecords = ${dayRecords.length}, monthRecords = ${monthRecords.length}',
      );

      if (mounted) {
        setState(() {
          // Evitar duplicados: usar monthRecords que ya incluye los registros del día
          // porque getRecordsForMonth incluye todo el mes
          _preloadedRecords = monthRecords;
          _isDataPreloaded = true;
          _isPreloading = false;
        });
      }

      _logger.d(
        'SmartLactationButton: _preloadedRecords final = ${_preloadedRecords.length}',
      );
      _logger.success('SmartLactationButton: Datos precargados exitosamente');
    } catch (e, stackTrace) {
      _logger.e('SmartLactationButton: Error precargando datos', e, stackTrace);
      if (mounted) {
        setState(() {
          _isPreloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón principal - Registro Inteligente
        _buildMainButton(context),

        const SizedBox(height: 12),

        // Opciones adicionales
        _buildAdditionalOptions(context),
      ],
    );
  }

  Widget _buildMainButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            _AppColors.primary,
            _AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSmartLactationFlow(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icono principal
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flash_on,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'home.registerLactation'.tr(),
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'home.quickRegister'.tr(),
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Flecha
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions(BuildContext context) {
    return Row(
      children: [
        // Registro rápido
        Expanded(child: _buildQuickButton(context)),

        const SizedBox(width: 12),

        // Registro completo
        Expanded(child: _buildFullButton(context)),
      ],
    );
  }

  Widget _buildQuickButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showQuickDialog(context),
      icon: const Icon(Icons.child_care, size: 18),
      label: Text(
        'home.complete'.tr(),
        style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: _AppColors.primary.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildFullButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showFullScreen(context),
      icon: const Icon(Icons.calendar_month, size: 18),
      label: Text(
        'home.register'.tr(),
        style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: _AppColors.primary.withValues(alpha: 0.5)),
      ),
    );
  }

  /// Navega al formulario completo de registro de lactancia
  void _showSmartLactationFlow(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => LactationFlowPage(
              selectedDate: widget.selectedDate,
              existingRecord: null,
            ),
          ),
        )
        .then((result) {
          if (result == true) {
            widget.onSuccess?.call();
          }
        });
  }

  /// Navega al registro completo de lactancia
  void _showQuickDialog(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => LactationRecordPage(
              selectedDate: widget.selectedDate,
              existingRecord:
                  null, // Puedes pasar un registro existente si lo tienes
            ),
          ),
        )
        .then((result) {
          if (result == true) {
            widget.onSuccess?.call();
          }
        });
  }

  /// Navega al calendario de lactancia con datos precargados
  void _showFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LactationCalendarPage(
          preloadedRecords: _isDataPreloaded ? _preloadedRecords : null,
        ),
      ),
    );
  }
}

/// Widget para mostrar sugerencias inteligentes
class LactationSuggestions extends StatelessWidget {
  final Map<String, dynamic> userStats;
  final Function(String) onSuggestionSelected;

  const LactationSuggestions({
    super.key,
    required this.userStats,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = _getSuggestions();

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: _AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sugerencias Inteligentes',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return _buildSuggestionChip(suggestion);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return ActionChip(
      label: Text(
        suggestion,
        style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      onPressed: () => onSuggestionSelected(suggestion),
      backgroundColor: Colors.white,
      side: BorderSide(color: _AppColors.primary.withValues(alpha: 0.3)),
      labelStyle: const TextStyle(color: _AppColors.primary),
    );
  }

  List<String> _getSuggestions() {
    final suggestions = <String>[];

    // Basado en estadísticas del usuario
    final preferredType = userStats['preferredFeedingType'] ?? 'breast';
    final avgDuration = userStats['avgDuration'] ?? 15;

    if (preferredType == 'breast') {
      suggestions.add('🤱 Lactancia Materna');
      suggestions.add('${avgDuration.round()} min');
    } else if (preferredType == 'bottle') {
      suggestions.add('🍶 Biberón');
      final avgVolume = userStats['avgExtraction'] ?? 120;
      suggestions.add('${avgVolume.round()} ml');
    }

    return suggestions;
  }
}

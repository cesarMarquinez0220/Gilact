import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../alerta_dialoge.dart'; // Assuming this provides DialogExample
import '../../../../core/services/app_initialization_service.dart' as app_init;
import '../../../../core/di/injection.dart';
import '../../domain/entities/lactation_record.dart'; // Assuming this defines LactationRecord
import '../../data/services/lactation_service.dart';

class LactationRecordPage extends StatefulWidget {
  final DateTime? selectedDate;
  final LactationRecord? existingRecord;

  const LactationRecordPage({Key? key, this.selectedDate, this.existingRecord})
    : super(key: key);

  @override
  State<LactationRecordPage> createState() => _LactationRecordPageState();
}

// --- REMOVED: Unused _RecordFlowStep enum ---

class _LactationRecordPageState extends State<LactationRecordPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final LactationService _lactationService = getIt<LactationService>();

  // Data map for the accordion flow
  Map<String, dynamic> _flowData = {};

  // Controllers for manual inputs within the accordion
  final _manualBreastDurationController = TextEditingController();
  final _manualBottleVolumeController = TextEditingController();
  final _manualSleepTimeController = TextEditingController();
  // --- REMOVED: _manualBreastSideController (not used in provided accordion UI) ---

  // Units (kept for manual input context)
  String _volumeUnit = 'ml'; // ml or oz
  String _durationUnit = 'min'; // min or hr
  String _sleepUnit = 'hr'; // min or hr

  // States for accordion expansion
  bool _showBreastSideOptions = false;
  bool _showBottleVolumeOptions = false;

  bool _isLoading = false;

  // Animation controller for background
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeFlowData(); // Initialize based on existingRecord or defaults
  }

  // Populate _flowData and accordion state from existing record or set defaults
  void _initializeFlowData() {
    if (widget.existingRecord != null) {
      final record = widget.existingRecord!;

      // Determinar tipo de alimentación basado en el tipo de lactancia y los contadores
      if (record.vecesPecho > 0 && record.vecesBiberon > 0) {
        _flowData['alimentacion'] = 'mixto';
      } else if (record.vecesPecho > 0) {
        _flowData['alimentacion'] = 'pecho';
      } else if (record.vecesBiberon > 0) {
        _flowData['alimentacion'] = 'biberon';
      } else {
        // Fallback basado en el tipo de lactancia
        _flowData['alimentacion'] = record.tipo == LactationType.bottle
            ? 'biberon'
            : 'pecho';
      }

      // Mapear lado del pecho (normalizar los valores)
      if (record.lado != null && record.lado != 'Ninguna') {
        String? mappedSide;
        final ladoLower = record.lado!.toLowerCase();
        if (ladoLower.contains('izquierdo') || ladoLower == 'izquierdo') {
          mappedSide = 'izquierdo';
        } else if (ladoLower.contains('derecho') || ladoLower == 'derecho') {
          mappedSide = 'derecho';
        } else if (ladoLower.contains('ambos') || ladoLower == 'ambos') {
          mappedSide = 'ambos';
        } else {
          mappedSide = null;
        }
        _flowData['breastSide'] = mappedSide;
      }

      // Mapear duración (en minutos)
      if (record.duracion.inMinutes > 0) {
        _flowData['duration'] = record.duracion.inMinutes.toString();
        // Pre-llenar el controlador manual si aplica
        _manualBreastDurationController.text = record.duracion.inMinutes
            .toString();
      }

      // Mapear volumen de biberón
      if (record.volumenExtraccion > 0) {
        _flowData['volume'] = record.volumenExtraccion.toString();
        // Pre-llenar el controlador manual si aplica
        _manualBottleVolumeController.text = record.volumenExtraccion
            .toString();
      }

      // Mapear horas de sueño (solo si el registro incluye sueño)
      if (record.incluyeSueno && record.horasSuenoBebe > 0) {
        _flowData['sleep'] = record.horasSuenoBebe.toString();
        // Pre-llenar el controlador manual
        _manualSleepTimeController.text = record.horasSuenoBebe.toString();
      }

      // Configurar unidades basadas en el registro
      if (record.unidadVolumen.isNotEmpty && record.unidadVolumen != 'No') {
        _volumeUnit = record.unidadVolumen.toLowerCase();
      }
      if (record.unidadSueno.isNotEmpty && record.unidadSueno != 'No') {
        _sleepUnit = record.unidadSueno.toLowerCase();
      }

      // Set accordion visibility based on populated data
      final alimentacion = _flowData['alimentacion'];
      _showBreastSideOptions =
          alimentacion == 'pecho' || alimentacion == 'mixto';
      _showBottleVolumeOptions =
          alimentacion == 'biberon' || alimentacion == 'mixto';
    } else {
      // Default state for a new record
      _flowData = {};
      _showBreastSideOptions = false;
      _showBottleVolumeOptions = false;
    }
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    // Dispose only the used controllers
    _manualBreastDurationController.dispose();
    _manualBottleVolumeController.dispose();
    _manualSleepTimeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // --- Firestore Helper ---
  DocumentReference? _getUserSituationDocRef(String? userDocId) {
    if (userDocId == null) return null;
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userDocId)
        .collection('situacion')
        .doc('seleccion');
  }

  CollectionReference? _getLactationCollectionRef(
    DocumentReference? situationDocRef,
  ) {
    if (situationDocRef == null) return null;
    return situationDocRef.collection('lactancia');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // ... (AppBar remains the same)
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.existingRecord != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _eliminarRegistro,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          // ... (Gradient remains the same)
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(overscroll: false),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    // Keep Form if validation is needed on manual inputs
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Header Section (moved _buildHeader here for clarity)
                        _buildHeader(),
                        const SizedBox(height: 30),
                        // Accordion Form Content
                        _buildAccordionForm(), // This now contains the main UI logic
                        const SizedBox(height: 40),
                        // Action Buttons (Simplified)
                        _buildSaveAndCancelButtons(), // Use simplified buttons
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Linear Progressive Disclosure Form
  Widget _buildAccordionForm() {
    final hasSelection = _flowData.containsKey('alimentacion');
    final selectedType = _flowData['alimentacion'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('lactation.recordForm.feedingTypeQuestion'.tr()),
        const SizedBox(height: 16),

        // --- Show all options OR only the selected one ---
        if (!hasSelection)
        // Initial state: Show all three options
        ...[
          _buildFeedingTypeOption(
            title: 'lactation.recordForm.breast'.tr(),
            description: 'lactation.recordForm.breastDescription'.tr(),
            icon: Icons.accessibility_new,
            value: 'pecho',
          ),
          const SizedBox(height: 12),
          _buildFeedingTypeOption(
            title: 'lactation.recordForm.bottle'.tr(),
            description: 'lactation.recordForm.bottleDescription'.tr(),
            icon: Icons.baby_changing_station,
            value: 'biberon',
          ),
          const SizedBox(height: 12),
          _buildFeedingTypeOption(
            title: 'lactation.recordForm.mixed'.tr(),
            description: 'lactation.recordForm.mixedDescription'.tr(),
            icon: Icons.all_inclusive,
            value: 'mixto',
          ),
        ] else
        // Selected state: Show only selected type and its details
        ...[
          // Show selected option as header
          _buildSelectedFeedingHeader(selectedType!),
          const SizedBox(height: 16),

          // Progressive disclosure: Show relevant details based on selection
          if (selectedType == 'pecho' || selectedType == 'mixto') ...[
            _buildBreastSideOptions(),
            const SizedBox(height: 20),
            _buildBreastDurationOptions(),
            const SizedBox(height: 20),
          ],

          if (selectedType == 'biberon' || selectedType == 'mixto') ...[
            _buildBottleVolumeOptions(),
            const SizedBox(height: 20),
          ],

          // Show sleep section right after the feeding details
          _buildSleepTimeSection(),
        ],
      ],
    );
  }

  // NEW: Simple feeding type option (for initial selection)
  Widget _buildFeedingTypeOption({
    required String title,
    required String description,
    required IconData icon,
    required String value,
  }) {
    return GestureDetector(
      onTap: () => _toggleAccordionSection(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.quicksand(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // NEW: Selected feeding type as header (with option to change)
  Widget _buildSelectedFeedingHeader(String selectedType) {
    String title = '';
    String description = '';
    IconData icon;

    switch (selectedType) {
      case 'pecho':
        title = 'lactation.recordForm.breast'.tr();
        description = 'lactation.recordForm.breastDescription'.tr();
        icon = Icons.accessibility_new;
        break;
      case 'biberon':
        title = 'lactation.recordForm.bottle'.tr();
        description = 'lactation.recordForm.bottleDescription'.tr();
        icon = Icons.baby_changing_station;
        break;
      case 'mixto':
        title = 'lactation.recordForm.mixed'.tr();
        description = 'lactation.recordForm.mixedDescription'.tr();
        icon = Icons.all_inclusive;
        break;
      default:
        title = 'lactation.recordForm.selectType'.tr();
        description = 'lactation.recordForm.selectTypeHint'.tr();
        icon = Icons.help_outline;
    }

    return GestureDetector(
      onTap: () => _toggleAccordionSection(selectedType),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.quicksand(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Cambiar',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to update flow data from controllers
  void _updateFlowDataFromControllers() {
    // Actualizar datos de duración si existe
    if (_manualBreastDurationController.text.isNotEmpty) {
      _flowData['duration'] = _manualBreastDurationController.text;
    }
    // Actualizar datos de volumen si existe
    if (_manualBottleVolumeController.text.isNotEmpty) {
      _flowData['volume'] = _manualBottleVolumeController.text;
    }
    // Actualizar datos de sueño si existe
    if (_manualSleepTimeController.text.isNotEmpty) {
      _flowData['sleep'] = _manualSleepTimeController.text;
    }
  }

  // Allow deselecting by clicking again
  void _toggleAccordionSection(String type) {
    setState(() {
      // If clicking the same type again, deselect it
      if (_flowData['alimentacion'] == type) {
        _flowData.remove('alimentacion');
        _showBreastSideOptions = false;
        _showBottleVolumeOptions = false;

        // Clear all data
        _flowData.clear();
        _manualBreastDurationController.clear();
        _manualBottleVolumeController.clear();
        _manualSleepTimeController.clear();
      } else {
        // Selecting a different type
        _flowData['alimentacion'] = type;
        _showBreastSideOptions = (type == 'pecho' || type == 'mixto');
        _showBottleVolumeOptions = (type == 'biberon' || type == 'mixto');

        // Reset data of sections that become hidden
        if (!_showBreastSideOptions) {
          _flowData.remove('breastSide');
          _flowData.remove('duration');
          _manualBreastDurationController.clear();
        }
        if (!_showBottleVolumeOptions) {
          _flowData.remove('volume');
          _manualBottleVolumeController.clear();
        }
      }
    });
  }

  // Helper to build section titles consistently
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.quicksand(
        fontSize: 20, // Slightly smaller for section titles
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildBreastSideOptions() {
    // Simplified: directly set _flowData['breastSide']
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'lactation.recordForm.breastSideQuestion'.tr(),
        ), // Use consistent title style
        const SizedBox(height: 12),
        Row(
          // Use Row for better layout
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildChoiceChip(
                label: 'lactation.recordForm.left'.tr(),
                value: 'izquierdo',
                groupValue: _flowData['breastSide'],
                icon: Icons.keyboard_arrow_left,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildChoiceChip(
                label: 'lactation.recordForm.right'.tr(),
                value: 'derecho',
                groupValue: _flowData['breastSide'],
                icon: Icons.keyboard_arrow_right,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildChoiceChip(
                label: 'lactation.recordForm.both'.tr(),
                value: 'ambos',
                groupValue: _flowData['breastSide'],
                icon: Icons.sync_alt,
              ),
            ),
          ],
        ),
        // Removed manual input card - not standard for side selection
      ],
    );
  }

  // Refactored Choice Chip for Side/Units
  Widget _buildChoiceChip({
    required String label,
    required String value,
    String? groupValue,
    IconData? icon,
    bool isUnitSelector = false,
    String? unitType, // 'duration', 'sleep', o 'volume'
  }) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isUnitSelector) {
            // Manejar cambio de unidades y conversión
            final String newValue = value;
            String oldUnit = '';
            String newUnit = '';
            TextEditingController? controller;

            // Identificar qué unidad estamos cambiando
            if (unitType == 'volume') {
              oldUnit = _volumeUnit;
              newUnit = newValue;
              controller = _manualBottleVolumeController;
            } else if (unitType == 'duration') {
              oldUnit = _durationUnit;
              newUnit = newValue;
              controller = _manualBreastDurationController;
            } else if (unitType == 'sleep') {
              oldUnit = _sleepUnit;
              newUnit = newValue;
              controller = _manualSleepTimeController;
            }

            // Si la unidad no cambió, no hacer nada
            if (oldUnit == newUnit) return;

            // Convertir el valor si existe
            if (controller != null && controller.text.isNotEmpty) {
              final double? currentValue = double.tryParse(controller.text);
              if (currentValue != null && currentValue > 0) {
                double convertedValue = currentValue;

                // Conversión de unidades
                if (unitType == 'volume') {
                  if (oldUnit == 'ml' && newUnit == 'oz') {
                    convertedValue = currentValue / 29.5735;
                  } else if (oldUnit == 'oz' && newUnit == 'ml') {
                    convertedValue = currentValue * 29.5735;
                  }
                } else if (unitType == 'duration' || unitType == 'sleep') {
                  if (oldUnit == 'hr' && newUnit == 'min') {
                    convertedValue = currentValue * 60;
                  } else if (oldUnit == 'min' && newUnit == 'hr') {
                    convertedValue = currentValue / 60;
                  }
                }

                // Actualizar el controlador y los datos
                controller.text = convertedValue.toStringAsFixed(
                  unitType == 'volume' ? 1 : 0,
                );
                _updateFlowDataFromControllers();
              }

              // Actualizar la unidad
              if (unitType == 'volume') {
                _volumeUnit = newUnit;
              } else if (unitType == 'duration')
                {_durationUnit = newUnit;}
              else if (unitType == 'sleep')
                {_sleepUnit = newUnit;}
            } else {
              // Si no hay valor, solo actualizar la unidad
              if (unitType == 'volume')
                {_volumeUnit = newUnit;}
              else if (unitType == 'duration')
                {_durationUnit = newUnit;}
              else if (unitType == 'sleep')
                {_sleepUnit = newUnit;}
            }
          } else {
            // No es selector de unidad, solo actualizar el valor
            _flowData['breastSide'] = value;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white.withValues(alpha: isSelected ? 1.0 : 0.7),
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Refactored Duration Options
  Widget _buildBreastDurationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('lactation.recordForm.breastDurationQuestion'.tr()),
        const SizedBox(height: 8),
        Row(
          // Unit Selector
          children: [
            _buildChoiceChip(
              label: 'min',
              value: 'min',
              groupValue: _durationUnit,
              isUnitSelector: true,
              unitType: 'duration',
            ),
            const SizedBox(width: 12),
            _buildChoiceChip(
              label: 'hr',
              value: 'hr',
              groupValue: _durationUnit,
              isUnitSelector: true,
              unitType: 'duration',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Quick selection chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [5, 10, 15, 20]
              .map(
                (val) => _buildQuickValueChip(
                  value: val.toString(),
                  unit: _durationUnit,
                  groupValue: _flowData['duration'],
                  dataKey: 'duration',
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        // Use refactored manual input
        _buildManualInputSection(
          controller: _manualBreastDurationController,
          dataKey: 'duration',
          hintText: 'lactation.recordForm.customTime'.tr(),
          unit: _durationUnit,
        ),
      ],
    );
  }

  // Refactored Volume Options
  Widget _buildBottleVolumeOptions() {
    // Values depend on the selected unit
    final quickValues = _volumeUnit == 'ml'
        ? [30, 60, 90, 120, 150, 180]
        : [1, 2, 3, 4, 5, 6];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('lactation.recordForm.bottleVolumeQuestion'.tr()),
        const SizedBox(height: 8),
        Row(
          // Unit Selector
          children: [
            _buildChoiceChip(
              label: 'ml',
              value: 'ml',
              groupValue: _volumeUnit,
              isUnitSelector: true,
              unitType: 'volume',
            ),
            const SizedBox(width: 12),
            _buildChoiceChip(
              label: 'oz',
              value: 'oz',
              groupValue: _volumeUnit,
              isUnitSelector: true,
              unitType: 'volume',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Quick selection chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickValues
              .map(
                (val) => _buildQuickValueChip(
                  value: val.toString(),
                  unit: _volumeUnit,
                  groupValue: _flowData['volume'],
                  dataKey: 'volume',
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        // Use refactored manual input
        _buildManualInputSection(
          controller: _manualBottleVolumeController,
          dataKey: 'volume',
          hintText: 'lactation.recordForm.customVolume'.tr(),
          unit: _volumeUnit,
        ),
      ],
    );
  }

  // Refactored Sleep Options
  Widget _buildSleepTimeSection() {
    // Values depend on the selected unit
    final quickValues = _sleepUnit == 'min'
        ? [30, 60, 90, 120, 180]
        : [1, 2, 3, 4, 5]; // Example values

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('lactation.recordForm.sleepTimeQuestion'.tr()),
        const SizedBox(height: 8),
        Row(
          // Unit Selector
          children: [
            _buildChoiceChip(
              label: 'min',
              value: 'min',
              groupValue: _sleepUnit,
              isUnitSelector: true,
              unitType: 'sleep',
            ),
            const SizedBox(width: 12),
            _buildChoiceChip(
              label: 'hr',
              value: 'hr',
              groupValue: _sleepUnit,
              isUnitSelector: true,
              unitType: 'sleep',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Quick selection chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickValues
              .map(
                (val) => _buildQuickValueChip(
                  value: val.toString(),
                  unit: _sleepUnit,
                  groupValue: _flowData['sleep'],
                  dataKey: 'sleep',
                  horizontalPadding: 22,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        _buildManualInputSection(
          controller: _manualSleepTimeController,
          dataKey: 'sleep',
          hintText: 'lactation.recordForm.customTime'.tr(),
          unit: _sleepUnit,
        ),
      ],
    );
  }

  // Chip for selecting quick values (Duration, Volume, Sleep)
  Widget _buildQuickValueChip({
    required String value,
    required String unit,
    String? groupValue,
    required String dataKey,
    double? horizontalPadding,
  }) {
    final String combinedValue = value + unit;
    final bool isSelected = groupValue == combinedValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          _flowData[dataKey] = combinedValue;

          // Optionally clear the manual input when a chip is selected
          if (dataKey == 'duration') _manualBreastDurationController.clear();
          if (dataKey == 'volume') _manualBottleVolumeController.clear();
          if (dataKey == 'sleep') _manualSleepTimeController.clear();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding ?? 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.6) // Más notorio manteniendo blanco
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          "$value $unit", // Display value and unit
          style: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // --- REFACTORED Manual Input Section ---
  Widget _buildManualInputSection({
    required TextEditingController controller,
    required String dataKey,
    required String hintText,
    required String unit,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (text) {
                    setState(() {
                      if (text.isNotEmpty) {
                        _flowData[dataKey] = text + unit;
                      } else {
                        _flowData.remove(dataKey);
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: GoogleFonts.quicksand(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    suffixText: unit,
                    suffixStyle: GoogleFonts.quicksand(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Simplified Action Buttons ---
  Widget _buildSaveAndCancelButtons() {
    return Column(
      children: [
        // Save Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _guardarDatos,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    /* ... CircularProgressIndicator ... */
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    widget.existingRecord != null
                        ? 'lactation.recordForm.updateRecord'.tr()
                        : 'lactation.recordForm.saveRecord'.tr(),
                    style: const TextStyle(
                      /* ... Style ... */
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // Cancel Button
        SizedBox(
          // Use SizedBox to allow full width
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: Colors.white70, // Text color
              backgroundColor: Colors.white.withValues(
                alpha: 0.1,
              ), // Subtle background
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ), // Subtle border
            ),
            child: Text(
              'lactation.recordForm.cancel'.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white70,
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _parseValueToDouble(String? valueWithUnit) {
    if (valueWithUnit == null || valueWithUnit.isEmpty) return 0.0;
    final numericPart = valueWithUnit.replaceAll(RegExp(r'[a-zA-Z]+'), '');
    return double.tryParse(numericPart) ?? 0.0;
  }

  Duration _parseDuration(String? valueWithUnit) {
    if (valueWithUnit == null || valueWithUnit.isEmpty) return Duration.zero;
    final numericPart = _parseValueToDouble(valueWithUnit);
    if (valueWithUnit.endsWith('hr')) {
      return Duration(minutes: (numericPart * 60).round());
    } else {
      // Assume minutes
      return Duration(minutes: numericPart.round());
    }
  }

  // --- Updated _guardarDatos to use _flowData ---
  Future<void> _guardarDatos() async {
    // --- Optional: Add validation based on _flowData ---
    if (_flowData['alimentacion'] == null) {
      DialogExample.showInfoDialog(
        context,
        'Faltan Datos',
        'Por favor, selecciona un tipo de alimentación.',
      );
      return;
    }
    // Add more validation as needed (e.g., ensure duration is entered if pecho selected)

    setState(() {
      _isLoading = true;
    });

    try {
      final fechaRegistro = widget.selectedDate ?? DateTime.now();
      final timestampRegistro =
          widget.existingRecord?.timestamp ?? DateTime.now();

      // --- Prepare data directly from _flowData ---
      final tipoAlimentacion =
          _flowData['alimentacion'] as String? ??
          'lactation.recordForm.notSpecified'.tr();
      final pechoDado =
          _flowData['breastSide'] as String? ??
          'Ninguna'; // Ensure 'Ninguna' if not breastfed

      // Determine LactationType and counts based on 'tipo_alimentacion'
      LactationType recordType = LactationType.breastfeeding; // Default
      int vecesPecho = 0;
      int vecesBiberon = 0;
      if (tipoAlimentacion == 'pecho') {
        recordType = LactationType.breastfeeding;
        vecesPecho = 1;
      } else if (tipoAlimentacion == 'biberon') {
        recordType = LactationType.bottle;
        vecesBiberon = 1;
      } else if (tipoAlimentacion == 'mixto') {
        recordType = LactationType
            .breastfeeding; // Or choose a 'mixed' type if you have one
        vecesPecho = 1;
        vecesBiberon = 1;
      }

      // Parse values safely
      final duration = _parseDuration(_flowData['duration'] as String?);
      final volumeValue = _parseValueToDouble(
        _flowData['volume'] as String?,
      ); // Keep double for potential oz decimals
      final sleepValue = _parseValueToDouble(_flowData['sleep'] as String?);

      final record = LactationRecord(
        id:
            widget.existingRecord?.id ??
            DateTime.now().millisecondsSinceEpoch
                .toString(), // Reuse ID or create new
        fechaRegistro: fechaRegistro,
        timestamp: timestampRegistro,
        tipo: recordType,
        lado: (vecesPecho > 0)
            ? pechoDado
            : null, // Only set side if breast was involved
        duracion: (vecesPecho > 0)
            ? duration
            : Duration.zero, // Only set duration if breast was involved
        volumenExtraccion: volumeValue
            .round(), // Store volume as int in record if needed
        unidadVolumen: (vecesBiberon > 0 && volumeValue > 0)
            ? _volumeUnit
            : 'No', // Only set unit if bottle was involved
        vecesPecho: vecesPecho,
        vecesBiberon: vecesBiberon,
        pechoDado: (vecesPecho > 0)
            ? pechoDado
            : 'Ninguna', // Use formatted string if needed by LactationRecord
        horasSuenoBebe: sleepValue.round(), // Store sleep as int if needed
        unidadSueno: (sleepValue > 0) ? _sleepUnit : 'No',
        notas:
            widget.existingRecord?.notas ??
            '', // Preserve existing notes or add default
        fechaRegistroString: fechaRegistro.toIso8601String(), // Keep if needed
        // NUEVO: Identificar como registro completo
        tipoRegistro: 'completo',
        incluyeSueno: sleepValue > 0, // true si hay datos de sueño
      );

      // Usar LactationService para guardar (offline-first)
      if (widget.existingRecord != null) {
        // Actualizar registro existente
        await _lactationService.updateRecord(widget.existingRecord!.id, record);
      } else {
        // Crear nuevo registro usando LactationService (offline-first)
        await _lactationService.saveRecord(record);
      }

      // Guardar el contexto antes de navegar para mostrar mensaje después
      final currentContext = context;

      // Navegar a Home y refrescar datos de lactancia de forma rápida
      if (mounted) {
        // Navegar a Home directamente (más rápido)
        Navigator.of(
          currentContext,
        ).pushNamedAndRemoveUntil('/home', (route) => false);

        // Refrescar datos de lactancia usando el context global después de la navegación
        await Future.delayed(const Duration(milliseconds: 150));
        await app_init.AppInitializationService.refreshLactationDataOnly();

        // Mostrar mensaje de éxito usando navigatorKey (evita error de widget desmontado)
        await Future.delayed(const Duration(milliseconds: 100));
        final homeContext =
            app_init.AppInitializationService.navigationKey.currentContext;
        if (homeContext != null) {
          ScaffoldMessenger.of(homeContext).showSnackBar(
            SnackBar(
              content: Text('lactation.recordForm.saved'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      /* ... Error handling ... */
      if (mounted) {
        DialogExample.showErrorDialog(
          context,
          'lactation.recordForm.error'.tr(),
          'lactation.recordForm.errorMessage'.tr(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- _eliminarRegistro and _getUserDocumentId remain the same ---
  Future<void> _eliminarRegistro() async {
    // ... same implementation ...
    if (widget.existingRecord == null) return;

    final confirmed = await showDialog<bool>(
      /* ... Confirmation Dialog ... */
      context: context,
      builder: (context) => AlertDialog(
        // ... (Keep the styled confirmation dialog)
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(/* ... */)],
          ),
          child: const Column(
            /* ... Icon, Text, Buttons ... */
            mainAxisSize: MainAxisSize.min,
            children: [/* ... Warning Icon, Title, Message, Buttons ... */],
          ),
        ),
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userDocId = await _getUserDocumentId(); // Use helper
      final situationDocRef = _getUserSituationDocRef(userDocId);
      final lactationCollectionRef = _getLactationCollectionRef(
        situationDocRef,
      );

      if (user == null || lactationCollectionRef == null) {
        DialogExample.showErrorDialog(
          context,
          'Error',
          'No se pudo encontrar el usuario o la colección.',
        );
        return;
      }

      await lactationCollectionRef.doc(widget.existingRecord!.id).delete();

      DialogExample.showSuccessDialog(
        context,
        'lactation.recordForm.deleted'.tr(),
        'lactation.recordForm.deletedMessage'.tr(),
        () {
          Navigator.of(context).pop(true); // Indicate success
        },
      );
    } catch (e) {
      /* ... Error handling ... */
      if (mounted) {
        DialogExample.showErrorDialog(
          context,
          'lactation.recordForm.deleteError'.tr(),
          'lactation.recordForm.deleteErrorMessage'.tr(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _getUserDocumentId() async {
    // ... same implementation ...
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      if (user.email != null) {
        final userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        if (userQuery.docs.isNotEmpty) {
          return userQuery.docs.first.id;
        }
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      if (docSnapshot.exists) {
        return user.uid;
      }

      print('❌ LactationRecordPage: No se encontró usuario en Firestore');
      return null;
    } catch (e) {
      print('❌ Error obteniendo ID del usuario: $e');
      return null;
    }
  }

  // --- _buildAnimatedBackground and _ParticlePainter remain the same ---
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      /* ... */
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(_pulseAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.child_care,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'lactation.recordForm.title'.tr(),
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.selectedDate != null
                          ? 'Fecha: ${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}'
                          : 'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
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
  }
} // End of _LactationRecordPageState

// --- _ParticlePainter class remains the same ---
class _ParticlePainter extends CustomPainter {
  final double animationValue;
  _ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    /* ... same particle drawing logic ... */
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 20; i++) {
      final x =
          (i * 50.0 + animationValue * 30) % size.width; // Slight variation
      final y = (i * 30.0 + animationValue * 100) % size.height;
      canvas.drawCircle(
        Offset(x, y),
        2.0 + (i % 3) * 0.5,
        paint,
      ); // Vary size slightly
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

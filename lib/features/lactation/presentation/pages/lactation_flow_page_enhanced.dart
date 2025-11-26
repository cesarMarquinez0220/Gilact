import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/app_initialization_service.dart' as app_init;
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';
import 'dart:ui';
import '../../domain/entities/lactation_record.dart';
import '../../data/services/lactation_service.dart';
import '../../domain/services/lactation_decision_tree.dart';

/// Página mejorada del flujo de registro de lactancia con opciones predefinidas
class LactationFlowPage extends StatefulWidget {
  final DateTime? selectedDate;
  final dynamic existingRecord;

  const LactationFlowPage({super.key, this.selectedDate, this.existingRecord});

  @override
  State<LactationFlowPage> createState() => _LactationFlowPageState();
}

class _LactationFlowPageState extends State<LactationFlowPage>
    with TickerProviderStateMixin {
  final AppLogger _logger = getIt<AppLogger>();
  LactationStep _currentStep = LactationStep.initial;
  final Map<String, dynamic> _data = {};
  final List<String> _history = [];
  late LactationService _lactationService;

  // Controlador de animación de fondo únicamente
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _logger.d('LactationFlowPage: Inicializando página...');
    _logger.d('LactationFlowPage: Fecha seleccionada: ${widget.selectedDate}');
    _logger.d(
      'LactationFlowPage: Registro existente: ${widget.existingRecord}',
    );
    _logger.d('LactationFlowPage: Paso inicial: $_currentStep');
    _logger.d('LactationFlowPage: Datos iniciales: $_data');
    _logger.d('LactationFlowPage: Historial inicial: $_history');

    // Inicializar servicio de lactancia
    _lactationService = LactationService(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );

    // Inicializar animaciones
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Iniciar animación de fondo
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C5F5D), // Azul teal oscuro (secundario)
              Color(0xFF1A365D), // Azul marino oscuro (primario)
              Color(0xFF4FD1C7), // Verde azulado medio vibrante (primario)
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Fondo animado con partículas
            _buildAnimatedBackground(),

            // Contenido principal
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(overscroll: false),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildStepContent(),
                      ),
                    ),
                  ),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header con botón de volver
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registro de Lactancia',
                      style: GoogleFonts.quicksand(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case LactationStep.initial:
        return _buildTypeSelection();
      case LactationStep.breastSide:
        return _buildBreastSideSelection();
      case LactationStep.breastDuration:
        return _buildBreastfeedingDurationInput();
      case LactationStep.bottleVolume:
        return _buildBottleVolumeInput();
      case LactationStep.confirmation:
        return _buildConfirmation();
      default:
        return _buildTypeSelection();
    }
  }

  Widget _buildTypeSelection() {
    final options = LactationDecisionTree.getOptionsForStep(
      LactationStep.initial,
    );

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Text(
                'lactation.flow.feedingTypeQuestion'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...options.map((option) => _buildOptionCard(option)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBreastSideSelection() {
    final options = LactationDecisionTree.getOptionsForStep(
      LactationStep.breastSide,
    );

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Text(
                'lactation.flow.breastSideQuestion'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...options.map((option) => _buildOptionCard(option)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBreastfeedingDurationInput() {
    final isManualEntry = _data['manualEntry'] == true;

    if (isManualEntry) {
      return _buildManualDurationInput();
    }

    final predefinedOptions = LactationDecisionTree.getOptionsForStep(
      LactationStep.breastDuration,
    );
    final allOptions = [
      ...predefinedOptions,
      LactationOption(
        id: 'otro',
        title: 'common.other'.tr(),
        description: 'lactation.flow.customTimeHint'.tr(),
        icon: '✏️',
        color: 0xFF9E9E9E,
      ),
    ];

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Text(
                '¿Cuánto tiempo duró la lactancia?',
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...allOptions.map((option) => _buildOptionCard(option)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBottleVolumeInput() {
    final isManualEntry = _data['manualEntryVolume'] == true;

    if (isManualEntry) {
      return _buildManualVolumeInput();
    }

    final predefinedOptions = LactationDecisionTree.getOptionsForStep(
      LactationStep.bottleVolume,
    );
    final allOptions = [
      ...predefinedOptions,
      LactationOption(
        id: 'otro',
        title: 'common.other'.tr(),
        description: 'Ingresar volumen personalizado',
        icon: '✏️',
        color: 0xFF9E9E9E,
      ),
    ];

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Text(
                '¿Cuánto volumen tomó?',
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...allOptions.map((option) => _buildOptionCard(option)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildManualDurationInput() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Text(
                'Ingresa la duración manualmente',
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
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
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final minutes = int.tryParse(value);
                  if (minutes != null) {
                    _data['duration'] = Duration(minutes: minutes);
                    _logger.d(
                      'LactationFlowPage: Duración manual ingresada: $minutes minutos',
                    );
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Duración en minutos',
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon:  Icon(
                    Icons.timer_outlined,
                    color: Colors.white70,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding:  EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1A365D), // Azul marino oscuro (primario)
                      Color(
                        0xFF4FD1C7,
                      ), // Verde azulado medio vibrante (primario)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4FD1C7).withValues(alpha: 0.4),
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
                  onPressed: () {
                    if (_data['duration'] != null) {
                      _logger.d(
                        'LactationFlowPage: Botón guardar duración presionado',
                      );
                      final isMixed =
                          _data['type']?.toString().toLowerCase() == 'mixto';
                      if (isMixed) {
                        _logger.d(
                          'LactationFlowPage: Lactancia mixta, avanzando a volumen',
                        );
                        setState(() {
                          _currentStep = LactationStep.bottleVolume;
                        });
                      } else {
                        _logger.d(
                          'LactationFlowPage: Lactancia materna completa, guardando',
                        );
                        _saveRecord();
                      }
                    } else {
                      _logger.w('LactationFlowPage: Duración no ingresada');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _data['type']?.toString().toLowerCase() == 'mixto'
                            ? Icons.arrow_forward_ios
                            : Icons.save,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _data['type']?.toString().toLowerCase() == 'mixto'
                            ? 'Continuar'
                            : 'Guardar',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildManualVolumeInput() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Text(
                'Ingresa el volumen manualmente',
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
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
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final volume = double.tryParse(value);
                  if (volume != null) {
                    _data['volume'] = volume;
                    _data['unit'] = 'ml';
                    _logger.d(
                      'LactationFlowPage: Volumen manual ingresado: $volume ml',
                    );
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Volumen en ml',
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon:  Icon(
                    Icons.water_drop_outlined,
                    color: Colors.white70,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding:  EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1A365D), // Azul marino oscuro (primario)
                      Color(
                        0xFF4FD1C7,
                      ), // Verde azulado medio vibrante (primario)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4FD1C7).withValues(alpha: 0.4),
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
                  onPressed: () {
                    if (_data['volume'] != null) {
                      _logger.d(
                        'LactationFlowPage: Botón guardar volumen presionado',
                      );
                      _saveRecord();
                    } else {
                      _logger.w('LactationFlowPage: Volumen no ingresado');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Guardar',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConfirmation() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            'lactation.flow.confirmRecord'.tr(),
            style: GoogleFonts.quicksand(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildConfirmationItem('Tipo', _data['type']),
              if (_data['side'] != null)
                _buildConfirmationItem('Lado', _data['side']),
              if (_data['duration'] != null)
                _buildConfirmationItem('Duración', _data['duration']),
              if (_data['volume'] != null)
                _buildConfirmationItem(
                  'Volumen',
                  '${_data['volume']} ${_data['unit']}',
                ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _saveRecord,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF667eea),
                        Color(0xFF764ba2),
                        Color(0xFFf093fb),
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Guardar Registro',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        children: [
          if (_currentStep != LactationStep.initial) ...[
            // --- BOTÓN "ATRÁS" MODIFICADO ---
            Expanded(
              child: Container(
                // 1. Copiamos la decoración del botón "Cancelar"
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: TextButton(
                  onPressed: _goBack,
                  // 2. Copiamos el estilo del "TextButton" de "Cancelar"
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.white, // Para el efecto "splash"
                  ),
                  // 3. El child ahora es un Row para incluir el ícono
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white70, // 4. Ajustamos color y tamaño
                        size: 15,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'lactation.flow.back'.tr(),
                        // 5. Copiamos el estilo de texto de "Cancelar"
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            // --- BOTÓN "CANCELAR" (NUESTRO MODELO) ---
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: TextButton(
                  onPressed: _goBack,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionCard(LactationOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _selectOption(option),
        child: Container(
          padding: const EdgeInsets.all(18),
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
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                children: [
                  // Icono simplificado estilo preparto/postparto
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
                    child: Center(
                      child: Icon(
                        _getIconForOption(option),
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option.title,
                          style: GoogleFonts.quicksand(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          option.description,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Flecha de indicador
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForOption(LactationOption option) {
    // Mapear la opción a un icono Material blanco
    switch (option.id) {
      case 'pecho':
        return Icons.child_care_outlined;
      case 'biberon':
        return Icons.local_drink_outlined;
      case 'mixto':
        return Icons.swap_horiz;
      case 'izquierdo':
        return Icons.keyboard_arrow_left;
      case 'derecho':
        return Icons.keyboard_arrow_right;
      case 'ambos':
        return Icons.sync_alt;
      case '5min':
      case '10min':
      case '15min':
      case '20min':
        return Icons.timer_outlined;
      case '30ml':
      case '60ml':
      case '120ml':
      case '180ml':
        return Icons.water_drop_outlined;
      case 'otro':
        return Icons.edit_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  void _selectOption(LactationOption option) {
    _logger.d(
      'LactationFlowPage: Opción seleccionada: ${option.title} (${option.id})',
    );
    _logger.d('LactationFlowPage: Paso actual: $_currentStep');
    _logger.d('LactationFlowPage: Datos antes de selección: $_data');

    // --- INICIO CORRECCIÓN DE DATOS ---
    String dataKey;
    switch (_currentStep) {
      case LactationStep.initial:
        dataKey = 'type';
        break;
      case LactationStep.breastSide:
        dataKey = 'side';
        break;
      case LactationStep.breastDuration:
        dataKey = 'duration';
        break;
      case LactationStep.bottleVolume:
        dataKey = 'volume';
        break;
      default:
        dataKey = _currentStep.name;
    }

    // No guardar el dato si es 'otro', solo activar el flag
    if (option.id != 'otro') {
      _data[dataKey] = option.id; // Guardar el ID (ej: '10min')
      _logger.d('LactationFlowPage: Guardando $dataKey = ${option.id}');
    } else {
      _logger.d('LactationFlowPage: Activando entrada manual para $dataKey');
    }
    _history.add(dataKey); // Añadir la *llave* (ej: 'duration') al historial
    _logger.d('LactationFlowPage: Historial actualizado: $_history');
    // --- FIN CORRECCIÓN DE DATOS ---

    if (option.id == 'otro') {
      if (_currentStep == LactationStep.breastDuration) {
        _data['manualEntry'] = true;
        _logger.d('LactationFlowPage: Activando entrada manual de duración');
      } else if (_currentStep == LactationStep.bottleVolume) {
        _data['manualEntryVolume'] = true;
        _logger.d('LactationFlowPage: Activando entrada manual de volumen');
      }
      // BUG #4 Arreglado: Faltaba setState para mostrar el input manual
      setState(() {});
      return;
    }

    // FLUJO RÁPIDO: Guardar inmediatamente para opciones predefinidas
    _logger.d('LactationFlowPage: Procesando flujo rápido...');
    switch (_currentStep) {
      case LactationStep.initial:
        if (option.id == 'pecho' || option.id == 'mixto') {
          _logger.d(
            'LactationFlowPage: Lactancia materna detectada, avanzando a selección de lado',
          );
          _currentStep = LactationStep.breastSide;
        } else {
          _logger.d(
            'LactationFlowPage: Biberón detectado, avanzando a volumen',
          );
          // Si es biberón, ir directo al volumen
          _currentStep = LactationStep.bottleVolume;
        }
        break;
      case LactationStep.breastSide:
        _logger.d('LactationFlowPage: Lado seleccionado, avanzando a duración');
        _currentStep = LactationStep.breastDuration;
        break;
      case LactationStep.breastDuration:
        // Ahora esto funciona gracias a la corrección de datos
        final isMixed = _data['type']?.toString().toLowerCase() == 'mixto';
        if (isMixed) {
          _logger.d(
            'LactationFlowPage: Lactancia mixta detectada, avanzando a volumen',
          );
          _currentStep = LactationStep.bottleVolume;
        } else {
          _logger.d(
            'LactationFlowPage: Lactancia materna completa, guardando registro',
          );
          // Guardar inmediatamente si no es mixto
          _saveRecord();
          return;
        }
        break;
      case LactationStep.bottleVolume:
        _logger.d(
          'LactationFlowPage: Volumen seleccionado, guardando registro',
        );
        // Guardar inmediatamente después de seleccionar volumen
        _saveRecord();
        return;
      default:
        _logger.d('LactationFlowPage: Paso final, guardando registro');
        _saveRecord();
        return;
    }

    _logger.d('LactationFlowPage: Avanzando al paso: $_currentStep');
    setState(() {});
  }

  void _goBack() {
    _logger.d('LactationFlowPage: Navegando hacia atrás...');
    _logger.d('LactationFlowPage: Paso actual: $_currentStep');
    _logger.d('LactationFlowPage: Datos actuales: $_data');
    _logger.d('LactationFlowPage: Historial actual: $_history');

    // 1. Manejar salida de modo "manual"
    // Si estamos en modo manual, "Atrás" debe volver a la lista de opciones
    if (_data['manualEntry'] == true) {
      _logger.d('LactationFlowPage: Saliendo del modo manual de duración');
      setState(() {
        _data.remove('manualEntry');
        _history.removeLast(); // Remover 'duration' del historial
      });
      _logger.d(
        'LactationFlowPage: Historial después de salir de manual: $_history',
      );
      return;
    }
    if (_data['manualEntryVolume'] == true) {
      _logger.d('LactationFlowPage: Saliendo del modo manual de volumen');
      setState(() {
        _data.remove('manualEntryVolume');
        _history.removeLast(); // Remover 'volume' del historial
      });
      _logger.d(
        'LactationFlowPage: Historial después de salir de manual: $_history',
      );
      return;
    }

    // 2. Navegación de página normal
    if (_history.isNotEmpty) {
      final lastStepKey = _history.removeLast();
      _logger.d('LactationFlowPage: Removiendo último paso: $lastStepKey');
      _data.remove(lastStepKey);
      _logger.d(
        'LactationFlowPage: Datos después de remover $lastStepKey: $_data',
      );

      LactationStep previousStep;
      switch (_currentStep) {
        case LactationStep.breastSide:
          previousStep = LactationStep.initial;
          _logger.d('LactationFlowPage: Volviendo de lado a tipo inicial');
          break;
        case LactationStep.breastDuration:
          previousStep = LactationStep.breastSide;
          _logger.d('LactationFlowPage: Volviendo de duración a lado');
          break;

        case LactationStep.bottleVolume:
          // LÓGICA CORREGIDA:
          final type =
              _data['type']; // 'type' es el paso anterior, sigue en _data
          if (type == 'mixto') {
            previousStep = LactationStep.breastDuration;
            _logger.d(
              'LactationFlowPage: Volviendo de volumen a duración (mixto)',
            );
          } else {
            // El tipo fue 'biberon'
            previousStep = LactationStep.initial;
            _logger.d(
              'LactationFlowPage: Volviendo de volumen a tipo inicial (biberón)',
            );
          }
          break;

        case LactationStep.confirmation:
          // LÓGICA CORREGIDA:
          // Vemos cuál fue el último dato que se guardó
          if (lastStepKey == 'volume') {
            previousStep = LactationStep.bottleVolume;
            _logger.d('LactationFlowPage: Volviendo de confirmación a volumen');
          } else {
            // El último dato fue 'duration'
            previousStep = LactationStep.breastDuration;
            _logger.d(
              'LactationFlowPage: Volviendo de confirmación a duración',
            );
          }
          break;

        default:
          previousStep = LactationStep.initial;
          _logger.d('LactationFlowPage: Volviendo al paso inicial por defecto');
      }

      _logger.d('LactationFlowPage: Nuevo paso: $previousStep');
      setState(() {
        _currentStep = previousStep;
      });
    } else {
      _logger.d('LactationFlowPage: No hay historial, cerrando pantalla');
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveRecord() async {
    _logger.d('LactationFlowPage: Iniciando guardado de registro...');
    _logger.d('LactationFlowPage: Datos del registro: $_data');
    _logger.d('LactationFlowPage: Fecha seleccionada: ${widget.selectedDate}');
    _logger.d(
      'LactationFlowPage: Registro existente: ${widget.existingRecord}',
    );

    // Validar datos antes de guardar
    _validateAndLogData();

    try {
      // Crear objeto LactationRecord para guardar en Firestore
      final record = _createLactationRecord();
      _logger.d('LactationFlowPage: Guardando registro en Firestore...');
      _logger.d('LactationFlowPage: Registro creado: ${record.toMap()}');

      // Guardar en Firestore usando LactationService
      await _lactationService.saveRecord(record);

      _logger.success(
        'LactationFlowPage: Registro guardado exitosamente en Firestore',
      );

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
              content: Text('lactation.flow.recordSavedSuccessEnhanced'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      _logger.e(
        'LactationFlowPage: Error guardando en Firestore',
        e,
        stackTrace,
      );
      // Mostrar error al usuario usando navigatorKey si está disponible
      if (mounted) {
        final errorContext =
            app_init.AppInitializationService.navigationKey.currentContext ??
            context;
        ScaffoldMessenger.of(errorContext).showSnackBar(
          SnackBar(
            content: Text(
              'lactation.flow.saveErrorEnhanced'.tr(
                namedArgs: {'error': e.toString()},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  LactationRecord _createLactationRecord() {
    final now = DateTime.now();
    final recordDate = widget.selectedDate ?? now;

    // Determinar tipo de alimentación
    String tipoAlimentacion = _data['type'] ?? 'pecho';

    // Determinar lado del pecho
    String? ladoPecho;
    if (tipoAlimentacion == 'pecho' || tipoAlimentacion == 'mixto') {
      ladoPecho = _data['side'] ?? 'ambos';
    }

    // Determinar duración
    Duration duracion = const Duration(minutes: 15); // Valor por defecto
    if (_data['duration'] != null) {
      if (_data['duration'] is Duration) {
        duracion = _data['duration'] as Duration;
      } else if (_data['duration'] is String) {
        // Convertir string a Duration (ej: "10min" -> Duration(minutes: 10))
        final durationStr = _data['duration'] as String;
        if (durationStr.contains('min')) {
          final minutes = int.tryParse(durationStr.replaceAll('min', ''));
          if (minutes != null) {
            duracion = Duration(minutes: minutes);
          }
        }
      }
    }

    // Determinar volumen
    int volumenExtraccion = 0;
    String unidadVolumen = 'No';
    if (_data['volume'] != null) {
      if (_data['volume'] is double) {
        volumenExtraccion = (_data['volume'] as double).round();
        unidadVolumen = _data['unit'] ?? 'ml';
      } else if (_data['volume'] is int) {
        volumenExtraccion = _data['volume'] as int;
        unidadVolumen = _data['unit'] ?? 'ml';
      } else if (_data['volume'] is String) {
        volumenExtraccion = int.tryParse(_data['volume'] as String) ?? 0;
        unidadVolumen = _data['unit'] ?? 'ml';
      }
    }

    // Determinar tipo de lactancia
    LactationType tipo;
    if (tipoAlimentacion == 'pecho') {
      tipo = LactationType.breastfeeding;
    } else if (tipoAlimentacion == 'biberon') {
      tipo = LactationType.bottle;
    } else if (tipoAlimentacion == 'mixto') {
      tipo = LactationType.breastfeeding; // Por defecto para mixto
    } else {
      tipo = LactationType.breastfeeding;
    }

    // Determinar pecho dado
    String pechoDado = 'Ninguna';
    if (tipoAlimentacion == 'pecho' || tipoAlimentacion == 'mixto') {
      if (ladoPecho == 'izquierdo') {
        pechoDado = 'Izquierdo';
      } else if (ladoPecho == 'derecho') {
        pechoDado = 'Derecho';
      } else if (ladoPecho == 'ambos') {
        pechoDado = 'Ambos';
      }
    }

    // Calcular veces pecho y biberón
    int vecesPecho = 0;
    int vecesBiberon = 0;
    if (tipoAlimentacion == 'pecho') {
      vecesPecho = 1;
    } else if (tipoAlimentacion == 'biberon') {
      vecesBiberon = 1;
    } else if (tipoAlimentacion == 'mixto') {
      vecesPecho = 1;
      vecesBiberon = 1;
    }

    _logger.d('LactationFlowPage: Creando registro con datos:');
    _logger.d('   - Tipo: $tipoAlimentacion -> $tipo');
    _logger.d('   - Lado: $ladoPecho -> $pechoDado');
    _logger.d('   - Duración: $duracion');
    _logger.d('   - Volumen: $volumenExtraccion $unidadVolumen');
    _logger.d('   - Fecha: $recordDate');
    _logger.d('   - Veces pecho: $vecesPecho');
    _logger.d('   - Veces biberón: $vecesBiberon');

    return LactationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fechaRegistro: recordDate,
      duracion: duracion,
      tipo: tipo,
      notas: 'Registrado desde LactationFlowPage',
      lado: ladoPecho,
      volumenExtraccion: volumenExtraccion,
      unidadVolumen: unidadVolumen,
      vecesBiberon: vecesBiberon,
      vecesPecho: vecesPecho,
      pechoDado: pechoDado,
      horasSuenoBebe: 0,
      unidadSueno: 'No',
      timestamp: now,
      fechaRegistroString: recordDate.toIso8601String(),
      // NUEVO: Identificar como registro rápido
      tipoRegistro: 'rapido',
      incluyeSueno: false,
    );
  }

  void _validateAndLogData() {
    _logger.d('LactationFlowPage: Validando datos del registro...');

    // Validar tipo de alimentación
    if (_data.containsKey('type')) {
      _logger.d('Tipo de alimentación: ${_data['type']}');
    } else {
      _logger.e('ERROR: Tipo de alimentación no especificado');
    }

    // Validar lado del pecho (si aplica)
    if (_data.containsKey('side')) {
      _logger.d('Lado del pecho: ${_data['side']}');
    } else if (_data['type'] == 'pecho' || _data['type'] == 'mixto') {
      _logger.w(
        'ADVERTENCIA: Lado del pecho no especificado para lactancia materna',
      );
    }

    // Validar duración (si aplica)
    if (_data.containsKey('duration')) {
      _logger.d('Duración: ${_data['duration']}');
    } else if (_data['type'] == 'pecho' || _data['type'] == 'mixto') {
      _logger.e('ERROR: Duración no especificada para lactancia materna');
    }

    // Validar volumen (si aplica)
    if (_data.containsKey('volume')) {
      _logger.d('Volumen: ${_data['volume']} ${_data['unit'] ?? 'ml'}');
    } else if (_data['type'] == 'biberon' || _data['type'] == 'mixto') {
      _logger.e('ERROR: Volumen no especificado para biberón');
    }

    // Validar entrada manual
    if (_data.containsKey('manualEntry')) {
      _logger.d('Entrada manual de duración: ${_data['manualEntry']}');
    }
    if (_data.containsKey('manualEntryVolume')) {
      _logger.d('Entrada manual de volumen: ${_data['manualEntryVolume']}');
    }

    _logger.d('Historial de pasos: $_history');
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Círculos decorativos animados más grandes y suaves
        Positioned(
          top: -80,
          right: -80,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(
                          0xFF2C5F5D,
                        ).withValues(alpha:0.15), // Azul teal oscuro
                        const Color(
                          0xFF2C5F5D,
                        ).withValues(alpha:0.05), // Azul teal oscuro
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: -120,
          left: -120,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value * 0.7,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(
                          0xFF4FD1C7,
                        ).withValues(alpha:0.1), // Verde azulado medio
                        const Color(
                          0xFF4FD1C7,
                        ).withValues(alpha:0.03), // Verde azulado medio
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Elementos decorativos adicionales
        Positioned(
          top: 150,
          right: 40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFE2E8F0).withValues(alpha:0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          right: 60,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFB794F6).withValues(alpha:0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Patrón de puntos decorativos
        Positioned(
          top: 120,
          right: 30,
          child: SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(painter: DotsPainter()),
          ),
        ),
        // Líneas decorativas sutiles
        Positioned(
          top: 300,
          left: 20,
          child: Container(
            width: 2,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF4FD1C7).withValues(alpha:0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha:0.4)
      ..style = PaintingStyle.fill;

    // Crear un patrón de puntos elegante
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        final x = i * 20.0;
        final y = j * 20.0;
        final radius = (i + j) % 2 == 0 ? 2.5 : 1.5;
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }

    // Agregar puntos más pequeños para mayor detalle
    final smallPaint = Paint()
      ..color = const Color(0xFF4FD1C7).withValues(alpha:0.2)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final x = i * 25.0 + 10.0;
        final y = j * 25.0 + 10.0;
        canvas.drawCircle(Offset(x, y), 1.0, smallPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

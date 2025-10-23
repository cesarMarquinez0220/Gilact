import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/lactation_record.dart';
import '../../data/services/lactation_service.dart';
import '../../domain/services/lactation_decision_tree.dart';

/// Página mejorada del flujo de registro de lactancia con opciones predefinidas
class LactationFlowPage extends StatefulWidget {
  final DateTime? selectedDate;
  final dynamic existingRecord;

  const LactationFlowPage({Key? key, this.selectedDate, this.existingRecord})
    : super(key: key);

  @override
  State<LactationFlowPage> createState() => _LactationFlowPageState();
}

class _LactationFlowPageState extends State<LactationFlowPage> {
  LactationStep _currentStep = LactationStep.initial;
  Map<String, dynamic> _data = {};
  List<String> _history = [];
  late LactationService _lactationService;

  @override
  void initState() {
    super.initState();
    print('🚀 LactationFlowPage: Inicializando página...');
    print('📅 LactationFlowPage: Fecha seleccionada: ${widget.selectedDate}');
    print('🆔 LactationFlowPage: Registro existente: ${widget.existingRecord}');
    print('📍 LactationFlowPage: Paso inicial: $_currentStep');
    print('📊 LactationFlowPage: Datos iniciales: $_data');
    print('📋 LactationFlowPage: Historial inicial: $_history');

    // Inicializar servicio de lactancia
    _lactationService = LactationService(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
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
              Color(0xFF667eea), // Azul púrpura (consistente con header)
              Color(0xFF764ba2), // Púrpura
              Color(0xFFf093fb), // Rosa claro
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStepContent(),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea), // Azul púrpura
            Color(0xFF764ba2), // Púrpura
            Color(0xFFf093fb), // Rosa claro
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
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
          const SizedBox(width: 16),
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
                const SizedBox(height: 6),
                Text(
                  'Registra tu sesión de lactancia',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
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
            '¿Qué tipo de alimentación?',
            style: GoogleFonts.quicksand(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
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
            '¿Qué lado del pecho?',
            style: GoogleFonts.quicksand(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
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
        title: 'Otro',
        description: 'Ingresar tiempo personalizado',
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
            '¿Cuánto tiempo duró la lactancia?',
            style: GoogleFonts.quicksand(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
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
        title: 'Otro',
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
            '¿Cuánto volumen tomó?',
            style: GoogleFonts.quicksand(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
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
            'Ingresa la duración manualmente',
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Duración en minutos',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final minutes = int.tryParse(value);
                  if (minutes != null) {
                    _data['duration'] = Duration(minutes: minutes);
                    print(
                      '⏱️ LactationFlowPage: Duración manual ingresada: $minutes minutos',
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (_data['duration'] != null) {
                    print(
                      '💾 LactationFlowPage: Botón guardar duración presionado',
                    );
                    final isMixed =
                        _data['type']?.toString().toLowerCase() == 'mixto';
                    if (isMixed) {
                      print(
                        '🔄 LactationFlowPage: Lactancia mixta, avanzando a volumen',
                      );
                      setState(() {
                        _currentStep = LactationStep.bottleVolume;
                      });
                    } else {
                      print(
                        '💾 LactationFlowPage: Lactancia materna completa, guardando',
                      );
                      _saveRecord();
                    }
                  } else {
                    print('⚠️ LactationFlowPage: Duración no ingresada');
                  }
                },
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

  Widget _buildManualVolumeInput() {
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
            'Ingresa el volumen manualmente',
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Volumen en ml',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final volume = double.tryParse(value);
                  if (volume != null) {
                    _data['volume'] = volume;
                    _data['unit'] = 'ml';
                    print(
                      '🍼 LactationFlowPage: Volumen manual ingresado: $volume ml',
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (_data['volume'] != null) {
                    print(
                      '💾 LactationFlowPage: Botón guardar volumen presionado',
                    );
                    _saveRecord();
                  } else {
                    print('⚠️ LactationFlowPage: Volumen no ingresado');
                  }
                },
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
                      Icon(Icons.save, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Guardar',
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
            'Confirmar registro',
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
                      Icon(Icons.save, color: Colors.white, size: 20),
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
            Expanded(
              child: GestureDetector(
                onTap: _goBack,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        color: const Color(0xFF2C3E50),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Atrás',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: GestureDetector(
                onTap: _goBack,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.close,
                        color: const Color(0xFF2C3E50),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cancelar',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
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
      margin: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () => _selectOption(option),
        child: Container(
          height: 110,
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
          child: Stack(
            children: [
              // Icono en la esquina superior derecha
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(option.color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(option.color).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    option.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),

              // Contenido principal
              Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.description,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7F8C8D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  void _selectOption(LactationOption option) {
    print(
      '🎯 LactationFlowPage: Opción seleccionada: ${option.title} (${option.id})',
    );
    print('📍 LactationFlowPage: Paso actual: $_currentStep');
    print('📊 LactationFlowPage: Datos antes de selección: $_data');

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
      print('💾 LactationFlowPage: Guardando $dataKey = ${option.id}');
    } else {
      print('✏️ LactationFlowPage: Activando entrada manual para $dataKey');
    }
    _history.add(dataKey); // Añadir la *llave* (ej: 'duration') al historial
    print('📋 LactationFlowPage: Historial actualizado: $_history');
    // --- FIN CORRECCIÓN DE DATOS ---

    if (option.id == 'otro') {
      if (_currentStep == LactationStep.breastDuration) {
        _data['manualEntry'] = true;
        print('📝 LactationFlowPage: Activando entrada manual de duración');
      } else if (_currentStep == LactationStep.bottleVolume) {
        _data['manualEntryVolume'] = true;
        print('📝 LactationFlowPage: Activando entrada manual de volumen');
      }
      // BUG #4 Arreglado: Faltaba setState para mostrar el input manual
      setState(() {});
      return;
    }

    // FLUJO RÁPIDO: Guardar inmediatamente para opciones predefinidas
    print('🚀 LactationFlowPage: Procesando flujo rápido...');
    switch (_currentStep) {
      case LactationStep.initial:
        if (option.id == 'pecho' || option.id == 'mixto') {
          print(
            '🤱 LactationFlowPage: Lactancia materna detectada, avanzando a selección de lado',
          );
          _currentStep = LactationStep.breastSide;
        } else {
          print('🍼 LactationFlowPage: Biberón detectado, avanzando a volumen');
          // Si es biberón, ir directo al volumen
          _currentStep = LactationStep.bottleVolume;
        }
        break;
      case LactationStep.breastSide:
        print('⏱️ LactationFlowPage: Lado seleccionado, avanzando a duración');
        _currentStep = LactationStep.breastDuration;
        break;
      case LactationStep.breastDuration:
        // Ahora esto funciona gracias a la corrección de datos
        final isMixed = _data['type']?.toString().toLowerCase() == 'mixto';
        if (isMixed) {
          print(
            '🔄 LactationFlowPage: Lactancia mixta detectada, avanzando a volumen',
          );
          _currentStep = LactationStep.bottleVolume;
        } else {
          print(
            '💾 LactationFlowPage: Lactancia materna completa, guardando registro',
          );
          // Guardar inmediatamente si no es mixto
          _saveRecord();
          return;
        }
        break;
      case LactationStep.bottleVolume:
        print('💾 LactationFlowPage: Volumen seleccionado, guardando registro');
        // Guardar inmediatamente después de seleccionar volumen
        _saveRecord();
        return;
      default:
        print('💾 LactationFlowPage: Paso final, guardando registro');
        _saveRecord();
        return;
    }

    print('➡️ LactationFlowPage: Avanzando al paso: $_currentStep');
    setState(() {});
  }

  void _goBack() {
    print('⬅️ LactationFlowPage: Navegando hacia atrás...');
    print('📍 LactationFlowPage: Paso actual: $_currentStep');
    print('📊 LactationFlowPage: Datos actuales: $_data');
    print('📋 LactationFlowPage: Historial actual: $_history');

    // 1. Manejar salida de modo "manual"
    // Si estamos en modo manual, "Atrás" debe volver a la lista de opciones
    if (_data['manualEntry'] == true) {
      print('📝 LactationFlowPage: Saliendo del modo manual de duración');
      setState(() {
        _data.remove('manualEntry');
        _history.removeLast(); // Remover 'duration' del historial
      });
      print(
        '📋 LactationFlowPage: Historial después de salir de manual: $_history',
      );
      return;
    }
    if (_data['manualEntryVolume'] == true) {
      print('📝 LactationFlowPage: Saliendo del modo manual de volumen');
      setState(() {
        _data.remove('manualEntryVolume');
        _history.removeLast(); // Remover 'volume' del historial
      });
      print(
        '📋 LactationFlowPage: Historial después de salir de manual: $_history',
      );
      return;
    }

    // 2. Navegación de página normal
    if (_history.isNotEmpty) {
      final lastStepKey = _history.removeLast();
      print('🗑️ LactationFlowPage: Removiendo último paso: $lastStepKey');
      _data.remove(lastStepKey);
      print(
        '📊 LactationFlowPage: Datos después de remover $lastStepKey: $_data',
      );

      LactationStep previousStep;
      switch (_currentStep) {
        case LactationStep.breastSide:
          previousStep = LactationStep.initial;
          print('⬅️ LactationFlowPage: Volviendo de lado a tipo inicial');
          break;
        case LactationStep.breastDuration:
          previousStep = LactationStep.breastSide;
          print('⬅️ LactationFlowPage: Volviendo de duración a lado');
          break;

        case LactationStep.bottleVolume:
          // LÓGICA CORREGIDA:
          final type =
              _data['type']; // 'type' es el paso anterior, sigue en _data
          if (type == 'mixto') {
            previousStep = LactationStep.breastDuration;
            print(
              '⬅️ LactationFlowPage: Volviendo de volumen a duración (mixto)',
            );
          } else {
            // El tipo fue 'biberon'
            previousStep = LactationStep.initial;
            print(
              '⬅️ LactationFlowPage: Volviendo de volumen a tipo inicial (biberón)',
            );
          }
          break;

        case LactationStep.confirmation:
          // LÓGICA CORREGIDA:
          // Vemos cuál fue el último dato que se guardó
          if (lastStepKey == 'volume') {
            previousStep = LactationStep.bottleVolume;
            print('⬅️ LactationFlowPage: Volviendo de confirmación a volumen');
          } else {
            // El último dato fue 'duration'
            previousStep = LactationStep.breastDuration;
            print('⬅️ LactationFlowPage: Volviendo de confirmación a duración');
          }
          break;

        default:
          previousStep = LactationStep.initial;
          print('⬅️ LactationFlowPage: Volviendo al paso inicial por defecto');
      }

      print('➡️ LactationFlowPage: Nuevo paso: $previousStep');
      setState(() {
        _currentStep = previousStep;
      });
    } else {
      print('🚪 LactationFlowPage: No hay historial, cerrando pantalla');
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveRecord() async {
    print('🔄 LactationFlowPage: Iniciando guardado de registro...');
    print('📊 LactationFlowPage: Datos del registro: $_data');
    print('📅 LactationFlowPage: Fecha seleccionada: ${widget.selectedDate}');
    print('🆔 LactationFlowPage: Registro existente: ${widget.existingRecord}');

    // Validar datos antes de guardar
    _validateAndLogData();

    try {
      // Crear objeto LactationRecord para guardar en Firestore
      final record = _createLactationRecord();
      print('🔥 LactationFlowPage: Guardando registro en Firestore...');
      print('💾 LactationFlowPage: Registro creado: ${record.toMap()}');

      // Guardar en Firestore usando LactationService
      await _lactationService.saveRecord(record);

      print('✅ LactationFlowPage: Registro guardado exitosamente en Firestore');
      Navigator.of(context).pop(true);
    } catch (e) {
      print('❌ LactationFlowPage: Error guardando en Firestore: $e');
      // Mostrar error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el registro: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    Duration duracion = Duration(minutes: 15); // Valor por defecto
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

    print('🔧 LactationFlowPage: Creando registro con datos:');
    print('   - Tipo: $tipoAlimentacion -> $tipo');
    print('   - Lado: $ladoPecho -> $pechoDado');
    print('   - Duración: $duracion');
    print('   - Volumen: $volumenExtraccion $unidadVolumen');
    print('   - Fecha: $recordDate');
    print('   - Veces pecho: $vecesPecho');
    print('   - Veces biberón: $vecesBiberon');

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
    );
  }

  void _validateAndLogData() {
    print('🔍 LactationFlowPage: Validando datos del registro...');

    // Validar tipo de alimentación
    if (_data.containsKey('type')) {
      print('✅ Tipo de alimentación: ${_data['type']}');
    } else {
      print('❌ ERROR: Tipo de alimentación no especificado');
    }

    // Validar lado del pecho (si aplica)
    if (_data.containsKey('side')) {
      print('✅ Lado del pecho: ${_data['side']}');
    } else if (_data['type'] == 'pecho' || _data['type'] == 'mixto') {
      print(
        '⚠️ ADVERTENCIA: Lado del pecho no especificado para lactancia materna',
      );
    }

    // Validar duración (si aplica)
    if (_data.containsKey('duration')) {
      print('✅ Duración: ${_data['duration']}');
    } else if (_data['type'] == 'pecho' || _data['type'] == 'mixto') {
      print('❌ ERROR: Duración no especificada para lactancia materna');
    }

    // Validar volumen (si aplica)
    if (_data.containsKey('volume')) {
      print('✅ Volumen: ${_data['volume']} ${_data['unit'] ?? 'ml'}');
    } else if (_data['type'] == 'biberon' || _data['type'] == 'mixto') {
      print('❌ ERROR: Volumen no especificado para biberón');
    }

    // Validar entrada manual
    if (_data.containsKey('manualEntry')) {
      print('📝 Entrada manual de duración: ${_data['manualEntry']}');
    }
    if (_data.containsKey('manualEntryVolume')) {
      print('📝 Entrada manual de volumen: ${_data['manualEntryVolume']}');
    }

    print('📋 Historial de pasos: $_history');
  }
}

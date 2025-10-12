import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../alerta_dialoge.dart';
import '../../domain/entities/lactation_record.dart';

class LactationRecordPage extends StatefulWidget {
  final DateTime? selectedDate;
  final LactationRecord? existingRecord;

  const LactationRecordPage({Key? key, this.selectedDate, this.existingRecord})
    : super(key: key);

  @override
  State<LactationRecordPage> createState() => _LactationRecordPageState();
}

class _LactationRecordPageState extends State<LactationRecordPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _volumenExtraccionController = TextEditingController();
  final _horasSuenoController = TextEditingController();
  final _vecesPechoController = TextEditingController();
  final _vecesBiberonController = TextEditingController();

  // Variables de estado
  String _seleccionVolumenUnidad = 'No';
  String _seleccionSuenoUnidad = 'No';
  String _seleccionPecho = 'Ninguna';

  bool _isLoading = false;

  // Controladores de animación
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.existingRecord != null) {
      // Cargar datos del registro existente
      final record = widget.existingRecord!;
      _volumenExtraccionController.text = record.volumenExtraccion.toString();
      _horasSuenoController.text = record.horasSuenoBebe.toString();
      _vecesPechoController.text = record.vecesPecho.toString();
      _vecesBiberonController.text = record.vecesBiberon.toString();

      // Configurar selecciones basadas en el registro existente
      _seleccionVolumenUnidad = record.unidadVolumen;
      _seleccionSuenoUnidad = record.unidadSueno;
      _seleccionPecho = record.pechoDado;
    } else {
      // Inicializar con valores por defecto
      _volumenExtraccionController.text = '0';
      _horasSuenoController.text = '0';
      _vecesPechoController.text = '0';
      _vecesBiberonController.text = '0';
    }
  }

  String _getValidationMessage(String field, int value) {
    switch (field) {
      case 'biberon':
        if (value > 10) return '⚠️ Muchas tomas de biberón';
        if (value == 0) return '✅ Solo lactancia materna';
        return '✅ Registro normal';
      case 'pecho':
        if (value > 12) return '⚠️ Muchas tomas de pecho';
        if (value == 0) return '⚠️ Sin lactancia materna';
        return '✅ Registro normal';
      case 'volumen':
        if (value > 300) return '⚠️ Volumen muy alto';
        if (value == 0) return 'ℹ️ Sin extracción';
        return '✅ Volumen normal';
      case 'sueno':
        if (value > 20) return '⚠️ Muchas horas de sueño';
        if (value < 8) return '⚠️ Pocas horas de sueño';
        return '✅ Sueño adecuado';
      default:
        return '';
    }
  }

  Color _getValidationColor(String field, int value) {
    switch (field) {
      case 'biberon':
        if (value > 10) return Colors.orange;
        if (value == 0) return Colors.green;
        return Colors.white;
      case 'pecho':
        if (value > 12) return Colors.orange;
        if (value == 0) return Colors.red;
        return Colors.white;
      case 'volumen':
        if (value > 300) return Colors.orange;
        if (value == 0) return Colors.blue;
        return Colors.white;
      case 'sueno':
        if (value > 20) return Colors.orange;
        if (value < 8) return Colors.red;
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Iniciar animaciones con delays escalonados
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _volumenExtraccionController.dispose();
    _horasSuenoController.dispose();
    _vecesPechoController.dispose();
    _vecesBiberonController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.existingRecord != null
              ? 'Editar Registro de Lactancia'
              : 'Registro de Lactancia',
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
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Stack(
          children: [
            // Fondo animado con partículas
            _buildAnimatedBackground(),

            // Contenido principal
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              // Header con icono
                              _buildHeader(),

                              const SizedBox(height: 30),

                              // Volumen de extracción
                              _buildVolumenExtraccionSection(),
                              const SizedBox(height: 20),

                              // Veces que se le dio biberón
                              _buildEnhancedNumberSelector(
                                title: "Veces que se le dio biberón",
                                subtitle: "Durante las últimas 24 horas",
                                icon: Icons.child_care,
                                controller: _vecesBiberonController,
                                minValue: 0,
                                maxValue: 20,
                                suggestions: [0, 1, 2, 3, 4, 5],
                                unit: "veces",
                              ),
                              const SizedBox(height: 20),

                              // Veces que se le dio pecho
                              _buildEnhancedNumberSelector(
                                title: "Veces que se le dio pecho",
                                subtitle: "Durante las últimas 24 horas",
                                icon: Icons.nature_people,
                                controller: _vecesPechoController,
                                minValue: 0,
                                maxValue: 20,
                                suggestions: [0, 1, 2, 3, 4, 5, 6, 7, 8],
                                unit: "veces",
                              ),
                              const SizedBox(height: 20),

                              // Horas de sueño
                              _buildHorasSuenoSection(),
                              const SizedBox(height: 30),

                              // Selección de pecho
                              _buildPechoSelection(),
                              const SizedBox(height: 40),

                              // Botón de registro
                              _buildActionButtons(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
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
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.child_care,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.existingRecord != null
                          ? 'Editar Registro de Lactancia'
                          : 'Registro de Lactancia',
                      style: GoogleFonts.quicksand(
                        fontSize: 24,
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
                    const SizedBox(height: 8),
                    Text(
                      'Registra los datos de lactancia de tu bebé',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
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

  Widget _buildVolumenExtraccionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildEnhancedNumberSelector(
                title: "Volumen de extracción",
                subtitle: "Cantidad extraída",
                icon: Icons.local_drink,
                controller: _volumenExtraccionController,
                minValue: 0,
                maxValue: 500,
                step: 1,
                suggestions: [0, 30, 60, 90, 120, 150, 200],
                unit: _seleccionVolumenUnidad == 'ml'
                    ? 'ml'
                    : _seleccionVolumenUnidad == 'oz'
                    ? 'oz'
                    : '',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                "Unidad",
                ["No", "ml", "oz"],
                _seleccionVolumenUnidad,
                (newValue) {
                  setState(() {
                    _seleccionVolumenUnidad = newValue!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHorasSuenoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildEnhancedNumberSelector(
                title: "Horas/minutos de sueño",
                subtitle: "Tiempo total de descanso",
                icon: Icons.timer,
                controller: _horasSuenoController,
                minValue: 0,
                maxValue: 24,
                step: 1,
                suggestions: [0, 1, 2, 3, 4, 6, 8, 10, 12],
                unit: _seleccionSuenoUnidad == 'Hrs'
                    ? 'hrs'
                    : _seleccionSuenoUnidad == 'Min'
                    ? 'min'
                    : '',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildDropdownField(
                "Unidad",
                ["No", "Hrs", "Min"],
                _seleccionSuenoUnidad,
                (newValue) {
                  setState(() {
                    _seleccionSuenoUnidad = newValue!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPechoSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pecho que dio a amamantar",
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildRadioOption(
                          'Izquierdo',
                          'Izquierdo',
                          Icons.touch_app,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildRadioOption(
                          'Derecho',
                          'Derecho',
                          Icons.touch_app,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRadioOption(
                          'Ambos pechos',
                          'Ambos pechos',
                          Icons.all_inclusive,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildRadioOption(
                          'Ninguno',
                          'Ninguno',
                          Icons.close,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String title, String value, IconData icon) {
    final isSelected = _seleccionPecho == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _seleccionPecho = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedNumberSelector({
    required String title,
    required String subtitle,
    required IconData icon,
    required TextEditingController controller,
    required int minValue,
    required int maxValue,
    required List<int> suggestions,
    required String unit,
    int step = 1,
  }) {
    int currentValue = int.tryParse(controller.text) ?? minValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y subtítulo
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // Selector principal
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Column(
                children: [
                  // Selector principal
                  Row(
                    children: [
                      // Icono
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 16,
                        ),
                      ),

                      // Valor actual
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              Text(
                                currentValue.toString(),
                                style: GoogleFonts.quicksand(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                unit,
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Botones de incremento/decremento
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNumberButton(Icons.keyboard_arrow_up, () {
                            if (currentValue < maxValue) {
                              currentValue += step;
                              controller.text = currentValue.toString();
                              setState(() {});
                            }
                          }, currentValue >= maxValue),
                          _buildNumberButton(Icons.keyboard_arrow_down, () {
                            if (currentValue > minValue) {
                              currentValue -= step;
                              controller.text = currentValue.toString();
                              setState(() {});
                            }
                          }, currentValue <= minValue),
                        ],
                      ),
                    ],
                  ),

                  // Sugerencias rápidas
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sugerencias rápidas:",
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: suggestions.map((value) {
                            final isSelected = currentValue == value;
                            return GestureDetector(
                              onTap: () {
                                controller.text = value.toString();
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.white.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.5)
                                        : Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  value.toString(),
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.8),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Feedback visual
                  if (title.contains('biberón'))
                    _buildValidationFeedback('biberon', currentValue)
                  else if (title.contains('pecho'))
                    _buildValidationFeedback('pecho', currentValue)
                  else if (title.contains('extracción'))
                    _buildValidationFeedback('volumen', currentValue)
                  else if (title.contains('sueño'))
                    _buildValidationFeedback('sueno', currentValue),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationFeedback(String field, int value) {
    final message = _getValidationMessage(field, value);
    final color = _getValidationColor(field, value);

    if (message.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            message.contains('✅')
                ? Icons.check_circle
                : message.contains('⚠️')
                ? Icons.warning
                : Icons.info,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(
    IconData icon,
    VoidCallback onPressed,
    bool isDisabled,
  ) {
    return Container(
      width: 32,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDisabled
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.2),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isDisabled
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String hintText,
    List<String> options,
    String selectedValue,
    Function(String?) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        isExpanded: true,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: Text(
                value,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.quicksand(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
        ),
        dropdownColor: Colors.transparent,
        iconEnabledColor: Colors.white.withValues(alpha: 0.8),
        style: GoogleFonts.quicksand(fontSize: 14, color: Colors.white),
        menuMaxHeight: 200,
        borderRadius: BorderRadius.circular(16),
        elevation: 8,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón principal (Guardar/Actualizar)
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
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
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.existingRecord != null
                        ? 'Actualizar Registro'
                        : 'Registrar Lactancia',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
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
          ),
        ),

        // Botón de borrado (solo si es edición)
        if (widget.existingRecord != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.red.withValues(alpha: 0.8),
                  Colors.redAccent.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _eliminarRegistro,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Eliminar Registro',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
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
            ),
          ),
        ],
      ],
    );
  }

  int _parseNumber(String text) {
    if (text.isEmpty) return 0;
    final intValue = int.tryParse(text);
    return intValue ?? 0;
  }

  Future<void> _eliminarRegistro() async {
    if (widget.existingRecord == null) return;

    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(24),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de advertencia
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withValues(alpha: 0.2),
                      Colors.redAccent.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '¿Eliminar Registro?',
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta acción no se puede deshacer. ¿Estás seguro de que quieres eliminar este registro de lactancia?',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.quicksand(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Eliminar',
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
      if (user == null) {
        DialogExample.showErrorDialog(
          context,
          'Error de Autenticación',
          'No hay usuario autenticado. Por favor, inicia sesión nuevamente.',
        );
        return;
      }

      // Eliminar el registro
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('situacion')
          .doc('seleccion')
          .collection('lactancia')
          .doc(widget.existingRecord!.id)
          .delete();

      // Mostrar mensaje de éxito y cerrar pantalla
      DialogExample.showSuccessDialog(
        context,
        'Registro Eliminado',
        'El registro de lactancia ha sido eliminado correctamente.',
        () {
          Navigator.of(context).pop(true); // Devolver true para indicar éxito
        },
      );
    } catch (e) {
      DialogExample.showErrorDialog(
        context,
        'Error al Eliminar',
        'No se pudo eliminar el registro. Por favor, inténtalo nuevamente.\n\nError: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarDatos() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        DialogExample.showErrorDialog(
          context,
          'Error de Autenticación',
          'No hay usuario autenticado. Por favor, inicia sesión nuevamente.',
        );
        return;
      }

      // Verificar si el usuario tiene situación Post-Parto
      final situacionDocRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('situacion')
          .doc('seleccion');

      final situacionSnapshot = await situacionDocRef.get();

      if (!situacionSnapshot.exists) {
        DialogExample.showInfoDialog(
          context,
          'Información Requerida',
          'Debes completar el proceso de onboarding y seleccionar la situación "Post-Parto" para poder registrar datos de lactancia.',
        );
        return;
      }

      // Verificar que el situationType sea 'postparto'
      final data = situacionSnapshot.data();
      final situationType = data?['situationType'] as String?;

      if (situationType != 'postparto') {
        DialogExample.showInfoDialog(
          context,
          'Información Requerida',
          'Debes completar el proceso de onboarding y seleccionar la situación "Post-Parto" para poder registrar datos de lactancia.',
        );
        return;
      }

      // Usar la fecha seleccionada o la fecha actual
      final fechaRegistro = widget.selectedDate ?? DateTime.now();

      // Para múltiples registros por día, usar timestamp actual para diferenciarlos
      final timestampRegistro =
          widget.existingRecord?.timestamp ?? DateTime.now();

      // Preparar datos de lactancia
      Map<String, dynamic> datosLactancia = {
        'volumen_extraccion': _parseNumber(_volumenExtraccionController.text),
        'unidad_volumen': _seleccionVolumenUnidad,
        'veces_biberon': _parseNumber(_vecesBiberonController.text),
        'veces_pecho': _parseNumber(_vecesPechoController.text),
        'pecho_dado': _seleccionPecho,
        'horas_sueno_bebe': _parseNumber(_horasSuenoController.text),
        'unidad_sueno': _seleccionSuenoUnidad,
        'timestamp': Timestamp.fromDate(timestampRegistro),
        'fecha_registro': fechaRegistro.toIso8601String(),
        'hora_registro': timestampRegistro
            .toIso8601String(), // Para diferenciar registros del mismo día
      };

      // Guardar o actualizar en la subcolección de lactancia
      if (widget.existingRecord != null) {
        // Actualizar registro existente
        await situacionDocRef
            .collection('lactancia')
            .doc(widget.existingRecord!.id)
            .update(datosLactancia);
      } else {
        // Crear nuevo registro
        await situacionDocRef.collection('lactancia').add(datosLactancia);
      }

      // Mostrar mensaje de éxito y cerrar pantalla
      DialogExample.showSuccessDialog(
        context,
        'Registro Exitoso',
        'Los datos de lactancia han sido registrados correctamente.',
        () {
          Navigator.of(context).pop(true); // Devolver true para indicar éxito
        },
      );
    } catch (e) {
      DialogExample.showErrorDialog(
        context,
        'Error al Guardar',
        'No se pudieron guardar los datos. Por favor, inténtalo nuevamente.\n\nError: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Custom painter para las partículas animadas del fondo
class _ParticlePainter extends CustomPainter {
  final double animationValue;

  _ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Dibujar partículas animadas
    for (int i = 0; i < 20; i++) {
      final x = (i * 50.0) % size.width;
      final y = (i * 30.0 + animationValue * 100) % size.height;
      canvas.drawCircle(Offset(x, y), 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

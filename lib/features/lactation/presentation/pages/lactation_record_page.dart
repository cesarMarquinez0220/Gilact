import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../alerta_dialoge.dart';
import '../../domain/entities/lactation_record.dart';
import '../../data/services/lactation_service.dart';

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

  // Servicio de lactancia
  late LactationService _lactationService;

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
    _initializeServices();
  }

  void _initializeServices() {
    _lactationService = LactationService(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
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
                              _buildIntegratedBottleSelector(),
                              const SizedBox(height: 20),

                              // Veces que se le dio pecho
                              _buildIntegratedBreastSelector(),
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
      children: [const SizedBox(height: 12), _buildIntegratedVolumeSelector()],
    );
  }

  Widget _buildIntegratedVolumeSelector() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.local_drink,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Volumen de extracción",
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Cantidad extraída",
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón de eliminar
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _volumenExtraccionController.text = '0';
                        _seleccionVolumenUnidad = 'No';
                      });
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Selector principal con dropdown integrado
              Row(
                children: [
                  // Flechas de incremento/decremento
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          final current =
                              int.tryParse(_volumenExtraccionController.text) ??
                              0;
                          if (current < 500) {
                            setState(() {
                              _volumenExtraccionController.text = (current + 1)
                                  .toString();
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final current =
                              int.tryParse(_volumenExtraccionController.text) ??
                              0;
                          if (current > 0) {
                            setState(() {
                              _volumenExtraccionController.text = (current - 1)
                                  .toString();
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  // Número central
                  Expanded(
                    child: Center(
                      child: Text(
                        _volumenExtraccionController.text.isEmpty
                            ? '0'
                            : _volumenExtraccionController.text,
                        style: GoogleFonts.quicksand(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Dropdown elegante con glassmorphism
                  Container(
                    width: 90,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _seleccionVolumenUnidad,
                            isExpanded: true,
                            dropdownColor: Colors.transparent,
                            style: GoogleFonts.quicksand(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            icon: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 16,
                              ),
                            ),
                            selectedItemBuilder: (BuildContext context) {
                              return ["No", "ml", "oz"].map<Widget>((
                                String value,
                              ) {
                                return Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            items: ["No", "ml", "oz"].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: _seleccionVolumenUnidad == value
                                        ? LinearGradient(
                                            colors: [
                                              Colors.white.withValues(
                                                alpha: 0.4,
                                              ),
                                              Colors.white.withValues(
                                                alpha: 0.3,
                                              ),
                                            ],
                                          )
                                        : null,
                                    border: _seleccionVolumenUnidad == value
                                        ? Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                            width: 1,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      value,
                                      style: GoogleFonts.quicksand(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _seleccionVolumenUnidad = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sugerencias rápidas
              Text(
                "Sugerencias rápidas:",
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [0, 30, 60, 90, 120, 150, 200].map((value) {
                  final isSelected =
                      int.tryParse(_volumenExtraccionController.text) == value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _volumenExtraccionController.text = value.toString();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        value.toString(),
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Estado actual
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _seleccionVolumenUnidad == 'No'
                          ? Colors.blue
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _seleccionVolumenUnidad == 'No'
                        ? "Sin extracción"
                        : "Extracción registrada",
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: _seleccionVolumenUnidad == 'No'
                          ? Colors.blue
                          : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorasSuenoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [const SizedBox(height: 12), _buildIntegratedSleepSelector()],
    );
  }

  Widget _buildIntegratedSleepSelector() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Horas/minutos de sueño",
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Tiempo total de descanso",
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón de eliminar
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _horasSuenoController.text = '0';
                        _seleccionSuenoUnidad = 'No';
                      });
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Selector principal con dropdown integrado
              Row(
                children: [
                  // Flechas de incremento/decremento
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          final current =
                              int.tryParse(_horasSuenoController.text) ?? 0;
                          if (current < 24) {
                            setState(() {
                              _horasSuenoController.text = (current + 1)
                                  .toString();
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final current =
                              int.tryParse(_horasSuenoController.text) ?? 0;
                          if (current > 0) {
                            setState(() {
                              _horasSuenoController.text = (current - 1)
                                  .toString();
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  // Número central
                  Expanded(
                    child: Center(
                      child: Text(
                        _horasSuenoController.text.isEmpty
                            ? '0'
                            : _horasSuenoController.text,
                        style: GoogleFonts.quicksand(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Dropdown integrado
                  Container(
                    width: 90,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _seleccionSuenoUnidad,
                            isExpanded: true,
                            dropdownColor: Colors.transparent,
                            style: GoogleFonts.quicksand(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            icon: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 16,
                              ),
                            ),
                            selectedItemBuilder: (BuildContext context) {
                              return ["No", "Hrs", "Min"].map<Widget>((
                                String value,
                              ) {
                                return Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            items: ["No", "Hrs", "Min"].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: _seleccionSuenoUnidad == value
                                        ? LinearGradient(
                                            colors: [
                                              Colors.white.withValues(
                                                alpha: 0.4,
                                              ),
                                              Colors.white.withValues(
                                                alpha: 0.3,
                                              ),
                                            ],
                                          )
                                        : null,
                                    border: _seleccionSuenoUnidad == value
                                        ? Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                            width: 1,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      value,
                                      style: GoogleFonts.quicksand(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _seleccionSuenoUnidad = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sugerencias rápidas
              Text(
                "Sugerencias rápidas:",
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [0, 1, 2, 3, 4, 6, 8, 10, 12].map((value) {
                  final isSelected =
                      int.tryParse(_horasSuenoController.text) == value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _horasSuenoController.text = value.toString();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        value.toString(),
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Estado actual
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _seleccionSuenoUnidad == 'No'
                          ? Colors.blue
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _seleccionSuenoUnidad == 'No'
                        ? "Sin registro de sueño"
                        : "Sueño registrado",
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: _seleccionSuenoUnidad == 'No'
                          ? Colors.blue
                          : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            borderRadius: BorderRadius.circular(16),
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

  Widget _buildIntegratedBottleSelector() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.child_care,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Veces que se le dio biberón",
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Durante las últimas 24 horas",
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón de eliminar
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _vecesBiberonController.text = '0';
                      });
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Selector principal
              Row(
                children: [
                  // Flechas de incremento/decremento
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          final current =
                              int.tryParse(_vecesBiberonController.text) ?? 0;
                          if (current < 10) {
                            setState(() {
                              _vecesBiberonController.text = (current + 1)
                                  .toString();
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final current =
                              int.tryParse(_vecesBiberonController.text) ?? 0;
                          if (current > 0) {
                            setState(() {
                              _vecesBiberonController.text = (current - 1)
                                  .toString();
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  // Número central
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            _vecesBiberonController.text.isEmpty
                                ? '0'
                                : _vecesBiberonController.text,
                            style: GoogleFonts.quicksand(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'veces',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Espacio para mantener simetría
                  const SizedBox(width: 60),
                ],
              ),

              const SizedBox(height: 16),

              // Sugerencias rápidas
              Text(
                "Sugerencias rápidas:",
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [0, 1, 2, 3, 4, 5].map((value) {
                  final isSelected =
                      int.tryParse(_vecesBiberonController.text) == value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _vecesBiberonController.text = value.toString();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        value.toString(),
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Estado actual
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: int.tryParse(_vecesBiberonController.text) == 0
                          ? Colors.blue
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    int.tryParse(_vecesBiberonController.text) == 0
                        ? "Solo lactancia materna"
                        : "Biberón registrado",
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: int.tryParse(_vecesBiberonController.text) == 0
                          ? Colors.blue
                          : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntegratedBreastSelector() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.nature_people,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Veces que se le dio pecho",
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Durante las últimas 24 horas",
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón de eliminar
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _vecesPechoController.text = '0';
                      });
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Selector principal
              Row(
                children: [
                  // Flechas de incremento/decremento
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          final current =
                              int.tryParse(_vecesPechoController.text) ?? 0;
                          if (current < 20) {
                            setState(() {
                              _vecesPechoController.text = (current + 1)
                                  .toString();
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final current =
                              int.tryParse(_vecesPechoController.text) ?? 0;
                          if (current > 0) {
                            setState(() {
                              _vecesPechoController.text = (current - 1)
                                  .toString();
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  // Número central
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            _vecesPechoController.text.isEmpty
                                ? '0'
                                : _vecesPechoController.text,
                            style: GoogleFonts.quicksand(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'veces',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Espacio para mantener simetría
                  const SizedBox(width: 60),
                ],
              ),

              const SizedBox(height: 16),

              // Sugerencias rápidas
              Text(
                "Sugerencias rápidas:",
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8].map((value) {
                  final isSelected =
                      int.tryParse(_vecesPechoController.text) == value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _vecesPechoController.text = value.toString();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        value.toString(),
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Estado actual
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: int.tryParse(_vecesPechoController.text) == 0
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    int.tryParse(_vecesPechoController.text) == 0
                        ? "Sin lactancia materna"
                        : "Lactancia registrada",
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: int.tryParse(_vecesPechoController.text) == 0
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

    print(
      '🔍 LactationRecordPage: Iniciando eliminación del registro: ${widget.existingRecord!.id}',
    );

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

    if (confirmed != true) {
      print('🔍 LactationRecordPage: Eliminación cancelada por el usuario');
      return;
    }

    print('🔍 LactationRecordPage: Usuario confirmó la eliminación');

    setState(() {
      _isLoading = true;
    });

    try {
      print(
        '🔍 LactationRecordPage: Iniciando eliminación con LactationService',
      );

      // Usar LactationService en lugar de Firestore directo
      await _lactationService.deleteRecord(widget.existingRecord!.id);

      print('🔍 LactationRecordPage: Registro eliminado exitosamente');

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
      print('❌ LactationRecordPage: Error eliminando registro: $e');
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

  /// Obtiene el ID del documento del usuario en Firestore
  Future<String?> _getUserDocumentId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Si el usuario tiene email, buscar por email primero
      if (user.email != null) {
        print(
          '🔍 LactationRecordPage: Buscando usuario por email: ${user.email}',
        );

        // Buscar el documento del usuario por email
        final userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userDocId = userQuery.docs.first.id;
          print(
            '🔍 LactationRecordPage: Usuario encontrado con ID: $userDocId',
          );
          return userDocId;
        } else {
          print('❌ LactationRecordPage: Usuario no encontrado por email');
        }
      }

      // Fallback: intentar con UID directamente
      print('🔍 LactationRecordPage: Intentando con UID: ${user.uid}');
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        print(
          '🔍 LactationRecordPage: Usuario encontrado con UID directo: ${user.uid}',
        );
        return user.uid;
      }

      print('❌ LactationRecordPage: No se encontró usuario en Firestore');
      return null;
    } catch (e) {
      print('❌ Error obteniendo ID del usuario: $e');
      return null;
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
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        DialogExample.showErrorDialog(
          context,
          'Error de Usuario',
          'No se pudo encontrar la información del usuario. Por favor, inicia sesión nuevamente.',
        );
        return;
      }

      final situacionDocRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userDocId)
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

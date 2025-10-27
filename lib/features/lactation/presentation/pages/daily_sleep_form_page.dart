import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import '../../../../alerta_dialoge.dart';

/// Página de registro diario de sueño del bebé (llamada desde notificación 8 AM)
class DailySleepFormPage extends StatefulWidget {
  const DailySleepFormPage({super.key});

  @override
  State<DailySleepFormPage> createState() => _DailySleepFormPageState();
}

class _DailySleepFormPageState extends State<DailySleepFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = false;
  double _hoursSlept = 8.0; // Valor inicial del slider
  int? _wakeUps; // Número de despertares (opcional)
  String? _quality; // Calidad del sueño (opcional)

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _hoursController.text = '8.0'; // Valor inicial
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
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _saveSleepRecord() async {
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

      final userId = await _getUserDocumentId();
      if (userId == null) {
        DialogExample.showErrorDialog(
          context,
          'Error de Usuario',
          'No se pudo encontrar la información del usuario.',
        );
        return;
      }

      // Fecha del día anterior (anoche)
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final fechaSueno =
          '${yesterday.year}-${_pad(yesterday.month)}-${_pad(yesterday.day)}';

      // Fecha de hoy para el registro
      final today = DateTime.now();
      final fechaRegistro =
          '${today.year}-${_pad(today.month)}-${_pad(today.day)}';
      final horaRegistro = '${_pad(today.hour)}:${_pad(today.minute)}';

      // Estructura de datos simplificada
      final sleepData = {
        'fecha_sueno': fechaSueno,
        'horas_dormido': _hoursSlept,
        if (_wakeUps != null) 'num_despertados': _wakeUps,
        if (_quality != null) 'calidad': _quality,
        'fecha_registro': fechaRegistro,
        'creado_en': DateTime.now(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Guardar en Firestore: /Users/{userId}/situacion/seleccion/sueno_diario/{recordId}
      final sleepCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('situacion')
          .doc('seleccion')
          .collection('sueno_diario');

      await sleepCollection.add(sleepData);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro de sueño guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        DialogExample.showErrorDialog(
          context,
          'Error al Guardar',
          'No se pudieron guardar los datos.\n\nError: ${e.toString()}',
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _pad(int number) => number.toString().padLeft(2, '0');

  Future<String?> _getUserDocumentId() async {
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

      return null;
    } catch (e) {
      return null;
    }
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
            SafeArea(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                overscroll: false, // Esto desactiva el resplandor
                  ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation( // Apply curve here
                           parent: _slideController,
                           curve: Curves.easeOutCubic,
                        )),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildHeader(),
                              const SizedBox(height: 30),
                              // Campo de horas de sueño
                              _buildHoursInput(),
                              const SizedBox(height: 24),
                              // Opcional: Despertares
                              _buildWakeUpsSection(),
                              const SizedBox(height: 24),
                              // Opcional: Calidad
                              _buildQualitySection(),
                              const SizedBox(height: 40),
                              // Botones
                              _buildActionButtons(),

                            ],
                          ),
                        ),
                      ),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.nights_stay, color: Colors.white, size: 50),
        ),
        const SizedBox(height: 32),
        const Text(
          'Registro de Sueño',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '¿Cuántas horas durmió el bebé anoche?',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHoursInput() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_hoursSlept.toStringAsFixed(1)}',
                    style: GoogleFonts.quicksand(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    ' horas',
                    style: GoogleFonts.quicksand(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: _hoursSlept,
                min: 0,
                max: 14,
                divisions: 56, // 0.25 horas por división
                label: '${_hoursSlept.toStringAsFixed(1)} horas',
                activeColor: Colors.white,
                inactiveColor: Colors.white.withValues(alpha: 0.3),
                onChanged: (value) {
                  setState(() {
                    _hoursSlept = value;
                    _hoursController.text = value.toStringAsFixed(1);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWakeUpsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cuántas veces se despertó? (Opcional)',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('0', 0),
            _buildChip('1', 1),
            _buildChip('2', 2),
            _buildChip('3+', 3),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String label, int value) {
    final isSelected = _wakeUps == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _wakeUps = isSelected ? null : value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: isSelected ? 1.0 : 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildQualitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo fue el sueño? (Opcional)',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildQualityChip('Bueno', 'bueno')),
            const SizedBox(width: 12),
            Expanded(child: _buildQualityChip('Regular', 'regular')),
            const SizedBox(width: 12),
            Expanded(child: _buildQualityChip('Malo', 'malo')),
          ],
        ),
      ],
    );
  }

  Widget _buildQualityChip(String label, String value) {
    final isSelected = _quality == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _quality = isSelected ? null : value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: isSelected ? 1.0 : 0.7),
          ),
        ),
      ),
    );
  }

Widget _buildActionButtons() {
    return Column(
      children: [
        // --- INICIO: Botón Guardar con el nuevo estilo ---
        Container( // 1. Contenedor para el gradiente y sombra
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient( // 2. Gradiente
              colors: [
                Color(0xFF1A365D), // Azul marino oscuro
                Color(0xFF4FD1C7), // Verde azulado medio
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16), // 3. Bordes redondeados
            boxShadow: [ // 4. Sombras
              BoxShadow(
                color: const Color(0xFF4FD1C7).withOpacity(0.4), // Sombra de color
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Sombra negra sutil
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton( // 5. ElevatedButton transparente DENTRO del Container
            onPressed: _isLoading ? null : _saveSleepRecord, // Mantiene tu lógica onPressed
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // Fondo transparente
              shadowColor: Colors.transparent,     // Sin sombra propia del botón
              shape: RoundedRectangleBorder(        // Forma que coincide con el Container
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox( // Mantiene tu indicador de carga
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white, // Color blanco para el indicador
                      strokeWidth: 2.5,
                    ),
                  )
                : Text( // 6. Texto con estilo blanco
                    'Guardar',
                    style: GoogleFonts.quicksand( // Usa GoogleFonts si prefieres
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Texto blanco
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
        // --- FIN: Botón Guardar con el nuevo estilo ---

        const SizedBox(height: 16),

        // Botón Cancelar (se mantiene igual)
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

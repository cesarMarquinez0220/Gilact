import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../alerta_dialoge.dart';
import '../../domain/entities/lactation_record.dart';
import '../../domain/services/lactation_decision_tree.dart';

/// Página principal del nuevo flujo de registro de lactancia
class LactationFlowPage extends StatefulWidget {
  final DateTime? selectedDate;
  final LactationRecord? existingRecord;

  const LactationFlowPage({super.key, this.selectedDate, this.existingRecord});

  @override
  State<LactationFlowPage> createState() => _LactationFlowPageState();
}

class _LactationFlowPageState extends State<LactationFlowPage>
    with TickerProviderStateMixin {
  // Controladores de animación
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  // Estado del flujo
  LactationFlowContext _context = LactationFlowContext(
    data: {},
    currentStep: LactationStep.initial,
    history: [],
  );

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadExistingRecord();
  }

  void _loadExistingRecord() {
    if (widget.existingRecord != null) {
      final record = widget.existingRecord!;
      _context = LactationFlowContext(
        data: {
          'initial': record.vecesPecho > 0 ? 'pecho' : 'biberon',
          'breastSide': record.pechoDado,
          'breastDuration': record.duracion.inMinutes.toString(),
          'bottleVolume': record.vecesBiberon > 0 ? '60' : '0',
          'sleepTime': record.horasSuenoBebe.toString(),
          'extractionVolume': record.volumenExtraccion.toString(),
        },
        currentStep: LactationStep.confirmation,
        history: ['Cargado desde registro existente'],
      );
    }
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

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Iniciar animaciones
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
            // Fondo animado
            _buildAnimatedBackground(),

            // Contenido principal
            SafeArea(
              child: Column(
                children: [
                  // Header con progreso
                  _buildHeader(),

                  // Contenido del paso actual
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: _buildStepContent(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
    final progress = _getProgress();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Icono y título
          Row(
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
                          ? 'lactation.calendar.editRecord'.tr()
                          : 'lactation.flow.recordTitle'.tr(),
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
                      'lactation.flow.stepByStepRecord'.tr(),
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

          const SizedBox(height: 20),

          // Barra de progreso
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Indicador de paso
          Text(
            'Paso ${_getCurrentStepNumber()} de ${_getTotalSteps()}',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    final message = LactationDecisionTree.getMessageForStep(
      _context.currentStep,
    );
    final options = LactationDecisionTree.getOptionsForStep(
      _context.currentStep,
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Mensaje del paso
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
                child: Text(
                  message,
                  textAlign: TextAlign.center,
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
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Opciones del paso
          Expanded(
            child: _context.currentStep == LactationStep.confirmation
                ? _buildConfirmationStep()
                : _buildOptionsGrid(options),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(List<LactationOption> options) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        return _buildOptionCard(option);
      },
    );
  }

  Widget _buildOptionCard(LactationOption option) {
    return GestureDetector(
      onTap: () => _selectOption(option),
      child: Container(
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono
                  Text(option.icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),

                  // Título
                  Text(
                    option.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Descripción
                  Text(
                    option.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationStep() {
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
              Text(
                'lactation.flow.summaryTitle'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Mostrar datos resumidos
              ..._buildSummaryItems(),

              const SizedBox(height: 30),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'lactation.flow.edit'.tr(),
                      Icons.edit,
                      Colors.orange,
                      () => _goToPreviousStep(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      'lactation.flow.save'.tr(),
                      Icons.save,
                      Colors.green,
                      _guardarRegistro,
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

  List<Widget> _buildSummaryItems() {
    final items = <Widget>[];

    if (_context.hasBreastfeeding) {
      final lado =
          _context.data['breastSide'] ??
          'lactation.recordForm.notSpecified'.tr();
      final duracion = _context.data['breastDuration'] ?? '0';
      items.add(
        _buildSummaryItem(
          '🤱',
          'lactation.flow.breastfeeding'.tr(),
          '$lado - $duracion min',
        ),
      );
    }

    final bottleVolume = _context.data['bottleVolume'];
    if (bottleVolume != null && bottleVolume != '0') {
      items.add(_buildSummaryItem('🍶', 'Biberón', '$bottleVolume ml'));
    }

    final sleepTime = _context.data['sleepTime'];
    if (sleepTime != null && sleepTime != '0') {
      items.add(
        _buildSummaryItem('😴', 'lactation.flow.sleep'.tr(), '$sleepTime min'),
      );
    }

    final extractionVolume = _context.data['extractionVolume'];
    if (extractionVolume != null && extractionVolume != '0') {
      items.add(_buildSummaryItem('💧', 'Extracción', '$extractionVolume ml'));
    }

    return items;
  }

  Widget _buildSummaryItem(String icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _selectOption(LactationOption option) {
    setState(() {
      _context = _context.addResponse(_context.currentStep.name, option.id);

      final nextStep = LactationDecisionTree.getNextStep(
        currentStep: _context.currentStep,
        userResponse: option.id,
        context: _context.data,
      );

      _context = _context.copyWith(currentStep: nextStep);
    });
  }

  void _goToPreviousStep() {
    if (_context.history.length > 1) {
      setState(() {
        // Implementar lógica para volver al paso anterior
        // Por simplicidad, volvemos al paso inicial
        _context = LactationFlowContext(
          data: {},
          currentStep: LactationStep.initial,
          history: [],
        );
      });
    }
  }

  double _getProgress() {
    final currentStepNumber = _getCurrentStepNumber();
    final totalSteps = _getTotalSteps();
    return currentStepNumber / totalSteps;
  }

  int _getCurrentStepNumber() {
    switch (_context.currentStep) {
      case LactationStep.initial:
        return 1;
      case LactationStep.breastOrBottle:
        return 2;
      case LactationStep.breastSide:
        return 3;
      case LactationStep.breastDuration:
        return 4;
      case LactationStep.bottleVolume:
        return 4;
      case LactationStep.sleepTime:
        return 5;
      case LactationStep.extractionVolume:
        return 6;
      case LactationStep.confirmation:
        return 7;
      case LactationStep.completed:
        return 8;
    }
  }

  int _getTotalSteps() {
    return 8;
  }

  Future<void> _guardarRegistro() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        DialogExample.showErrorDialog(
          context,
          'lactation.flow.authenticationError'.tr(),
          'lactation.flow.authenticationErrorMessage'.tr(),
        );
        return;
      }

      // Verificar situación Post-Parto
      final userDocId = await _getUserDocumentId();
      if (userDocId == null) {
        DialogExample.showErrorDialog(
          context,
          'lactation.flow.userError'.tr(),
          'lactation.flow.userErrorMessage'.tr(),
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
          'lactation.flow.infoRequired'.tr(),
          'lactation.flow.infoRequiredMessage'.tr(),
        );
        return;
      }

      final data = situacionSnapshot.data();
      final situationType = data?['situationType'] as String?;
      if (situationType != 'postparto') {
        DialogExample.showInfoDialog(
          context,
          'lactation.flow.infoRequired'.tr(),
          'lactation.flow.infoRequiredMessage'.tr(),
        );
        return;
      }

      // Preparar datos de lactancia
      final fechaRegistro = widget.selectedDate ?? DateTime.now();
      final timestampRegistro =
          widget.existingRecord?.timestamp ?? DateTime.now();

      Map<String, dynamic> datosLactancia = {
        'volumen_extraccion':
            int.tryParse(_context.data['extractionVolume'] ?? '0') ?? 0,
        'unidad_volumen': 'ml',
        'veces_biberon': _context.data['bottleVolume'] != '0' ? 1 : 0,
        'veces_pecho': _context.hasBreastfeeding ? 1 : 0,
        'pecho_dado': _context.data['breastSide'] ?? 'Ninguna',
        'horas_sueno_bebe':
            int.tryParse(_context.data['sleepTime'] ?? '0') ?? 0,
        'unidad_sueno': 'Min',
        'timestamp': Timestamp.fromDate(timestampRegistro),
        'fecha_registro': fechaRegistro.toIso8601String(),
        'hora_registro': timestampRegistro.toIso8601String(),
      };

      // Guardar o actualizar
      if (widget.existingRecord != null) {
        await situacionDocRef
            .collection('lactancia')
            .doc(widget.existingRecord!.id)
            .update(datosLactancia);
      } else {
        await situacionDocRef.collection('lactancia').add(datosLactancia);
      }

      DialogExample.showSuccessDialog(
        context,
        'lactation.flow.recordSuccess'.tr(),
        'lactation.flow.recordSavedSuccess'.tr(),
        () {
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      DialogExample.showErrorDialog(
        context,
        'lactation.flow.saveError'.tr(),
        'lactation.flow.saveErrorMessage'.tr(
          namedArgs: {'error': e.toString()},
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _eliminarRegistro() async {
    if (widget.existingRecord == null) return;

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
                'lactation.flow.deleteConfirmTitle'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'lactation.flow.deleteConfirmMessage'.tr(),
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
                        'common.cancel'.tr(),
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
                        'common.delete'.tr(),
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
          'lactation.flow.authenticationErrorMessage'.tr(),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('situacion')
          .doc('seleccion')
          .collection('lactancia')
          .doc(widget.existingRecord!.id)
          .delete();

      DialogExample.showSuccessDialog(
        context,
        'Registro Eliminado',
        'lactation.flow.recordDeletedSuccess'.tr(),
        () {
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      DialogExample.showErrorDialog(
        context,
        'lactation.flow.deleteError'.tr(),
        'lactation.flow.deleteErrorMessage'.tr(
          namedArgs: {'error': e.toString()},
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

    for (int i = 0; i < 20; i++) {
      final x = (i * 50.0) % size.width;
      final y = (i * 30.0 + animationValue * 100) % size.height;
      canvas.drawCircle(Offset(x, y), 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

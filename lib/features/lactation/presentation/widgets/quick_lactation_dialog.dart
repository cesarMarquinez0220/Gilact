import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';
import '../../domain/services/lactation_decision_tree.dart';

// Colores de la aplicación
class _AppColors {
  static const Color primary = Color(0xFF03A696);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
}

/// Dialog rápido para registro de lactancia
/// Ideal para registros simples y rápidos
class QuickLactationDialog extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onCancel;

  const QuickLactationDialog({
    super.key,
    this.selectedDate,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<QuickLactationDialog> createState() => _QuickLactationDialogState();
}

class _QuickLactationDialogState extends State<QuickLactationDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  LactationStep _currentStep = LactationStep.initial;
  Map<String, dynamic> _data = {};
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildDialogContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogContent() {
    final message = LactationDecisionTree.getMessageForStep(_currentStep);
    final options = LactationDecisionTree.getOptionsForStep(_currentStep);

    return Container(
      constraints: BoxConstraints(
        maxWidth: 400,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con progreso
              _buildHeader(),

              // Contenido principal con scroll
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pregunta actual
                      _buildQuestion(message),

                      const SizedBox(height: 20),

                      // Opciones
                      _buildOptions(options),

                      const SizedBox(height: 20),

                      // Botones de acción
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final progress = _getProgress();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _AppColors.primary.withValues(alpha: 0.1),
            _AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.child_care, color: _AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'lactation.quickDialog.title'.tr(),
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                color: _AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progreso
          LinearProgressIndicator(
            value: progress,
            backgroundColor: _AppColors.primary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(_AppColors.primary),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, color: _AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(List<LactationOption> options) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: options.map((option) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildOptionCard(option),
        );
      }).toList(),
    );
  }

  Widget _buildOptionCard(LactationOption option) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectOption(option),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(option.color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    option.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _AppColors.textPrimary,
                      ),
                    ),
                    if (option.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: _AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Botón atrás
        Expanded(
          child: OutlinedButton(
            onPressed: _goBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: _AppColors.textSecondary),
            ),
            child: Text(
              // UX Mejora: Cambia a "Cancelar" en el primer paso
              _currentStep == LactationStep.initial
                  ? 'lactation.quickDialog.cancel'.tr()
                  : 'lactation.quickDialog.back'.tr(),
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectOption(LactationOption option) {
    setState(() {
      print(
        '🔍 DEBUG: Seleccionando opción: ${option.id} en paso: ${_currentStep.name}',
      );

      // Si estamos en confirmación y seleccionamos "Guardar"
      if (_currentStep == LactationStep.confirmation &&
          option.id == 'confirm') {
        widget.onSave(_data);
        Navigator.of(context).pop();
        return;
      }

      // Actualizar datos
      _data[_currentStep.name] = option.id;
      _history.add('${_currentStep.name}: ${option.id}');

      print('🔍 DEBUG: Datos actualizados: $_data');
      print('🔍 DEBUG: Historial actualizado: $_history');

      // Continuar con el flujo normal
      final nextStep = LactationDecisionTree.getNextStep(
        currentStep: _currentStep,
        userResponse: option.id,
        context: _data,
      );

      print('🔍 DEBUG: Siguiente paso: ${nextStep.name}');
      _currentStep = nextStep;
    });
  }

  void _goToPreviousStep() {
    print('🔍 DEBUG: Navegando hacia atrás desde: ${_currentStep.name}');
    print('🔍 DEBUG: Historial (antes): $_history');
    print('🔍 DEBUG: Datos (antes): $_data');

    if (_history.isNotEmpty) {
      // 1. Obtener y remover la última decisión del historial
      //    Ejemplo: "breastDuration: 10min"
      final String lastDecision = _history.removeLast();

      // 2. Extraer el nombre del *paso* de esa decisión
      //    Ejemplo: "breastDuration"
      final String stepNameKey = lastDecision.split(':').first;

      // 3. Limpiar los datos del paso que estamos deshaciendo
      //    Ejemplo: _data.remove("breastDuration")
      _data.remove(stepNameKey);

      // 4. Buscar el enum 'LactationStep' que coincida con ese nombre
      LactationStep previousStep;
      try {
        previousStep = LactationStep.values.firstWhere(
          (e) => e.name == stepNameKey,
        );
      } catch (e) {
        // Si falla (no debería pasar), volver al inicio
        print('Error al parsear el paso anterior: $e');
        previousStep = LactationStep.initial;
      }

      // 5. Establecer el paso actual a ese paso
      //    Así volvemos a la pantalla de "breastDuration"
      _currentStep = previousStep;

      print('🔍 DEBUG: Nuevo paso: ${_currentStep.name}');
      print('🔍 DEBUG: Historial (después): $_history');
      print('🔍 DEBUG: Datos (después): $_data');
    } else {
      // No hay historial, así que ya estamos en el inicio
      print('🔍 DEBUG: No hay historial, volviendo a initial');
      _currentStep = LactationStep.initial;
      _data.clear();
    }
  }

  void _goBack() {
    setState(() {
      if (_currentStep == LactationStep.initial) {
        // Si estamos en el paso inicial, cerrar el diálogo
        Navigator.of(context).pop();
        widget.onCancel?.call();
      } else {
        // Ir al paso anterior
        _goToPreviousStep();
      }
    });
  }

  double _getProgress() {
    switch (_currentStep) {
      case LactationStep.initial:
        return 0.0;
      case LactationStep.breastSide:
        return 0.2;
      case LactationStep.breastDuration:
        return 0.4;
      case LactationStep.bottleVolume:
        return 0.6;
      case LactationStep.confirmation:
        return 0.8;
      case LactationStep.completed:
        return 1.0;
      default:
        return 0.0;
    }
  }
}

/// Widget para mostrar el dialog de lactancia rápida
class QuickLactationButton extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onCancel;

  const QuickLactationButton({
    super.key,
    this.selectedDate,
    required this.onSave,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showQuickDialog(context),
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'lactation.quickDialog.quickRegisterButton'.tr(),
        style: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
    );
  }

  void _showQuickDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuickLactationDialog(
        selectedDate: selectedDate,
        onSave: onSave,
        onCancel: onCancel,
      ),
    );
  }
}

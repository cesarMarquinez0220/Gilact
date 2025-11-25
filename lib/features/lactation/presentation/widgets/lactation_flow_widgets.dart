import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../domain/services/lactation_decision_tree.dart';

/// Widget para mostrar opciones de lactancia de forma elegante
class LactationOptionCard extends StatelessWidget {
  final LactationOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const LactationOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    Colors.white.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.3),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.15),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: isSelected ? 15 : 10,
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
                  // Icono con animación
                  AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      option.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
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

                  // Indicador de selección
                  if (isSelected) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar el progreso del flujo
class LactationProgressIndicator extends StatelessWidget {
  final double progress;
  final int currentStep;
  final int totalSteps;

  const LactationProgressIndicator({
    super.key,
    required this.progress,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de progreso
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
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
          'Paso $currentStep de $totalSteps',
          style: GoogleFonts.quicksand(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar el mensaje del paso actual
class LactationStepMessage extends StatelessWidget {
  final String message;
  final String? subtitle;

  const LactationStepMessage({Key? key, required this.message, this.subtitle})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          child: Column(
            children: [
              Text(
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
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar un resumen de los datos ingresados
class LactationSummaryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final bool isLoading;

  const LactationSummaryCard({
    Key? key,
    required this.data,
    required this.onEdit,
    required this.onSave,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              // Título
              Row(
                children: [
                  const Icon(Icons.checklist, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Resumen del Registro',
                    style: GoogleFonts.quicksand(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Items del resumen
              ..._buildSummaryItems(),

              const SizedBox(height: 30),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Editar',
                      Icons.edit,
                      Colors.orange,
                      onEdit,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      'Guardar',
                      Icons.save,
                      Colors.green,
                      onSave,
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

    // Lactancia materna
    if (data['breastSide'] != null && data['breastSide'] != '') {
      final lado = data['breastSide'];
      final duracion = data['breastDuration'] ?? '0';
      items.add(
        _buildSummaryItem('🤱', 'Lactancia Materna', '$lado - $duracion min'),
      );
    }

    // Biberón
    final bottleVolume = data['bottleVolume'];
    if (bottleVolume != null && bottleVolume != '0') {
      items.add(_buildSummaryItem('🍶', 'Biberón', '$bottleVolume ml'));
    }

    // Sueño
    final sleepTime = data['sleepTime'];
    if (sleepTime != null && sleepTime != '0') {
      items.add(_buildSummaryItem('😴', 'Sueño', '$sleepTime min'));
    }

    // Extracción
    final extractionVolume = data['extractionVolume'];
    if (extractionVolume != null && extractionVolume != '0') {
      items.add(_buildSummaryItem('💧', 'Extracción', '$extractionVolume ml'));
    }

    if (items.isEmpty) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'No hay datos registrados',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
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
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
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
}

/// Widget para mostrar sugerencias inteligentes basadas en el contexto
class LactationSuggestionsWidget extends StatelessWidget {
  final LactationStep currentStep;
  final Map<String, dynamic> context;
  final Function(String) onSuggestionTap;

  const LactationSuggestionsWidget({
    Key? key,
    required this.currentStep,
    required this.context,
    required this.onSuggestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final suggestions = _getSuggestions();

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sugerencias',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return GestureDetector(
                onTap: () => onSuggestionTap(suggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<String> _getSuggestions() {
    switch (currentStep) {
      case LactationStep.breastDuration:
        return ['5 min', '10 min', '15 min', '20 min'];
      case LactationStep.bottleVolume:
        return ['60 ml', '90 ml', '120 ml', '150 ml'];
      case LactationStep.sleepTime:
        return ['30 min', '1 hora', '2 horas', '3 horas'];
      case LactationStep.extractionVolume:
        return ['30 ml', '60 ml', '90 ml', '120 ml'];
      default:
        return [];
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

// Colores de la aplicación
class _AppColors {
  static const Color primary = Color(0xFF03A696);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color success = Color(0xFF27AE60);
}

/// Widget para entrada manual de volumen de biberón
class BottleVolumeInputWidget extends StatefulWidget {
  final Function(double volume, String unit) onVolumeEntered;
  final double? initialVolume;
  final String? initialUnit;

  const BottleVolumeInputWidget({
    super.key,
    required this.onVolumeEntered,
    this.initialVolume,
    this.initialUnit,
  });

  @override
  State<BottleVolumeInputWidget> createState() =>
      _BottleVolumeInputWidgetState();
}

class _BottleVolumeInputWidgetState extends State<BottleVolumeInputWidget> {
  final TextEditingController _volumeController = TextEditingController();
  String _selectedUnit = 'ml';
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.initialUnit ?? 'ml';
    if (widget.initialVolume != null) {
      _volumeController.text = widget.initialVolume!.toString();
      _isValid = true;
    }
    _volumeController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _volumeController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final volume = double.tryParse(_volumeController.text);
    setState(() {
      _isValid =
          volume != null && volume > 0 && volume <= 500; // Máximo 500ml/oz
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isValid ? _AppColors.success : _AppColors.textSecondary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.local_drink, color: _AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Volumen del Biberón',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Campo de entrada
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _volumeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    hintText: 'Ej: 120',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorText: _volumeController.text.isNotEmpty && !_isValid
                        ? 'Ingresa un valor válido (1-500)'
                        : null,
                    prefixIcon: const Icon(
                      Icons.straighten,
                      color: _AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedUnit,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'oz', child: Text('oz')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedUnit = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Información adicional
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: _AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rango recomendado: 30-240 ml (1-8 oz)',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: _AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Botón continuar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isValid ? _continue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'Guardar',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _continue() {
    final volume = double.parse(_volumeController.text);
    widget.onVolumeEntered(volume, _selectedUnit);
  }
}

/// Widget para entrada manual de duración de lactancia materna
class BreastfeedingDurationInputWidget extends StatefulWidget {
  final Function(Duration duration) onDurationEntered;
  final Duration? initialDuration;
  final String buttonText;

  const BreastfeedingDurationInputWidget({
    super.key,
    required this.onDurationEntered,
    this.initialDuration,
    this.buttonText = 'Guardar',
  });

  @override
  State<BreastfeedingDurationInputWidget> createState() =>
      _BreastfeedingDurationInputWidgetState();
}

class _BreastfeedingDurationInputWidgetState
    extends State<BreastfeedingDurationInputWidget> {
  final TextEditingController _minutesController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDuration != null) {
      _minutesController.text = widget.initialDuration!.inMinutes.toString();
      _isValid = true;
    }
    _minutesController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    setState(() {
      _isValid = minutes > 0 && minutes <= 120; // Máximo 2 horas
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isValid ? _AppColors.success : _AppColors.textSecondary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.access_time, color: _AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Duración de Lactancia',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Campo de entrada
          TextField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Duración en minutos',
              hintText: 'Ej: 15',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _AppColors.primary, width: 2),
              ),
              prefixIcon: const Icon(Icons.timer, color: _AppColors.primary),
            ),
          ),

          const SizedBox(height: 16),

          // Botones rápidos
          Text(
            'Tiempos comunes:',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickTimeButton('5 min', 5),
              _buildQuickTimeButton('10 min', 10),
              _buildQuickTimeButton('15 min', 15),
              _buildQuickTimeButton('20 min', 20),
              _buildQuickTimeButton('30 min', 30),
            ],
          ),

          const SizedBox(height: 16),

          // Información adicional
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: _AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tiempo promedio: 10-20 minutos por pecho',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: _AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Botón continuar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isValid ? _continue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                widget.buttonText,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTimeButton(String label, int minutes) {
    return ActionChip(
      label: Text(
        label,
        style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      onPressed: () {
        _minutesController.text = minutes.toString();
        _validateInput();
      },
      backgroundColor: _AppColors.primary.withValues(alpha: 0.1),
      side: BorderSide(color: _AppColors.primary.withValues(alpha: 0.3)),
      labelStyle: const TextStyle(color: _AppColors.primary),
    );
  }

  void _continue() {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final duration = Duration(minutes: minutes);
    widget.onDurationEntered(duration);
  }
}

/// Widget para entrada manual de notas adicionales
class NotesInputWidget extends StatefulWidget {
  final Function(String notes) onNotesEntered;
  final String? initialNotes;

  const NotesInputWidget({
    super.key,
    required this.onNotesEntered,
    this.initialNotes,
  });

  @override
  State<NotesInputWidget> createState() => _NotesInputWidgetState();
}

class _NotesInputWidgetState extends State<NotesInputWidget> {
  final TextEditingController _notesController = TextEditingController();
  final List<String> _quickNotes = [
    'Bebé muy activo',
    'Se durmió mientras comía',
    'Molestias en el pecho',
    'Buen agarre',
    'Necesitó ayuda',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialNotes != null) {
      _notesController.text = widget.initialNotes!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _AppColors.textSecondary, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.note_add, color: _AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Notas Adicionales',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Campo de texto
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Observaciones (opcional)',
              hintText: 'Ej: El bebé se durmió mientras comía...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _AppColors.primary, width: 2),
              ),
              prefixIcon: const Icon(Icons.edit_note, color: _AppColors.primary),
            ),
          ),

          const SizedBox(height: 16),

          // Notas rápidas
          Text(
            'Notas comunes:',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickNotes.map((note) {
              return ActionChip(
                label: Text(
                  note,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  final currentText = _notesController.text;
                  final newText = currentText.isEmpty
                      ? note
                      : '$currentText, $note';
                  _notesController.text = newText;
                },
                backgroundColor: _AppColors.primary.withValues(alpha: 0.1),
                side: BorderSide(
                  color: _AppColors.primary.withValues(alpha: 0.3),
                ),
                labelStyle: const TextStyle(color: _AppColors.primary),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Botones
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => widget.onNotesEntered(''),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: _AppColors.textSecondary),
                  ),
                  child: Text(
                    'Saltar',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _continue() {
    widget.onNotesEntered(_notesController.text.trim());
  }
}

/// Widget para mostrar resumen antes de guardar
class LactationSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onSave;
  final VoidCallback onEdit;

  const LactationSummaryWidget({
    super.key,
    required this.data,
    required this.onSave,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _AppColors.success, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.check_circle, color: _AppColors.success, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resumen del Registro',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Datos del resumen
          _buildSummaryItem('Tipo', _getTypeDisplay()),
          _buildSummaryItem('Duración', _getDurationDisplay()),
          _buildSummaryItem('Volumen', _getVolumeDisplay()),
          if (data['notes'] != null && data['notes'].toString().isNotEmpty)
            _buildSummaryItem('Notas', data['notes'].toString()),

          const SizedBox(height: 20),

          // Botones
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: _AppColors.textSecondary),
                  ),
                  child: Text(
                    'Editar',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Guardar',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: _AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeDisplay() {
    final type = data['type'] ?? 'unknown';
    switch (type) {
      case 'breast':
        return '🤱 Lactancia Materna';
      case 'bottle':
        return '🍶 Biberón';
      case 'mixed':
        return '🔄 Mixto';
      default:
        return 'Desconocido';
    }
  }

  String _getDurationDisplay() {
    final duration = data['duration'];
    if (duration == null) return 'lactation.recordForm.notSpecified'.tr();

    if (duration is Duration) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      if (minutes > 0) {
        return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes} minutos';
      } else {
        return '${seconds} segundos';
      }
    }

    return duration.toString();
  }

  String _getVolumeDisplay() {
    final volume = data['volume'];
    final unit = data['unit'] ?? 'ml';

    if (volume == null) return 'lactation.recordForm.notSpecified'.tr();
    return '${volume.toStringAsFixed(0)} $unit';
  }
}

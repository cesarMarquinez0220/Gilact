import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/entities/lactation_record.dart';
import '../../data/services/lactation_service.dart';
import '../../../../alerta_dialoge.dart';

class LactationRecordFormDialog extends StatefulWidget {
  final DateTime selectedDate;
  final LactationRecord? existingRecord;
  final VoidCallback onRecordSaved;

  const LactationRecordFormDialog({
    super.key,
    required this.selectedDate,
    this.existingRecord,
    required this.onRecordSaved,
  });

  @override
  State<LactationRecordFormDialog> createState() =>
      _LactationRecordFormDialogState();
}

class _LactationRecordFormDialogState extends State<LactationRecordFormDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _volumenExtraccionController = TextEditingController();
  final _horasSuenoController = TextEditingController();
  final _vecesPechoController = TextEditingController();
  final _vecesBiberonController = TextEditingController();
  final _notasController = TextEditingController();

  // Variables de estado
  String _seleccionVolumenUnidad = 'No';
  String _seleccionSuenoUnidad = 'No';
  String _seleccionPecho = 'Ninguna';
  LactationType _tipoLactancia = LactationType.breastfeeding;
  Duration _duracion = const Duration(minutes: 15);
  DateTime _fechaHora = DateTime.now();

  bool _isLoading = false;

  // Controladores de animación
  late AnimationController _slideController;
  late AnimationController _fadeController;
  // Campos de animación no usados - mantenidos para uso futuro
  // ignore: unused_field
  late Animation<double> _slideAnimation;
  // ignore: unused_field
  late Animation<double> _fadeAnimation;

  late LactationService _lactationService;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initServices();
    _initializeForm();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();
  }

  void _initServices() {
    _lactationService = LactationService(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
  }

  void _initializeForm() {
    if (widget.existingRecord != null) {
      final record = widget.existingRecord!;
      _volumenExtraccionController.text = record.volumenExtraccion.toString();
      _horasSuenoController.text = record.horasSuenoBebe.toString();
      _vecesPechoController.text = record.vecesPecho.toString();
      _vecesBiberonController.text = record.vecesBiberon.toString();
      _notasController.text = record.notas ?? '';

      _seleccionVolumenUnidad = record.unidadVolumen;
      _seleccionSuenoUnidad = record.unidadSueno;
      _seleccionPecho = record.pechoDado;
      _tipoLactancia = record.tipo;
      _duracion = record.duracion;
      _fechaHora = record.fechaRegistro;
    } else {
      _fechaHora = widget.selectedDate;
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _volumenExtraccionController.dispose();
    _horasSuenoController.dispose();
    _vecesPechoController.dispose();
    _vecesBiberonController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: ScrollConfiguration(
                      // <-- 1. Envuelve con esto
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(overscroll: false),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildDateTimeSection(),
                              const SizedBox(height: 20),
                              _buildTipoLactanciaSection(),
                              const SizedBox(height: 20),
                              _buildDuracionSection(),
                              const SizedBox(height: 20),
                              _buildVolumenExtraccionSection(),
                              const SizedBox(height: 20),
                              _buildVecesPechoSection(),
                              const SizedBox(height: 20),
                              _buildVecesBiberonSection(),
                              const SizedBox(height: 20),
                              _buildHorasSuenoSection(),
                              const SizedBox(height: 20),
                              _buildNotasSection(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.child_care, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existingRecord != null
                      ? 'lactation.calendar.editRecord'.tr()
                      : 'common.newRecord'.tr(),
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${_fechaHora.day}/${_fechaHora.month}/${_fechaHora.year}',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fecha y Hora',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${_fechaHora.day}/${_fechaHora.month}/${_fechaHora.year}',
                          style: GoogleFonts.quicksand(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${_fechaHora.hour.toString().padLeft(2, '0')}:${_fechaHora.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.quicksand(),
                        ),
                      ],
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

  Widget _buildTipoLactanciaSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de Lactancia',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTipoButton(
                'Directa',
                LactationType.breastfeeding,
                Icons.child_care,
              ),
              const SizedBox(width: 8),
              _buildTipoButton(
                'Extracción',
                LactationType.pumping,
                Icons.water_drop,
              ),
              const SizedBox(width: 8),
              _buildTipoButton(
                'Biberón',
                LactationType.bottle,
                Icons.local_drink,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipoButton(String label, LactationType type, IconData icon) {
    final isSelected = _tipoLactancia == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tipoLactancia = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF667eea) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDuracionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duración',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumberSelector(
                  'Minutos',
                  _duracion.inMinutes,
                  (value) =>
                      setState(() => _duracion = Duration(minutes: value)),
                  0,
                  180,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumenExtraccionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Volumen de Extracción',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _volumenExtraccionController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixText: _seleccionVolumenUnidad == 'No'
                        ? ''
                        : _seleccionVolumenUnidad,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _seleccionVolumenUnidad,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['No', 'ml', 'oz'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _seleccionVolumenUnidad = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVecesPechoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Veces al Pecho',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumberSelector(
                  'Cantidad',
                  int.tryParse(_vecesPechoController.text) ?? 0,
                  (value) => _vecesPechoController.text = value.toString(),
                  0,
                  20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _seleccionPecho,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['Ninguna', 'Izquierdo', 'Derecho', 'Ambos'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _seleccionPecho = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVecesBiberonSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Veces Biberón',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberSelector(
            'Cantidad',
            int.tryParse(_vecesBiberonController.text) ?? 0,
            (value) => _vecesBiberonController.text = value.toString(),
            0,
            20,
          ),
        ],
      ),
    );
  }

  Widget _buildHorasSuenoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horas de Sueño del Bebé',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _horasSuenoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixText: _seleccionSuenoUnidad == 'No'
                        ? ''
                        : _seleccionSuenoUnidad,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _seleccionSuenoUnidad,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['No', 'Hrs', 'Min'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _seleccionSuenoUnidad = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotasSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notas Adicionales',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notasController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Observaciones sobre la lactancia...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberSelector(
    String label,
    int value,
    Function(int) onChanged,
    int min,
    int max,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove),
                iconSize: 20,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.existingRecord != null ? 'Actualizar' : 'Guardar',
                      style: GoogleFonts.quicksand(
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (!mounted) return;

    if (date != null) {
      setState(() {
        _fechaHora = DateTime(
          date.year,
          date.month,
          date.day,
          _fechaHora.hour,
          _fechaHora.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaHora),
    );

    if (!mounted) return;

    if (time != null) {
      setState(() {
        _fechaHora = DateTime(
          _fechaHora.year,
          _fechaHora.month,
          _fechaHora.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final record = LactationRecord(
        id: widget.existingRecord?.id ?? '',
        fechaRegistro: _fechaHora,
        duracion: _duracion,
        tipo: _tipoLactancia,
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
        lado: _seleccionPecho == 'Ninguna'
            ? null
            : _seleccionPecho.toLowerCase(),
        volumenExtraccion: int.tryParse(_volumenExtraccionController.text) ?? 0,
        unidadVolumen: _seleccionVolumenUnidad,
        vecesBiberon: int.tryParse(_vecesBiberonController.text) ?? 0,
        vecesPecho: int.tryParse(_vecesPechoController.text) ?? 0,
        pechoDado: _seleccionPecho,
        horasSuenoBebe: int.tryParse(_horasSuenoController.text) ?? 0,
        unidadSueno: _seleccionSuenoUnidad,
        timestamp: DateTime.now(),
        fechaRegistroString: _fechaHora.toIso8601String(),
      );

      if (widget.existingRecord != null) {
        await _lactationService.updateRecord(record.id, record);
      } else {
        await _lactationService.saveRecord(record);
      }

      if (!mounted) return;

      Navigator.of(context).pop();
      widget.onRecordSaved();

      DialogExample.showSuccessDialog(
        context,
        'lactation.flow.recordSuccess'.tr(),
        widget.existingRecord != null
            ? 'El registro de lactancia ha sido actualizado correctamente.'
            : 'El registro de lactancia ha sido guardado correctamente.',
        () {},
      );
    } catch (e) {
      if (!mounted) return;

      DialogExample.showErrorDialog(
        context,
        'Error al Guardar',
        'No se pudieron guardar los datos. Por favor, inténtalo nuevamente.\n\nError: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

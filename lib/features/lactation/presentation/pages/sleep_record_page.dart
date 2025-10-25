import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../alerta_dialoge.dart';
import '../../domain/entities/sleep_record.dart';
import '../widgets/sleep_record_form_widget.dart';

/// Página para registrar las horas de sueño del bebé
class SleepRecordPage extends StatefulWidget {
  final SleepRecord? existingRecord;
  final bool isFromNotification;

  const SleepRecordPage({
    super.key,
    this.existingRecord,
    this.isFromNotification = false,
  });

  @override
  State<SleepRecordPage> createState() => _SleepRecordPageState();
}

class _SleepRecordPageState extends State<SleepRecordPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controladores de tiempo
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _notesController;

  // Variables de estado
  DateTime? _sleepStartTime;
  DateTime? _sleepEndTime;
  SleepQuality _selectedQuality = SleepQuality.good;
  bool _isLoading = false;
  bool _isEditing = false;

  // Animaciones
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _setupExistingRecord();
  }

  void _initializeControllers() {
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    _notesController = TextEditingController();
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

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
  }

  void _setupExistingRecord() {
    if (widget.existingRecord != null) {
      _isEditing = true;
      final record = widget.existingRecord!;

      _sleepStartTime = record.sleepStartTime;
      _sleepEndTime = record.sleepEndTime;
      _selectedQuality = record.quality;
      _notesController.text = record.notes ?? '';

      _startTimeController.text = DateFormat('HH:mm').format(_sleepStartTime!);
      _endTimeController.text = DateFormat('HH:mm').format(_sleepEndTime!);
    } else {
      // Valores por defecto para nuevo registro
      final now = DateTime.now();
      _sleepStartTime = now.subtract(const Duration(hours: 2));
      _sleepEndTime = now;

      _startTimeController.text = DateFormat('HH:mm').format(_sleepStartTime!);
      _endTimeController.text = DateFormat('HH:mm').format(_sleepEndTime!);
    }
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _notesController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Registro de Sueño' : 'Registrar Sueño',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _handleBack(),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header con información
              _buildHeader(),

              // Formulario principal
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SleepRecordFormWidget(
                  slideAnimation: _slideAnimation,
                  fadeAnimation: _fadeAnimation,
                  startTimeController: _startTimeController,
                  endTimeController: _endTimeController,
                  notesController: _notesController,
                  selectedQuality: _selectedQuality,
                  isLoading: _isLoading,
                  onStartTimeTap: _selectStartTime,
                  onEndTimeTap: _selectEndTime,
                  onQualityChanged: (quality) {
                    setState(() {
                      _selectedQuality = quality;
                    });
                  },
                ),
              ),

              // Botones de acción
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Icono principal
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.bedtime, color: Colors.white, size: 40),
              ),

              const SizedBox(height: 16),

              // Título
              Text(
                _isEditing ? 'Editar Sueño' : 'Registrar Sueño',
                style: GoogleFonts.quicksand(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // Subtítulo
              Text(
                _isEditing
                    ? 'Actualiza la información del sueño'
                    : 'Registra las horas de sueño de tu bebé',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              if (widget.isFromNotification) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Recordatorio de sueño',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Botón principal
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveSleepRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
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
                      _isEditing ? 'Actualizar Registro' : 'Guardar Registro',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Botón secundario
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _handleBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_sleepStartTime ?? DateTime.now()),
    );

    if (time != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      setState(() {
        _sleepStartTime = selectedDateTime;
        _startTimeController.text = DateFormat(
          'HH:mm',
        ).format(selectedDateTime);
      });

      // Actualizar duración automáticamente
      _updateDuration();
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_sleepEndTime ?? DateTime.now()),
    );

    if (time != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      setState(() {
        _sleepEndTime = selectedDateTime;
        _endTimeController.text = DateFormat('HH:mm').format(selectedDateTime);
      });

      // Actualizar duración automáticamente
      _updateDuration();
    }
  }

  void _updateDuration() {
    if (_sleepStartTime != null && _sleepEndTime != null) {
      // Si el tiempo de fin es menor que el de inicio, asumir que es del día siguiente
      if (_sleepEndTime!.isBefore(_sleepStartTime!)) {
        _sleepEndTime = _sleepEndTime!.add(const Duration(days: 1));
      }
    }
  }

  Future<void> _saveSleepRecord() async {
    if (!_formKey.currentState!.validate()) return;

    if (_sleepStartTime == null || _sleepEndTime == null) {
      DialogExample.showErrorDialog(
        context,
        'Error de Validación',
        'Por favor selecciona tanto la hora de inicio como la de fin.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Aquí se implementará la lógica para guardar en Firestore
      // Por ahora simulamos el guardado
      await Future.delayed(const Duration(seconds: 1));

      DialogExample.showSuccessDialog(
        context,
        'Registro Guardado',
        _isEditing
            ? 'El registro de sueño ha sido actualizado exitosamente.'
            : 'El registro de sueño ha sido guardado exitosamente.',
        () {
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      DialogExample.showErrorDialog(
        context,
        'Error',
        'No se pudo guardar el registro. Inténtalo nuevamente.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleBack() {
    if (_hasUnsavedChanges()) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  bool _hasUnsavedChanges() {
    if (widget.existingRecord == null) {
      // Nuevo registro - verificar si hay datos ingresados
      return _startTimeController.text.isNotEmpty ||
          _endTimeController.text.isNotEmpty ||
          _notesController.text.isNotEmpty;
    } else {
      // Registro existente - verificar si hay cambios
      final original = widget.existingRecord!;
      return _startTimeController.text !=
              DateFormat('HH:mm').format(original.sleepStartTime) ||
          _endTimeController.text !=
              DateFormat('HH:mm').format(original.sleepEndTime) ||
          _notesController.text != (original.notes ?? '') ||
          _selectedQuality != original.quality;
    }
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cambios sin Guardar',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?',
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.quicksand(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              'Salir',
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Registro',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar este registro de sueño? Esta acción no se puede deshacer.',
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.quicksand(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSleepRecord();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              'Eliminar',
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSleepRecord() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Aquí se implementará la lógica para eliminar de Firestore
      await Future.delayed(const Duration(seconds: 1));

      DialogExample.showSuccessDialog(
        context,
        'Registro Eliminado',
        'El registro de sueño ha sido eliminado exitosamente.',
        () {
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      DialogExample.showErrorDialog(
        context,
        'Error',
        'No se pudo eliminar el registro. Inténtalo nuevamente.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

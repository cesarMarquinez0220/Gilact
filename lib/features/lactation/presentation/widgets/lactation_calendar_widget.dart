import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

import '../../domain/entities/lactation_record.dart';
import '../../data/services/lactation_service.dart';
import '../pages/lactation_record_page.dart';
import '../../../../alerta_dialoge.dart';

enum CalendarView { day, week, month }

class LactationCalendarWidget extends StatefulWidget {
  const LactationCalendarWidget({super.key});

  @override
  State<LactationCalendarWidget> createState() =>
      _LactationCalendarWidgetState();
}

class _LactationCalendarWidgetState extends State<LactationCalendarWidget>
    with TickerProviderStateMixin {
  CalendarView _currentView = CalendarView.month;
  DateTime _selectedDate = DateTime.now();
  List<LactationRecord> _records = [];
  LactationStats? _stats;
  bool _isLoading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late LactationService _lactationService;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initServices();
    _loadData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  void _initServices() {
    _lactationService = LactationService(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Verificar si el usuario tiene situación Post-Parto (ahora usa caché)
      print('🔍 LactationCalendarWidget: Verificando situación postparto...');
      final hasPostpartum = await _lactationService.hasPostpartumSituation();
      print('🔍 LactationCalendarWidget: hasPostpartum = $hasPostpartum');

      if (!hasPostpartum) {
        print(
          '⚠️ LactationCalendarWidget: Usuario no tiene situación postparto, mostrando diálogo',
        );
        setState(() => _isLoading = false);
        _showPostpartumRequiredDialog();
        return;
      }

      print(
        '✅ LactationCalendarWidget: Usuario tiene situación postparto, cargando datos...',
      );

      List<LactationRecord> records;
      switch (_currentView) {
        case CalendarView.day:
          records = await _lactationService.getRecordsForDate(_selectedDate);
          break;
        case CalendarView.week:
          final startOfWeek = _selectedDate.subtract(
            Duration(days: _selectedDate.weekday - 1),
          );
          records = await _lactationService.getRecordsForWeek(startOfWeek);
          break;
        case CalendarView.month:
          records = await _lactationService.getRecordsForMonth(_selectedDate);
          break;
      }

      final stats = await _lactationService.getStats();

      setState(() {
        _records = records;
        _stats = stats;
        _isLoading = false;
      });

      _fadeController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error cargando datos: $e');
      DialogExample.showErrorDialog(
        context,
        'Error de Carga',
        'No se pudieron cargar los datos de lactancia. Por favor, inténtalo nuevamente.',
      );
    }
  }

  void _showPostpartumRequiredDialog() {
    DialogExample.showInfoDialog(
      context,
      'Información Requerida',
      'Debes completar el proceso de onboarding y seleccionar la situación "Post-Parto" para poder registrar datos de lactancia.',
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildViewSelector(),
              Expanded(child: _buildCalendarContent()),
              _buildQuickAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Calendario de Lactancia',
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
                  ),
                  IconButton(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildQuickStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Hoy',
          '${_stats?.feedsToday ?? 0}',
          'sesiones',
          Icons.child_care,
        ),
        _buildStatItem(
          'Duración',
          '${_stats?.durationToday.inMinutes ?? 0}',
          'min',
          Icons.timer,
        ),
        _buildStatItem(
          'Total',
          '${_stats?.totalFeeds ?? 0}',
          'sesiones',
          Icons.trending_up,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          '$label $unit',
          style: GoogleFonts.quicksand(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildViewSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
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
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              _buildViewButton('Día', CalendarView.day, Icons.today),
              _buildViewButton('Semana', CalendarView.week, Icons.view_week),
              _buildViewButton('Mes', CalendarView.month, Icons.calendar_month),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewButton(String label, CalendarView view, IconData icon) {
    final isSelected = _currentView == view;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _currentView = view);
          _loadData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.2),
                    ],
                  )
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(20),
        child: _buildCalendarView(),
      ),
    );
  }

  Widget _buildCalendarView() {
    switch (_currentView) {
      case CalendarView.day:
        return _buildDayView();
      case CalendarView.week:
        return _buildWeekView();
      case CalendarView.month:
        return _buildMonthView();
    }
  }

  Widget _buildDayView() {
    final dayRecords = _records
        .where(
          (record) =>
              record.fechaRegistro.year == _selectedDate.year &&
              record.fechaRegistro.month == _selectedDate.month &&
              record.fechaRegistro.day == _selectedDate.day,
        )
        .toList();

    return Column(
      children: [
        _buildDateHeader(),
        Expanded(
          child: dayRecords.isEmpty
              ? _buildEmptyState(title: 'No hay registros para este día')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dayRecords.length,
                  itemBuilder: (context, index) {
                    final record = dayRecords[index];
                    return _buildRecordCard(record);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({required String title}) {
    return GestureDetector(
      onTap: () => _navigateToRecordPageForDay(_selectedDate),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(
            alpha: 0.2,
          ), // Color sólido en lugar de gradiente
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Toca aquí para agregar un registro',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekView() {
    // Calcular los días de la semana
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    // Obtener registros de la semana
    final weekRecords = _records.where((record) {
      final recordDate = record.fechaRegistro;
      return weekDays.any(
        (day) =>
            recordDate.year == day.year &&
            recordDate.month == day.month &&
            recordDate.day == day.day,
      );
    }).toList();

    return Column(
      children: [
        _buildDateHeader(),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: weekRecords.isEmpty
                  ? _buildEmptyState(title: 'No hay registros para esta semana')
                  : Column(
                      children: [
                        // Días de la semana
                        _buildWeekDaysHeader(weekDays),
                        const SizedBox(height: 8),
                        // Registros de la semana
                        Expanded(child: _buildWeekRecordsList(weekRecords)),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView() {
    return Column(
      children: [
        _buildDateHeader(),
        const SizedBox(height: 10),
        // Días de la semana
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildMonthCalendar(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
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
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_currentView == CalendarView.day) {
                      _selectedDate = _selectedDate.subtract(
                        const Duration(days: 1),
                      );
                    } else if (_currentView == CalendarView.week) {
                      _selectedDate = _selectedDate.subtract(
                        const Duration(days: 7),
                      );
                    } else {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                      );
                    }
                  });
                  _loadData();
                },
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Text(
                _getDateHeaderText(),
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_currentView == CalendarView.day) {
                      _selectedDate = _selectedDate.add(
                        const Duration(days: 1),
                      );
                    } else if (_currentView == CalendarView.week) {
                      _selectedDate = _selectedDate.add(
                        const Duration(days: 7),
                      );
                    } else {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    }
                  });
                  _loadData();
                },
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDateHeaderText() {
    switch (_currentView) {
      case CalendarView.day:
        return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
      case CalendarView.week:
        final startOfWeek = _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}';
      case CalendarView.month:
        final months = [
          'Enero',
          'Febrero',
          'Marzo',
          'Abril',
          'Mayo',
          'Junio',
          'Julio',
          'Agosto',
          'Septiembre',
          'Octubre',
          'Noviembre',
          'Diciembre',
        ];
        return '${months[_selectedDate.month - 1]} ${_selectedDate.year}';
    }
  }

  Widget _buildMonthCalendar() {
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final firstDayOfWeek = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday - 1),
    );

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final day = firstDayOfWeek.add(Duration(days: index));
        final isCurrentMonth = day.month == _selectedDate.month;
        final isToday =
            day.day == DateTime.now().day &&
            day.month == DateTime.now().month &&
            day.year == DateTime.now().year;

        // Verificar si hay registros para este día
        final dayRecords = _records
            .where(
              (record) =>
                  record.fechaRegistro.year == day.year &&
                  record.fechaRegistro.month == day.month &&
                  record.fechaRegistro.day == day.day,
            )
            .toList();

        return _buildMonthDayCard(day, isCurrentMonth, isToday, dayRecords);
      },
    );
  }

  Widget _buildMonthDayCard(
    DateTime day,
    bool isCurrentMonth,
    bool isToday,
    List<LactationRecord> dayRecords,
  ) {
    return GestureDetector(
      onTap: () {
        if (dayRecords.isEmpty) {
          // Si no hay registros, agregar nuevo registro
          _navigateToRecordPageForDay(day);
        } else {
          // Si hay registros, mostrar lista de registros del día
          _showDayRecordsList(day, dayRecords);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isToday
              ? LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.2),
                  ],
                )
              : isCurrentMonth
              ? LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.15),
                  ],
                )
              : null,
          border: Border.all(
            color: isToday
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.3),
            width: isToday ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentMonth
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                if (isCurrentMonth && dayRecords.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                // Indicador de número de registros
                if (isCurrentMonth && dayRecords.length > 1)
                  Container(
                    margin: const EdgeInsets.only(top: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${dayRecords.length}',
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(LactationRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
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
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Icon(
                  _getTypeIcon(record.tipo),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypeName(record.tipo),
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')} • ${record.duracion.inMinutes} min',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showEditRecordDialog(record),
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    tooltip: 'Editar registro',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(record),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    tooltip: 'Eliminar registro',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddButton() {
    // Solo mostrar el botón flotante cuando hay registros en vista de semana
    if (_currentView == CalendarView.month) {
      return const SizedBox.shrink(); // No mostrar en vista de mes
    }

    // En vista de día, mostrar si hay registros para ese día
    if (_currentView == CalendarView.day) {
      final dayRecords = _records
          .where(
            (record) =>
                record.fechaRegistro.year == _selectedDate.year &&
                record.fechaRegistro.month == _selectedDate.month &&
                record.fechaRegistro.day == _selectedDate.day,
          )
          .toList();

      if (dayRecords.isEmpty) {
        return const SizedBox.shrink(); // No mostrar si no hay registros
      }
    }

    // En vista de semana, solo mostrar si hay registros
    if (_currentView == CalendarView.week) {
      final startOfWeek = _selectedDate.subtract(
        Duration(days: _selectedDate.weekday - 1),
      );
      final weekDays = List.generate(
        7,
        (index) => startOfWeek.add(Duration(days: index)),
      );
      final weekRecords = _records.where((record) {
        final recordDate = record.fechaRegistro;
        return weekDays.any(
          (day) =>
              recordDate.year == day.year &&
              recordDate.month == day.month &&
              recordDate.day == day.day,
        );
      }).toList();

      if (weekRecords.isEmpty) {
        return const SizedBox.shrink(); // No mostrar si no hay registros
      }
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToRecordPageForDay(_selectedDate),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        foregroundColor: const Color(0xFF667eea),
        icon: const Icon(Icons.add),
        label: Text(
          'Agregar Registro',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildWeekDaysHeader(List<DateTime> weekDays) {
    return Container(
      height: 60, // Altura fija para evitar overflow
      child: Row(
        children: weekDays.map((day) {
          final isSelected = day.day == _selectedDate.day;
          final dayRecords = _records
              .where(
                (record) =>
                    record.fechaRegistro.year == day.year &&
                    record.fechaRegistro.month == day.month &&
                    record.fechaRegistro.day == day.day,
              )
              .toList();

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = day;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.2),
                          ],
                        )
                      : null,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ['L', 'M', 'X', 'J', 'V', 'S', 'D'][day.weekday - 1],
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.day}',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    if (dayRecords.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 1),
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeekRecordsList(List<LactationRecord> weekRecords) {
    return ListView.builder(
      itemCount: weekRecords.length,
      itemBuilder: (context, index) {
        final record = weekRecords[index];
        return _buildRecordCard(record);
      },
    );
  }

  void _showSuccessFeedback() {
    // Mostrar SnackBar de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '¡Registro guardado exitosamente!',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateToRecordPageForDay(DateTime day) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => LactationRecordPage(selectedDate: day),
          ),
        )
        .then((result) {
          // Recargar datos cuando regrese de la página
          _loadData();

          // Mostrar retroalimentación visual si se creó un registro
          if (result == true) {
            _showSuccessFeedback();
          }
        });
  }

  void _showDayRecordsList(DateTime day, List<LactationRecord> records) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.8),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registros del ${day.day}/${day.month}',
                                style: GoogleFonts.quicksand(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${records.length} registro${records.length > 1 ? 's' : ''}',
                                style: GoogleFonts.quicksand(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
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
                  ),

                  // Lista de registros
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(
                                        0xFF667eea,
                                      ).withValues(alpha: 0.3),
                                      const Color(
                                        0xFF764ba2,
                                      ).withValues(alpha: 0.1),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  _getTypeIcon(record.tipo),
                                  color: const Color(0xFF667eea),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getTypeName(record.tipo),
                                      style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')} • ${record.duracion.inMinutes} min',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _showEditRecordDialog(record);
                                },
                                icon: const Icon(Icons.edit, size: 20),
                                color: const Color(0xFF667eea),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Botón para agregar más registros
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _navigateToRecordPageForDay(day);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: Text(
                          'Agregar Registro',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  void _showDeleteConfirmation(LactationRecord record) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.8),
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
              child: Padding(
                padding: const EdgeInsets.all(24),
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
                            Colors.red.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.warning,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Título
                    Text(
                      'Eliminar Registro',
                      style: GoogleFonts.quicksand(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Mensaje
                    Text(
                      '¿Estás seguro de que quieres eliminar este registro de lactancia? Esta acción no se puede deshacer.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botones
                    Row(
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
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _deleteRecord(record);
                            },
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
          ),
        ),
      ),
    );
  }

  Future<void> _deleteRecord(LactationRecord record) async {
    try {
      print(
        '🔍 LactationCalendarWidget: Iniciando eliminación del registro: ${record.id}',
      );
      setState(() => _isLoading = true);

      await _lactationService.deleteRecord(record.id);
      print('🔍 LactationCalendarWidget: Registro eliminado exitosamente');

      // Recargar datos
      await _loadData();
      print('🔍 LactationCalendarWidget: Datos recargados');

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Registro eliminado exitosamente',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      print('❌ LactationCalendarWidget: Error eliminando registro: $e');
      DialogExample.showErrorDialog(
        context,
        'Error al Eliminar',
        'No se pudo eliminar el registro. Por favor, inténtalo nuevamente.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEditRecordDialog(LactationRecord record) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => LactationRecordPage(
              selectedDate: record.fechaRegistro,
              existingRecord: record,
            ),
          ),
        )
        .then((_) {
          // Recargar datos cuando regrese de la página
          _loadData();
        });
  }

  IconData _getTypeIcon(LactationType type) {
    switch (type) {
      case LactationType.breastfeeding:
        return Icons.child_care;
      case LactationType.pumping:
        return Icons.water_drop;
      case LactationType.bottle:
        return Icons.local_drink;
    }
  }

  String _getTypeName(LactationType type) {
    switch (type) {
      case LactationType.breastfeeding:
        return 'Lactancia Directa';
      case LactationType.pumping:
        return 'Extracción';
      case LactationType.bottle:
        return 'Biberón';
    }
  }
}

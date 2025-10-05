import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../domain/entities/lactation_record.dart';
import '../../data/datasources/lactation_database.dart';

enum CalendarView { day, week, month }

class LactationCalendar extends StatefulWidget {
  const LactationCalendar({super.key});

  @override
  State<LactationCalendar> createState() => _LactationCalendarState();
}

class _LactationCalendarState extends State<LactationCalendar>
    with TickerProviderStateMixin {
  CalendarView _currentView = CalendarView.day;
  DateTime _selectedDate = DateTime.now();
  List<LactationRecord> _records = [];
  LactationStats? _stats;
  bool _isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final database = LactationDatabase();
      List<LactationRecord> records;

      switch (_currentView) {
        case CalendarView.day:
          records = await database.getRecordsForDate(_selectedDate);
          break;
        case CalendarView.week:
          final startOfWeek = _selectedDate.subtract(
            Duration(days: _selectedDate.weekday - 1),
          );
          records = await database.getRecordsForWeek(startOfWeek);
          break;
        case CalendarView.month:
          records = await database.getRecordsForMonth(_selectedDate);
          break;
      }

      final stats = await database.getStats();

      setState(() {
        _records = records;
        _stats = stats;
        _isLoading = false;
      });

      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error cargando datos: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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
                  Text(
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
                  IconButton(
                    onPressed: _showStats,
                    icon: const Icon(Icons.analytics, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_stats != null) _buildQuickStats(),
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
          '${_stats!.feedsToday}',
          'sesiones',
          Icons.child_care,
        ),
        _buildStatItem(
          'Duración',
          '${_stats!.durationToday.inMinutes}',
          'min',
          Icons.timer,
        ),
        _buildStatItem(
          'Total',
          '${_stats!.totalFeeds}',
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
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(20),
          child: _buildCurrentView(),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
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
              record.dateTime.year == _selectedDate.year &&
              record.dateTime.month == _selectedDate.month &&
              record.dateTime.day == _selectedDate.day,
        )
        .toList();

    return Column(
      children: [
        _buildDateHeader(),
        const SizedBox(height: 20),
        Expanded(
          child: dayRecords.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: dayRecords.length,
                  itemBuilder: (context, index) =>
                      _buildRecordCard(dayRecords[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    return Column(
      children: [
        _buildWeekHeader(weekDays),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: weekDays.length,
            itemBuilder: (context, index) {
              final day = weekDays[index];
              final dayRecords = _records
                  .where(
                    (record) =>
                        record.dateTime.year == day.year &&
                        record.dateTime.month == day.month &&
                        record.dateTime.day == day.day,
                  )
                  .toList();

              return _buildWeekDayCard(day, dayRecords);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView() {
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final firstDayOfWeek = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday - 1),
    );

    return Column(
      children: [
        _buildMonthHeader(),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 42, // 6 weeks * 7 days
            itemBuilder: (context, index) {
              final day = firstDayOfWeek.add(Duration(days: index));
              final dayRecords = _records
                  .where(
                    (record) =>
                        record.dateTime.year == day.year &&
                        record.dateTime.month == day.month &&
                        record.dateTime.day == day.day,
                  )
                  .toList();

              return _buildMonthDayCard(day, dayRecords);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFormattedDate(_selectedDate),
                    style: GoogleFonts.quicksand(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _getDayName(_selectedDate),
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(
                        () => _selectedDate = _selectedDate.subtract(
                          const Duration(days: 1),
                        ),
                      );
                      _loadData();
                    },
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(
                        () => _selectedDate = _selectedDate.add(
                          const Duration(days: 1),
                        ),
                      );
                      _loadData();
                    },
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekHeader(List<DateTime> weekDays) {
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
                  setState(
                    () => _selectedDate = _selectedDate.subtract(
                      const Duration(days: 7),
                    ),
                  );
                  _loadData();
                },
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Text(
                'Semana del ${_getFormattedDate(weekDays.first)}',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(
                    () => _selectedDate = _selectedDate.add(
                      const Duration(days: 7),
                    ),
                  );
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

  Widget _buildMonthHeader() {
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
                  setState(
                    () => _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month - 1,
                    ),
                  );
                  _loadData();
                },
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Text(
                _getMonthName(_selectedDate),
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(
                    () => _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month + 1,
                    ),
                  );
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
                  _getTypeIcon(record.type),
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
                      _getTypeName(record.type),
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_formatTime(record.dateTime)} • ${record.duration.inMinutes} min',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    if (record.notes != null && record.notes!.isNotEmpty)
                      Text(
                        record.notes!,
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _editRecord(record),
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDayCard(DateTime day, List<LactationRecord> records) {
    final isToday =
        day.day == DateTime.now().day &&
        day.month == DateTime.now().month &&
        day.year == DateTime.now().year;

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
          color: isToday
              ? Colors.white.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.3),
          width: isToday ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getDayName(day),
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${day.day}',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (records.isEmpty)
                Text(
                  'Sin registros',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                )
              else
                ...records
                    .take(3)
                    .map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: [
                            Icon(
                              _getTypeIcon(record.type),
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatTime(record.dateTime)} • ${record.duration.inMinutes} min',
                              style: GoogleFonts.quicksand(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              if (records.length > 3)
                Text(
                  '+${records.length - 3} más',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthDayCard(DateTime day, List<LactationRecord> records) {
    final isCurrentMonth = day.month == _selectedDate.month;
    final isToday =
        day.day == DateTime.now().day &&
        day.month == DateTime.now().month &&
        day.year == DateTime.now().year;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = day;
          _currentView = CalendarView.day;
        });
        _loadData();
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
                if (records.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care,
            size: 80,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 20),
          Text(
            'No hay registros para este día',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Toca el botón + para agregar un registro',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: FloatingActionButton.extended(
        onPressed: _showAddRecordDialog,
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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDayName(DateTime date) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[date.weekday - 1];
  }

  String _getMonthName(DateTime date) {
    const months = [
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
    return months[date.month - 1];
  }

  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddRecordDialog(
        onRecordAdded: (record) {
          _loadData();
        },
      ),
    );
  }

  void _editRecord(LactationRecord record) {
    showDialog(
      context: context,
      builder: (context) => _AddRecordDialog(
        existingRecord: record,
        onRecordAdded: (updatedRecord) {
          _loadData();
        },
      ),
    );
  }

  void _showStats() {
    if (_stats == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Estadísticas',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Total de sesiones', '${_stats!.totalFeeds}'),
            _buildStatRow(
              'Duración total',
              '${_stats!.totalDuration.inHours}h ${_stats!.totalDuration.inMinutes % 60}m',
            ),
            _buildStatRow(
              'Duración promedio',
              '${_stats!.averageDuration.inMinutes} min',
            ),
            _buildStatRow('Sesiones hoy', '${_stats!.feedsToday}'),
            _buildStatRow(
              'Duración hoy',
              '${_stats!.durationToday.inMinutes} min',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.quicksand()),
          Text(
            value,
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Widget temporal para el diálogo de agregar registro
class _AddRecordDialog extends StatefulWidget {
  final LactationRecord? existingRecord;
  final Function(LactationRecord) onRecordAdded;

  const _AddRecordDialog({this.existingRecord, required this.onRecordAdded});

  @override
  State<_AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends State<_AddRecordDialog> {
  late LactationType _selectedType;
  late DateTime _selectedDateTime;
  late Duration _duration;
  String? _notes;
  String? _side;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      _selectedType = widget.existingRecord!.type;
      _selectedDateTime = widget.existingRecord!.dateTime;
      _duration = widget.existingRecord!.duration;
      _notes = widget.existingRecord!.notes;
      _side = widget.existingRecord!.side;
    } else {
      _selectedType = LactationType.breastfeeding;
      _selectedDateTime = DateTime.now();
      _duration = const Duration(minutes: 15);
      _notes = null;
      _side = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingRecord != null ? 'Editar Registro' : 'Nuevo Registro',
        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Funcionalidad en desarrollo', style: GoogleFonts.quicksand()),
          const SizedBox(height: 20),
          Text(
            'Próximamente podrás agregar registros de lactancia de forma rápida y fácil.',
            style: GoogleFonts.quicksand(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cerrar',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

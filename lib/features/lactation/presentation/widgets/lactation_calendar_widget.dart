import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

import '../../domain/entities/lactation_record.dart';
import '../../data/services/lactation_service.dart';
import '../pages/lactation_record_page.dart';
import '../../../../alerta_dialoge.dart';
import '../../domain/entities/baby_weight_record.dart';
import '../../data/datasources/baby_weight_offline_local_data_source.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

enum CalendarView { day, week, month }

enum RecordFilter { all, lactation, weight }

class LactationCalendarWidget extends StatefulWidget {
  final List<LactationRecord>? preloadedRecords;

  const LactationCalendarWidget({super.key, this.preloadedRecords});

  @override
  State<LactationCalendarWidget> createState() =>
      _LactationCalendarWidgetState();
}

class _LactationCalendarWidgetState extends State<LactationCalendarWidget>
    with TickerProviderStateMixin {
  CalendarView _currentView = CalendarView.day;
  DateTime _selectedDate = DateTime.now();
  List<LactationRecord> _records = [];
  List<LactationRecord> _monthRecords = []; // Datos del mes precargados
  List<BabyWeightRecord> _weightRecords =
      []; // Registros de peso para el día/vista actual
  List<BabyWeightRecord> _monthWeightRecords =
      []; // Datos de peso del mes precargados
  RecordFilter _currentFilter = RecordFilter.all; // Filtro actual
  LactationStats? _stats;
  bool _isLoading = true;
  bool _isFullScreenCalendar =
      false; // Nueva variable para controlar pantalla completa
  bool _monthDataLoaded =
      false; // Flag para saber si los datos del mes están cargados

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late LactationService _lactationService;
  final BabyWeightOfflineLocalDataSource _weightDataSource =
      BabyWeightOfflineLocalDataSource();
  final AppLogger _logger = getIt<AppLogger>();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initServices();

    // Si hay datos precargados, usarlos directamente
    if (widget.preloadedRecords != null) {
      _usePreloadedData();
    } else {
      _loadData();
    }
  }

  void _usePreloadedData() async {
    _logger.d(
      '_usePreloadedData(): ${widget.preloadedRecords!.length} registros precargados',
    );

    // Cargar registros de peso
    final weightRecords = await _loadWeightRecordsForMonth(_selectedDate);

    setState(() {
      // Si hay datos precargados, pueden ser del mes completo
      // Filtrar por el día seleccionado para vista de día
      if (_currentView == CalendarView.day) {
        _records = widget.preloadedRecords!
            .where(
              (record) =>
                  record.fechaRegistro.year == _selectedDate.year &&
                  record.fechaRegistro.month == _selectedDate.month &&
                  record.fechaRegistro.day == _selectedDate.day,
            )
            .toList();
        _logger.d('Filtrados para el día: ${_records.length} registros');
      } else {
        _records = widget.preloadedRecords!;
        _logger.d('Usando todos los registros precargados: ${_records.length}');
      }

      _monthRecords = widget.preloadedRecords!;
      _weightRecords = weightRecords;
      _monthDataLoaded = true;
      _isLoading = false;
    });

    // Calcular estadísticas del día actual
    _calculateDayStats();

    _fadeController.forward();
  }

  Future<void> _calculateDayStats() async {
    try {
      final dayRecords = _records
          .where(
            (record) =>
                record.fechaRegistro.year == _selectedDate.year &&
                record.fechaRegistro.month == _selectedDate.month &&
                record.fechaRegistro.day == _selectedDate.day,
          )
          .toList();

      final stats = await _getDayStats(_selectedDate, dayRecords);

      setState(() {
        _stats = stats;
      });
    } catch (e, stackTrace) {
      _logger.e('Error calculando estadísticas', e, stackTrace);
    }
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

  /// Carga registros de peso para el mes seleccionado
  Future<List<BabyWeightRecord>> _loadWeightRecordsForMonth(
    DateTime date,
  ) async {
    try {
      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
      final startTimestamp = firstDayOfMonth.millisecondsSinceEpoch;
      final endTimestamp = lastDayOfMonth
          .add(const Duration(days: 1))
          .millisecondsSinceEpoch;

      final List<BabyWeightRecord> records = [];

      // Obtener userId
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logger.w('No hay usuario autenticado para cargar registros de peso');
        return [];
      }

      String? userDocId;
      if (user.email != null) {
        final userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        if (userQuery.docs.isNotEmpty) {
          userDocId = userQuery.docs.first.id;
        }
      }
      userDocId ??= user.uid;

      // Consultar desde Firestore
      final connectivityService = ConnectivityService();
      final isConnected = await connectivityService.isConnected();

      if (isConnected) {
        try {
          final weightCollection = FirebaseFirestore.instance
              .collection('Users')
              .doc(userDocId)
              .collection('situacion')
              .doc('seleccion')
              .collection('peso');

          final querySnapshot = await weightCollection
              .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
              .where('timestamp', isLessThanOrEqualTo: endTimestamp)
              .orderBy('timestamp', descending: false)
              .get();

          _logger.d(
            'Registros de peso desde Firestore: ${querySnapshot.docs.length}',
          );

          for (final doc in querySnapshot.docs) {
            final data = doc.data();
            final recordedAt = data['fecha_peso'] != null
                ? DateTime.parse(data['fecha_peso'] as String)
                : DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);

            records.add(
              BabyWeightRecord(
                id: doc.id,
                userId: userDocId,
                weight: (data['peso'] as num).toDouble(),
                recordedAt: recordedAt,
                notes: data['notas'] as String?,
                createdAt: recordedAt,
                updatedAt: recordedAt,
              ),
            );
          }
        } catch (e, stackTrace) {
          _logger.e('Error consultando Firestore para peso', e, stackTrace);
        }
      }

      // También obtener desde datos locales (para registros no sincronizados)
      try {
        final localRecords = await _weightDataSource.getAllRecords();
        final localRecordsInRange = localRecords.where((record) {
          final recordDate = DateTime(
            record.recordedAt.year,
            record.recordedAt.month,
            record.recordedAt.day,
          );
          final firstDay = DateTime(
            firstDayOfMonth.year,
            firstDayOfMonth.month,
            firstDayOfMonth.day,
          );
          final lastDay = DateTime(
            lastDayOfMonth.year,
            lastDayOfMonth.month,
            lastDayOfMonth.day,
          );
          return recordDate.isAfter(
                firstDay.subtract(const Duration(days: 1)),
              ) &&
              recordDate.isBefore(lastDay.add(const Duration(days: 1)));
        }).toList();

        // Agregar solo los que no están ya en records (por ID)
        final existingIds = records.map((r) => r.id).toSet();
        for (final localRecord in localRecordsInRange) {
          if (!existingIds.contains(localRecord.id)) {
            records.add(localRecord);
          }
        }

        _logger.d(
          'Registros de peso locales adicionales: ${localRecordsInRange.length}',
        );
      } catch (e, stackTrace) {
        _logger.e('Error obteniendo datos locales de peso', e, stackTrace);
      }

      // Ordenar por fecha
      records.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

      _logger.success('Total registros de peso cargados: ${records.length}');
      return records;
    } catch (e, stackTrace) {
      _logger.e('Error cargando registros de peso', e, stackTrace);
      return [];
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Verificar si el usuario tiene situación Post-Parto (ahora usa caché)
      _logger.d('LactationCalendarWidget: Verificando situación postparto...');
      final hasPostpartum = await _lactationService.hasPostpartumSituation();
      _logger.d('LactationCalendarWidget: hasPostpartum = $hasPostpartum');

      if (!hasPostpartum) {
        _logger.w(
          'LactationCalendarWidget: Usuario no tiene situación postparto, mostrando diálogo',
        );
        setState(() => _isLoading = false);
        _showPostpartumRequiredDialog();
        return;
      }

      _logger.d(
        'LactationCalendarWidget: Usuario tiene situación postparto, cargando datos...',
      );

      List<LactationRecord> records;
      LactationStats? stats;

      switch (_currentView) {
        case CalendarView.day:
          _logger.d('Vista DÍA - Fecha seleccionada: $_selectedDate');
          records = await _lactationService.getRecordsForDate(_selectedDate);
          _logger.d('Registros cargados de Firestore: ${records.length}');
          for (var record in records) {
            _logger.d(
              '   - ID: ${record.id}, Fecha: ${record.fechaRegistro}, Tipo: ${record.tipo}',
            );
          }
          // Cargar estadísticas específicas del día seleccionado
          stats = await _getDayStats(_selectedDate, records);
          break;
        case CalendarView.week:
          final startOfWeek = _selectedDate.subtract(
            Duration(days: _selectedDate.weekday - 1),
          );
          records = await _lactationService.getRecordsForWeek(startOfWeek);
          stats = await _lactationService.getStats();
          break;
        case CalendarView.month:
          records = await _lactationService.getRecordsForMonth(_selectedDate);
          stats = await _lactationService.getStats();
          break;
      }

      // Cargar registros de peso para el mes actual
      final weightRecords = await _loadWeightRecordsForMonth(_selectedDate);

      _logger.d('Asignando ${records.length} registros a _records');
      _logger.d('Asignando ${weightRecords.length} registros de peso');
      _logger.d('Vista actual: $_currentView');
      setState(() {
        _records = records;
        _weightRecords = weightRecords;
        _stats = stats;
        _isLoading = false;

        // Si estamos en vista de mes, también actualizar los datos del mes precargados
        if (_currentView == CalendarView.month) {
          _monthRecords = records;
          _monthWeightRecords = weightRecords;
          _monthDataLoaded = true;
          _logger.d(
            'Datos del mes actualizados: ${_monthRecords.length} lactancia, ${_monthWeightRecords.length} peso',
          );
        }
      });
      _logger.d('_records actualizado con ${_records.length} elementos');

      // Precargar datos del mes en background cuando estamos en vista de día
      if (_currentView == CalendarView.day && !_monthDataLoaded) {
        _preloadMonthData();
      }

      _fadeController.forward();
    } catch (e, stackTrace) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _logger.e('Error cargando datos', e, stackTrace);
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

  void _toggleMonthView() {
    setState(() {
      if (_currentView == CalendarView.day) {
        _currentView = CalendarView.month;
        _isFullScreenCalendar =
            true; // Activar pantalla completa para calendario
        // Usar datos precargados si están disponibles
        if (_monthDataLoaded) {
          _records = _monthRecords;
          _weightRecords =
              _monthWeightRecords; // También actualizar registros de peso
        } else {
          // Si no hay datos precargados, usar los datos actuales como datos del mes
          // Pero primero necesitamos cargar los datos del mes completo
          _monthRecords = _records;
          _monthWeightRecords = _weightRecords;
          // No marcar como cargado todavía, necesitamos cargar el mes completo
        }
      } else {
        _currentView = CalendarView.day;
        _isFullScreenCalendar = false; // Desactivar pantalla completa
      }
    });

    // Cargar datos del mes si no están precargados o si necesitamos actualizarlos
    if (_currentView == CalendarView.month && !_monthDataLoaded) {
      _loadData();
    } else if (_currentView == CalendarView.month &&
        _monthWeightRecords.isEmpty) {
      // Si estamos en vista de mes pero no hay datos de peso, cargar
      _loadData();
    }
  }

  Future<void> _preloadMonthData() async {
    try {
      _logger.d('Precargando datos del mes en background...');
      final monthRecords = await _lactationService.getRecordsForMonth(
        _selectedDate,
      );
      final monthWeightRecords = await _loadWeightRecordsForMonth(
        _selectedDate,
      );

      setState(() {
        _monthRecords = monthRecords;
        _monthWeightRecords =
            monthWeightRecords; // Solo actualizar _monthWeightRecords, no _weightRecords
        _monthDataLoaded = true;
      });
      _logger.success(
        'Datos del mes precargados exitosamente (${monthRecords.length} lactancia, ${monthWeightRecords.length} peso)',
      );
    } catch (e, stackTrace) {
      _logger.e('Error precargando datos del mes', e, stackTrace);
    }
  }

  void _switchToDayView(DateTime day) {
    // Solo recargar datos si cambiamos a un día diferente
    final needsReload =
        _selectedDate.day != day.day ||
        _selectedDate.month != day.month ||
        _selectedDate.year != day.year;

    setState(() {
      _selectedDate = day;
      _currentView = CalendarView.day;
      _isFullScreenCalendar = false;
    });

    // Solo recargar datos si es necesario (cuando cambiamos a un día diferente)
    if (needsReload) {
      _loadData();
    }
  }

  Future<LactationStats> _getDayStats(
    DateTime day,
    List<LactationRecord> dayRecords,
  ) async {
    // Calcular estadísticas específicas del día
    int feedsToday = dayRecords.length;

    Duration durationToday = Duration.zero;
    for (final record in dayRecords) {
      durationToday += record.duracion;
    }

    // Obtener estadísticas generales para el total
    final generalStats = await _lactationService.getStats();

    return LactationStats(
      totalFeeds: generalStats.totalFeeds,
      totalDuration: generalStats.totalDuration,
      averageDuration: generalStats.averageDuration,
      feedsToday: feedsToday,
      durationToday: durationToday,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _isFullScreenCalendar
              ? _buildFullScreenCalendar()
              : Column(
                  children: [
                    _buildHeader(),
                    // Selector de vistas eliminado - ahora solo vista de día por defecto
                    Expanded(child: _buildCalendarContent()),
                    _buildQuickAddButton(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFullScreenCalendar() {
    return Column(
      children: [
        // Header simplificado para pantalla completa
        Container(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'lactation.calendar.title'.tr(),
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
                ],
              ),
            ),
          ),
        ),
        // Calendario que ocupa toda la pantalla
        Expanded(child: _buildCalendarContent()),
      ],
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
                      'lactation.calendar.recordsTitle'.tr(),
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
          _currentView == CalendarView.day
              ? 'lactation.calendar.thisDay'.tr()
              : 'lactation.calendar.today'.tr(),
          '${_stats?.feedsToday ?? 0}',
          'lactation.calendar.sessions'.tr(),
          Icons.child_care,
        ),
        _buildStatItem(
          'lactation.calendar.duration'.tr(),
          '${_stats?.durationToday.inMinutes ?? 0}',
          'lactation.calendar.min'.tr(),
          Icons.timer,
        ),
        _buildStatItem(
          'lactation.calendar.total'.tr(),
          '${_stats?.totalFeeds ?? 0}',
          'lactation.calendar.sessions'.tr(),
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

  // Widget _buildViewSelector() { // Método comentado - selector de vistas eliminado
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 20),
  //     padding: const EdgeInsets.all(4),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(25),
  //       gradient: LinearGradient(
  //         colors: [
  //           Colors.white.withValues(alpha: 0.25),
  //           Colors.white.withValues(alpha: 0.15),
  //         ],
  //       ),
  //       border: Border.all(
  //         color: Colors.white.withValues(alpha: 0.3),
  //         width: 1,
  //       ),
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(25),
  //       child: BackdropFilter(
  //         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //         child: Row(
  //           children: [
  //             _buildViewButton('Día', CalendarView.day, Icons.today),
  //             _buildViewButton('Semana', CalendarView.week, Icons.view_week),
  //             _buildViewButton('Mes', CalendarView.month, Icons.calendar_month),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildViewButton(String label, CalendarView view, IconData icon) { // Método comentado - selector de vistas eliminado
  //   final isSelected = _currentView == view;
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: () {
  //         setState(() => _currentView = view);
  //         _loadData();
  //       },
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(vertical: 12),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(20),
  //           gradient: isSelected
  //               ? LinearGradient(
  //                   colors: [
  //                     Colors.white.withValues(alpha: 0.3),
  //                     Colors.white.withValues(alpha: 0.2),
  //                   ],
  //                 )
  //               : null,
  //         ),
  //         child: Column(
  //           children: [
  //             Icon(
  //               icon,
  //               color: isSelected
  //                   ? Colors.white
  //                   : Colors.white.withValues(alpha: 0.7),
  //               size: 20,
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               label,
  //               style: GoogleFonts.quicksand(
  //                 fontSize: 12,
  //                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //                 color: isSelected
  //                     ? Colors.white
  //                     : Colors.white.withValues(alpha: 0.7),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
    // Filtrar registros de lactancia para el día seleccionado (por si acaso hay registros de otros días)
    final dayRecords = _records.where((record) {
      final recordDate = DateTime(
        record.fechaRegistro.year,
        record.fechaRegistro.month,
        record.fechaRegistro.day,
      );
      return recordDate.year == _selectedDate.year &&
          recordDate.month == _selectedDate.month &&
          recordDate.day == _selectedDate.day;
    }).toList();

    // Obtener registros de peso para el día seleccionado
    final dayWeightRecords = _weightRecords.where((record) {
      final recordDate = DateTime(
        record.recordedAt.year,
        record.recordedAt.month,
        record.recordedAt.day,
      );
      return recordDate.year == _selectedDate.year &&
          recordDate.month == _selectedDate.month &&
          recordDate.day == _selectedDate.day;
    }).toList();

    _logger.d(
      '_buildDayView(): Total registros: ${_records.length}, dayRecords: ${dayRecords.length}, dayWeightRecords: ${dayWeightRecords.length}, Fecha: $_selectedDate',
    );

    if (dayRecords.isNotEmpty) {
      _logger.d(
        'Primer registro: ID=${dayRecords.first.id}, Fecha=${dayRecords.first.fechaRegistro}',
      );
      _logger.d(
        'Último registro: ID=${dayRecords.last.id}, Fecha=${dayRecords.last.fechaRegistro}',
      );
    }

    final hasAnyRecords = dayRecords.isNotEmpty || dayWeightRecords.isNotEmpty;

    return Column(
      children: [
        _buildDateHeader(),
        Expanded(
          child: !hasAnyRecords
              ? _buildEmptyState(title: 'lactation.calendar.noRecords'.tr())
              : ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    overscroll: false, // Esto desactiva el resplandor
                  ),
                  child: ListView.builder(
                    // Tu ListView original va aquí DENTRO
                    padding: const EdgeInsets.all(16),
                    itemCount: dayRecords.length + dayWeightRecords.length,
                    itemBuilder: (context, index) {
                      // Mostrar primero registros de lactancia, luego peso
                      if (index < dayRecords.length) {
                        final record = dayRecords[index];
                        _logger.d(
                          'Construyendo card lactancia #${index + 1}/${dayRecords.length} - ID: ${record.id}, Fecha: ${record.fechaRegistro}',
                        );
                        return _buildLactationRecordCard(record);
                      } else {
                        final weightRecord =
                            dayWeightRecords[index - dayRecords.length];
                        _logger.d(
                          'Construyendo card peso #${index - dayRecords.length + 1}/${dayWeightRecords.length} - ID: ${weightRecord.id}, Fecha: ${weightRecord.recordedAt}',
                        );
                        return _buildWeightRecordCard(weightRecord);
                      }
                    },
                  ),
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
              'lactation.calendar.tapToAdd'.tr(),
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
                  ? _buildEmptyState(
                      title: 'lactation.calendar.noRecordsWeek'.tr(),
                    )
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
        // Filtros
        _buildFilterButtons(),
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
              // Icono para cambiar a vista de mes
              IconButton(
                onPressed: _toggleMonthView,
                icon: Icon(
                  _currentView == CalendarView.month
                      ? Icons.list
                      : Icons.calendar_month,
                  color: Colors.white,
                ),
                tooltip: _currentView == CalendarView.month
                    ? 'lactation.calendar.viewList'.tr()
                    : 'lactation.calendar.viewMonth'.tr(),
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
          'lactation.calendar.months.january'.tr(),
          'lactation.calendar.months.february'.tr(),
          'lactation.calendar.months.march'.tr(),
          'lactation.calendar.months.april'.tr(),
          'lactation.calendar.months.may'.tr(),
          'lactation.calendar.months.june'.tr(),
          'lactation.calendar.months.july'.tr(),
          'lactation.calendar.months.august'.tr(),
          'lactation.calendar.months.september'.tr(),
          'lactation.calendar.months.october'.tr(),
          'lactation.calendar.months.november'.tr(),
          'lactation.calendar.months.december'.tr(),
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

        // Verificar si hay registros de lactancia para este día
        // En vista de mes, siempre usar _monthRecords si están disponibles
        final monthRecordsToUse =
            (_currentView == CalendarView.month && _monthRecords.isNotEmpty)
            ? _monthRecords
            : (_monthDataLoaded && _monthRecords.isNotEmpty)
            ? _monthRecords
            : _records;
        final dayRecords = monthRecordsToUse
            .where(
              (record) =>
                  record.fechaRegistro.year == day.year &&
                  record.fechaRegistro.month == day.month &&
                  record.fechaRegistro.day == day.day,
            )
            .toList();

        // Verificar si hay registros de peso para este día
        // En vista de mes, siempre usar _monthWeightRecords si están disponibles
        // Si estamos en vista de mes, priorizar _monthWeightRecords, sino usar _weightRecords
        // IMPORTANTE: En vista de mes, _weightRecords también contiene los datos del mes cuando se cargan
        final monthWeightRecordsToUse = (_currentView == CalendarView.month)
            ? (_monthWeightRecords.isNotEmpty
                  ? _monthWeightRecords
                  : _weightRecords) // En vista de mes, usar _weightRecords como fallback (contiene datos del mes)
            : (_monthDataLoaded && _monthWeightRecords.isNotEmpty)
            ? _monthWeightRecords
            : _weightRecords;

        final dayWeightRecords = monthWeightRecordsToUse.where((record) {
          final recordDate = DateTime(
            record.recordedAt.year,
            record.recordedAt.month,
            record.recordedAt.day,
          );
          return recordDate.year == day.year &&
              recordDate.month == day.month &&
              recordDate.day == day.day;
        }).toList();

        // Debug para el día 15 (que sabemos que tiene peso)
        if (day.day == 15 && day.month == 11) {
          _logger.d(
            'Día 15 - Vista: $_currentView, _monthWeightRecords: ${_monthWeightRecords.length}, _weightRecords: ${_weightRecords.length}, monthWeightRecordsToUse: ${monthWeightRecordsToUse.length}, dayWeightRecords: ${dayWeightRecords.length}, _monthDataLoaded: $_monthDataLoaded',
          );
          if (monthWeightRecordsToUse.isNotEmpty) {
            _logger.d(
              'Primer registro de peso: ${monthWeightRecordsToUse.first.recordedAt}',
            );
          }
        }

        return _buildMonthDayCard(
          day,
          isCurrentMonth,
          isToday,
          dayRecords,
          dayWeightRecords,
        );
      },
    );
  }

  Widget _buildMonthDayCard(
    DateTime day,
    bool isCurrentMonth,
    bool isToday,
    List<LactationRecord> dayRecords,
    List<BabyWeightRecord> dayWeightRecords,
  ) {
    // Aplicar filtro
    final showLactation =
        _currentFilter == RecordFilter.all ||
        _currentFilter == RecordFilter.lactation;
    final showWeight =
        _currentFilter == RecordFilter.all ||
        _currentFilter == RecordFilter.weight;

    final hasLactation = dayRecords.isNotEmpty && showLactation;
    final hasWeight = dayWeightRecords.isNotEmpty && showWeight;
    final hasAnyRecord = hasLactation || hasWeight;

    return GestureDetector(
      onTap: () {
        if (_isFullScreenCalendar) {
          // Si estamos en modo pantalla completa, cambiar a vista de día
          _switchToDayView(day);
        } else {
          // Lógica original para cuando no está en pantalla completa
          if (hasLactation || hasWeight) {
            // Hay registros (lactancia, peso o ambos), mostrar lista
            _showDayRecordsList(day, dayRecords, dayWeightRecords);
          } else {
            // No hay registros, agregar nuevo registro
            _navigateToRecordPageForDay(day);
          }
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
            child: SizedBox(
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '${day.day}',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrentMonth
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Indicadores de registros
                  if (isCurrentMonth && hasAnyRecord)
                    _buildDayIndicators(
                      hasLactation,
                      hasWeight,
                      dayRecords.length,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye los indicadores visuales para un día del calendario
  Widget _buildDayIndicators(
    bool hasLactation,
    bool hasWeight,
    int lactationCount,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicador de lactancia (círculo blanco)
          if (hasLactation)
            Container(
              margin: EdgeInsets.only(right: hasWeight ? 2 : 0),
              width: lactationCount == 1 ? 6 : null,
              height: 6,
              padding: lactationCount > 1
                  ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1)
                  : null,
              decoration: BoxDecoration(
                shape: lactationCount == 1
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                borderRadius: lactationCount > 1
                    ? BorderRadius.circular(8)
                    : null,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              child: lactationCount > 1
                  ? Text(
                      '$lactationCount',
                      style: GoogleFonts.quicksand(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : null,
            ),
          // Indicador de peso (triángulo verde)
          if (hasWeight)
            SizedBox(
              width: 6,
              height: 6,
              child: CustomPaint(painter: _TrianglePainter()),
            ),
        ],
      ),
    );
  }

  /// Construye una tarjeta para registro de lactancia en el diálogo
  Widget _buildLactationRecordCard(LactationRecord record) {
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
                    tooltip: 'lactation.calendar.editRecord'.tr(),
                  ),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(record),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    tooltip: 'lactation.calendar.deleteRecord'.tr(),
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
          'lactation.calendar.addRecord'.tr(),
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildWeekDaysHeader(List<DateTime> weekDays) {
    return SizedBox(
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
        return _buildLactationRecordCard(record);
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
              'lactation.calendar.savedSuccess'.tr(),
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

  void _showDayRecordsList(
    DateTime day,
    List<LactationRecord> records, [
    List<BabyWeightRecord>? weightRecords,
  ]) {
    final weightList = weightRecords ?? [];
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
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
                                '${'lactation.calendar.recordsOf'.tr()} ${day.day}/${day.month}',
                                style: GoogleFonts.quicksand(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _getRecordsCountText(
                                  records.length,
                                  weightList.length,
                                ),
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
                      itemCount: records.length + weightList.length,
                      itemBuilder: (context, index) {
                        // Mostrar primero registros de lactancia, luego peso
                        if (index < records.length) {
                          final record = records[index];
                          return _buildLactationRecordCard(record);
                        }
                        final weightRecord = weightList[index - records.length];
                        return _buildWeightRecordCard(weightRecord);
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
                          'lactation.calendar.addRecord'.tr(),
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
                      'lactation.calendar.deleteConfirmTitle'.tr(),
                      style: GoogleFonts.quicksand(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Mensaje
                    Text(
                      'lactation.calendar.deleteConfirmMessage'.tr(),
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
                            onPressed: () {
                              Navigator.of(context).pop();
                              _deleteRecord(record);
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
                              'lactation.calendar.deleteButton'.tr(),
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
      setState(() => _isLoading = true);

      await _lactationService.deleteRecord(record.id);

      // Recargar datos
      await _loadData();

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'lactation.calendar.deletedSuccess'.tr(),
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
      if (!mounted) return;

      DialogExample.showErrorDialog(
        context,
        'lactation.calendar.deleteError'.tr(),
        'lactation.calendar.deleteErrorMessage'.tr(),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        return 'lactation.recordForm.breastfeeding'.tr();
      case LactationType.pumping:
        return 'Extracción';
      case LactationType.bottle:
        return 'Biberón';
    }
  }

  /// Obtiene el texto de conteo de registros
  String _getRecordsCountText(int lactationCount, int weightCount) {
    final parts = <String>[];
    if (lactationCount > 0) {
      parts.add('$lactationCount lactancia${lactationCount > 1 ? 's' : ''}');
    }
    if (weightCount > 0) {
      parts.add('$weightCount peso${weightCount > 1 ? 's' : ''}');
    }
    if (parts.isEmpty) {
      return 'lactation.calendar.noRecordsText'.tr();
    }
    return parts.join(', ');
  }

  /// Construye una tarjeta para registro de peso en el diálogo
  Widget _buildWeightRecordCard(BabyWeightRecord record) {
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
                      const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.monitor_weight,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'lactation.calendar.weight'.tr(),
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4CAF50,
                            ).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${record.weight.toStringAsFixed(2)} kg',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${record.recordedAt.hour.toString().padLeft(2, '0')}:${record.recordedAt.minute.toString().padLeft(2, '0')}',
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

  /// Construye los botones de filtro
  Widget _buildFilterButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 360;
        final spacing = isSmallScreen ? 4.0 : 8.0;
        final horizontalPadding = isSmallScreen ? 12.0 : 20.0;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _buildFilterButton(
                  'lactation.calendar.filters.all'.tr(),
                  RecordFilter.all,
                  Icons.view_module,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              SizedBox(width: spacing),
              Flexible(
                child: _buildFilterButton(
                  'lactation.calendar.filters.lactation'.tr(),
                  RecordFilter.lactation,
                  Icons.child_care,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              SizedBox(width: spacing),
              Flexible(
                child: _buildFilterButton(
                  'lactation.calendar.filters.weight'.tr(),
                  RecordFilter.weight,
                  Icons.monitor_weight,
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(
    String label,
    RecordFilter filter,
    IconData icon, {
    bool isSmallScreen = false,
  }) {
    final isSelected = _currentFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 16,
          vertical: isSmallScreen ? 6 : 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isSmallScreen ? 14 : 16, color: Colors.white),
            SizedBox(width: isSmallScreen ? 4 : 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter para dibujar un triángulo
class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

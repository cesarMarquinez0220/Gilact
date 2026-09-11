import 'package:flutter/material.dart';
import '../widgets/lactation_calendar_widget.dart';
import '../../domain/entities/lactation_record.dart';

/// Página de ejemplo que muestra cómo usar el nuevo sistema de calendario de lactancia
class LactationCalendarPage extends StatelessWidget {
  final List<LactationRecord>? preloadedRecords;

  const LactationCalendarPage({super.key, this.preloadedRecords});

  @override
  Widget build(BuildContext context) {
    return LactationCalendarWidget(preloadedRecords: preloadedRecords);
  }
}

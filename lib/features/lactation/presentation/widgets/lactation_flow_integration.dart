import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection.dart';
import '../providers/lactation_flow_provider.dart';
import '../pages/lactation_flow_page.dart';
import '../../domain/entities/lactation_record.dart';

/// Widget para mostrar un botón que abre el nuevo flujo de lactancia
class LactationFlowButton extends StatelessWidget {
  final DateTime? selectedDate;
  final LactationRecord? existingRecord;
  final VoidCallback? onRecordSaved;

  const LactationFlowButton({
    super.key,
    this.selectedDate,
    this.existingRecord,
    this.onRecordSaved,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => getIt<LactationFlowProvider>(),
      child: Consumer<LactationFlowProvider>(
        builder: (context, provider, child) {
          return Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _openLactationFlow(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    existingRecord != null
                        ? 'Editar con Nuevo Flujo'
                        : 'Registro Rápido',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openLactationFlow(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => LactationFlowPage(
          selectedDate: selectedDate,
          existingRecord: existingRecord,
        ),
      ),
    );

    if (result == true && onRecordSaved != null) {
      onRecordSaved!();
    }
  }
}

/// Widget para mostrar estadísticas del nuevo flujo
class LactationFlowStats extends StatelessWidget {
  const LactationFlowStats({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => getIt<LactationFlowProvider>(),
      child: Consumer<LactationFlowProvider>(
        builder: (context, provider, child) {
          if (provider.userStatistics.isEmpty) {
            return const SizedBox.shrink();
          }

          final stats = provider.userStatistics;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.8),
                ],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.analytics_outlined,
                      color: Color(0xFF667eea),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Estadísticas Inteligentes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Estadísticas
                _buildStatItem(
                  '📊',
                  'Total de Registros',
                  '${stats['totalRecords'] ?? 0}',
                ),
                _buildStatItem(
                  '🤱',
                  'Lactancia Materna',
                  '${stats['totalBreastfeeding'] ?? 0} veces',
                ),
                _buildStatItem(
                  '🍶',
                  'Biberón',
                  '${stats['totalBottle'] ?? 0} veces',
                ),
                if (stats['avgDuration'] > 0)
                  _buildStatItem(
                    '⏱️',
                    'Duración Promedio',
                    '${stats['avgDuration'].round()} min',
                  ),
                if (stats['avgSleepTime'] > 0)
                  _buildStatItem(
                    '😴',
                    'Sueño Promedio',
                    '${stats['avgSleepTime'].round()} min',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar sugerencias basadas en el historial
class LactationFlowSuggestions extends StatelessWidget {
  const LactationFlowSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => getIt<LactationFlowProvider>(),
      child: Consumer<LactationFlowProvider>(
        builder: (context, provider, child) {
          if (provider.userStatistics.isEmpty) {
            return const SizedBox.shrink();
          }

          final stats = provider.userStatistics;
          final preferredType = stats['preferredFeedingType'] ?? 'breast';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.1),
                  Colors.blue.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.2),
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
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sugerencias Inteligentes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  preferredType == 'breast'
                      ? '💡 Basado en tu historial, parece que prefieres la lactancia materna. ¿Quieres registrar una sesión de lactancia?'
                      : '💡 Basado en tu historial, parece que usas más el biberón. ¿Quieres registrar una toma con biberón?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openLactationFlow(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Registrar Ahora',
                          style: TextStyle(
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
          );
        },
      ),
    );
  }

  Future<void> _openLactationFlow(BuildContext context) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const LactationFlowPage()),
    );
  }
}

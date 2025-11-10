import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/sync_queue_service.dart';
import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/di/injection.dart';

/// Widget que muestra el estado de sincronización y operaciones pendientes
class SyncIndicator extends StatefulWidget {
  const SyncIndicator({super.key});

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator> {
  int _pendingOperations = 0;
  bool _isSyncing = false;
  bool _isConnected = false;
  Timer? _updateTimer;
  final SyncQueueService _syncQueueService = SyncQueueService();
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _startPeriodicUpdate();
    _listenToConnectivity();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _startPeriodicUpdate() {
    // Actualizar cada 2 segundos
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkStatus();
    });
  }

  void _listenToConnectivity() {
    _connectivitySubscription = _connectivityService.connectivityStream.listen((
      isConnected,
    ) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });
  }

  Future<void> _checkStatus() async {
    if (!mounted) return;

    try {
      final pendingCount = await _syncQueueService.getPendingOperationsCount();
      final isConnected = await _connectivityService.isConnected();

      if (mounted) {
        setState(() {
          _pendingOperations = pendingCount;
          _isConnected = isConnected;
          // Si hay operaciones pendientes y hay conexión, asumir que está sincronizando
          _isSyncing = pendingCount > 0 && isConnected;
        });
      }
    } catch (e) {
      // Ignorar errores silenciosamente
    }
  }

  @override
  Widget build(BuildContext context) {
    // No mostrar si no hay operaciones pendientes y está conectado
    if (_pendingOperations == 0 && _isConnected) {
      return const SizedBox.shrink();
    }

    // Si no hay conexión y no hay operaciones pendientes, no mostrar
    if (!_isConnected && _pendingOperations == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {
          // Mostrar detalles de sincronización
          _showSyncDetails(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isSyncing
                ? Colors.orange
                : _pendingOperations > 0
                ? Colors.blue
                : Colors.green,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSyncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else if (_pendingOperations > 0)
                const Icon(Icons.cloud_upload, color: Colors.white, size: 18)
              else
                const Icon(Icons.cloud_done, color: Colors.white, size: 18),
              if (_pendingOperations > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '$_pendingOperations',
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSyncDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SyncDetailsDialog(
        pendingOperations: _pendingOperations,
        isSyncing: _isSyncing,
        isConnected: _isConnected,
      ),
    );
  }
}

/// Diálogo con detalles de sincronización
class _SyncDetailsDialog extends StatelessWidget {
  final int pendingOperations;
  final bool isSyncing;
  final bool isConnected;

  const _SyncDetailsDialog({
    required this.pendingOperations,
    required this.isSyncing,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Estado de Sincronización',
        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusRow(
            'Conexión',
            isConnected ? 'Conectado' : 'Sin conexión',
            isConnected ? Colors.green : Colors.red,
            isConnected ? Icons.wifi : Icons.wifi_off,
          ),
          const SizedBox(height: 12),
          _buildStatusRow(
            'Operaciones pendientes',
            '$pendingOperations',
            pendingOperations > 0 ? Colors.orange : Colors.green,
            pendingOperations > 0 ? Icons.pending : Icons.check_circle,
          ),
          const SizedBox(height: 12),
          _buildStatusRow(
            'Estado',
            isSyncing ? 'Sincronizando...' : 'En espera',
            isSyncing ? Colors.blue : Colors.grey,
            isSyncing ? Icons.sync : Icons.sync_disabled,
          ),
        ],
      ),
      actions: [
        if (pendingOperations > 0 && isConnected)
          TextButton(
            onPressed: () {
              // Forzar sincronización
              getIt<OfflineSyncService>().forceSync();
              Navigator.of(context).pop();
            },
            child: Text(
              'Sincronizar Ahora',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cerrar', style: GoogleFonts.quicksand()),
        ),
      ],
    );
  }

  Widget _buildStatusRow(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: GoogleFonts.quicksand(fontSize: 14)),
        ),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

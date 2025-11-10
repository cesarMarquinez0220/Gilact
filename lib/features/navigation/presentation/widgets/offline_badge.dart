import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../../core/services/connectivity_service.dart';

/// Widget discreto para mostrar estado offline
class OfflineBadge extends StatefulWidget {
  const OfflineBadge({super.key});

  @override
  State<OfflineBadge> createState() => _OfflineBadgeState();
}

class _OfflineBadgeState extends State<OfflineBadge> {
  bool _isOffline = false;
  StreamSubscription<bool>? _connectivitySubscription;
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    // Escuchar cambios de conectividad usando el servicio
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (bool isConnected) {
        if (mounted) {
          setState(() {
            _isOffline = !isConnected;
          });
        }
      },
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final isConnected = await _connectivityService.isConnected();
      if (mounted) {
        setState(() {
          _isOffline = !isConnected;
        });
      }
    } catch (e) {
      // En caso de error, asumir offline
      if (mounted) {
        setState(() {
          _isOffline = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              'Offline',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


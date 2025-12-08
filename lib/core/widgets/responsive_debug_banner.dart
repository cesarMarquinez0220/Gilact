import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/responsive_helper.dart';

/// Widget de debug que muestra información responsive en tiempo real
/// Solo se muestra en modo debug
///
/// Uso:
/// ```dart
/// ResponsiveDebugBanner(
///   child: YourWidget(),
/// )
/// ```
class ResponsiveDebugBanner extends StatelessWidget {
  final Widget child;
  final bool showBanner;

  const ResponsiveDebugBanner({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    // Solo mostrar en modo debug
    if (!kDebugMode || !showBanner) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.phone_android,
                        size: 12,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ResponsiveHelper.getBreakpointName(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ResponsiveHelper.screenWidth(context).toStringAsFixed(0)} × ${ResponsiveHelper.screenHeight(context).toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Overlay de debug completo con información detallada
/// Se puede activar/desactivar con un gesto
class ResponsiveDebugOverlay extends StatefulWidget {
  final Widget child;

  const ResponsiveDebugOverlay({super.key, required this.child});

  @override
  State<ResponsiveDebugOverlay> createState() => _ResponsiveDebugOverlayState();
}

class _ResponsiveDebugOverlayState extends State<ResponsiveDebugOverlay> {
  bool _showOverlay = false;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (_showOverlay) _buildDebugOverlay(context),
        Positioned(
          bottom: 100,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _showOverlay = !_showOverlay;
              });
            },
            backgroundColor: Colors.black87,
            child: Icon(
              _showOverlay ? Icons.close : Icons.info_outline,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDebugOverlay(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📱 Responsive Debug Info',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Breakpoint',
                ResponsiveHelper.getBreakpointName(context),
              ),
              _buildInfoRow(
                'Screen Size',
                '${ResponsiveHelper.screenWidth(context).toStringAsFixed(0)} × ${ResponsiveHelper.screenHeight(context).toStringAsFixed(0)}',
              ),
              _buildInfoRow(
                'SafeArea Top',
                '${padding.top.toStringAsFixed(0)}px',
              ),
              _buildInfoRow(
                'SafeArea Bottom',
                '${padding.bottom.toStringAsFixed(0)}px',
              ),
              _buildInfoRow(
                'SafeArea Left',
                '${padding.left.toStringAsFixed(0)}px',
              ),
              _buildInfoRow(
                'SafeArea Right',
                '${padding.right.toStringAsFixed(0)}px',
              ),
              _buildInfoRow(
                'Text Scale',
                ResponsiveHelper.textScaleFactor(context).toStringAsFixed(2),
              ),
              _buildInfoRow(
                'Has Notch',
                ResponsiveHelper.hasNotch(context) ? 'Yes' : 'No',
              ),
              _buildInfoRow(
                'Is Tablet',
                ResponsiveHelper.isTablet(context) ? 'Yes' : 'No',
              ),
              _buildInfoRow(
                'Is Short Screen',
                ResponsiveHelper.isShortScreen(context) ? 'Yes' : 'No',
              ),
              const SizedBox(height: 16),
              const Text(
                '📐 Responsive Helpers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Padding',
                '${ResponsiveHelper.getResponsivePadding(context).toStringAsFixed(0)}px',
              ),
              _buildInfoRow(
                'Button Height',
                '${ResponsiveHelper.getResponsiveButtonHeight(context).toStringAsFixed(0)}px',
              ),
              _buildInfoRow(
                'Avatar Size',
                '${ResponsiveHelper.getResponsiveAvatarSize(context).toStringAsFixed(0)}px',
              ),
              _buildInfoRow(
                'Grid Columns',
                '${ResponsiveHelper.getResponsiveColumns(context)}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

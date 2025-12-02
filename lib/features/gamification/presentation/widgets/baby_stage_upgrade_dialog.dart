import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'package:rive/rive.dart'
    as rive
    show
        RiveWidgetBuilder,
        RiveWidget,
        RiveWidgetController,
        FileLoader,
        ArtboardSelector,
        StateMachineSelector,
        RiveLoading,
        RiveFailed,
        RiveLoaded,
        Fit,
        Factory;
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/di/injection.dart';

/// Diálogo que muestra cuando el bebé crece de etapa
class BabyStageUpgradeDialog extends StatefulWidget {
  final String newStage; // 'baby_3months', 'baby_6months'
  final String previousStage; // 'baby_born', 'baby_3months'
  final int completedLessons;

  const BabyStageUpgradeDialog({
    super.key,
    required this.newStage,
    required this.previousStage,
    required this.completedLessons,
  });

  /// Muestra el diálogo
  static void show(
    BuildContext context, {
    required String newStage,
    required String previousStage,
    required int completedLessons,
    bool withVibration = true,
  }) {
    // Vibración y sonido de celebración
    if (withVibration) {
      final SoundService soundService = getIt<SoundService>();
      final VibrationService vibrationService = getIt<VibrationService>();
      soundService.playAchievementSound();
      vibrationService.vibrateOnAchievementDuolingoStyle().catchError((error) {
        vibrationService.vibrateOnAchievement();
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => BabyStageUpgradeDialog(
        newStage: newStage,
        previousStage: previousStage,
        completedLessons: completedLessons,
      ),
    );
  }

  /// Obtiene el nombre de la etapa para mostrar
  String getStageName(String stage) {
    switch (stage) {
      case 'baby_3months':
        return 'gamification.babyStage.3months'.tr();
      case 'baby_6months':
        return 'gamification.babyStage.6months'.tr();
      case 'baby_born':
      default:
        return 'gamification.babyStage.born'.tr();
    }
  }

  /// Obtiene el emoji de la etapa
  String getStageEmoji(String stage) {
    switch (stage) {
      case 'baby_3months':
        return '👶';
      case 'baby_6months':
        return '🧒';
      case 'baby_born':
      default:
        return '👼';
    }
  }

  @override
  State<BabyStageUpgradeDialog> createState() =>
      _BabyStageUpgradeDialogState();
}

class _BabyStageUpgradeDialogState extends State<BabyStageUpgradeDialog>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _scaleController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Confeti en toda la pantalla
        Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: List.generate(5, (index) {
                final position = (screenWidth / 6) * (index + 1);
                return Positioned(
                  top: 0,
                  left: position - 50,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: math.pi / 2,
                    maxBlastForce: 5,
                    minBlastForce: 2,
                    emissionFrequency: 0.05,
                    numberOfParticles: 8,
                    gravity: 0.1,
                    colors: const [
                      Colors.amber,
                      Colors.orange,
                      Colors.yellow,
                      Colors.pink,
                      Colors.purple,
                      Colors.blue,
                      Colors.green,
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        // Diálogo centrado con animación
        Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '🎉 ${'gamification.babyStage.upgradeTitle'.tr()}',
                          style: GoogleFonts.quicksand(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(110),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Efecto de brillo girando
                              AnimatedBuilder(
                                animation: _rotationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle:
                                        _rotationController.value * 2 * math.pi,
                                    child: Opacity(
                                      opacity: 0.5,
                                      child: CustomPaint(
                                        size: const Size(220, 220),
                                        painter: _SunburstPainter(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Animación de Rive del bebé en estado idle
                              _BabyRiveAnimationDialog(
                                babyStage: widget.newStage,
                                size: 200,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'gamification.babyStage.upgradeMessage'.tr(),
                          style: GoogleFonts.quicksand(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'gamification.babyStage.upgradeDescription'
                              .tr(namedArgs: {
                            'newStage': widget.getStageName(widget.newStage),
                            'lessons': widget.completedLessons.toString(),
                          }),
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF667eea),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'gamification.messages.great'.tr(),
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Halo exterior
    final outerHaloGradient = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withValues(alpha: 0.08),
          Colors.yellow.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.1));
    canvas.drawCircle(center, radius * 1.05, outerHaloGradient);

    // Gradiente radial central
    final centralGradient = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.withValues(alpha: 0.6),
          Colors.amber.withValues(alpha: 0.5),
          Colors.orange.withValues(alpha: 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.5));
    canvas.drawCircle(center, radius * 0.5, centralGradient);

    // Rayos principales
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi * 2) / 16;
      final startRadius = radius * 0.3;
      final endRadius = radius * 0.98;
      const startWidth = 2.0;
      const endWidth = 10.0;
      final perpAngle = angle + (math.pi / 2);

      final startX1 = center.dx +
          math.cos(angle) * startRadius +
          math.cos(perpAngle) * (startWidth / 2);
      final startY1 = center.dy +
          math.sin(angle) * startRadius +
          math.sin(perpAngle) * (startWidth / 2);
      final startX2 = center.dx +
          math.cos(angle) * startRadius +
          math.cos(perpAngle) * (-startWidth / 2);
      final startY2 = center.dy +
          math.sin(angle) * startRadius +
          math.sin(perpAngle) * (-startWidth / 2);

      final endX1 = center.dx +
          math.cos(angle) * endRadius +
          math.cos(perpAngle) * (endWidth / 2);
      final endY1 = center.dy +
          math.sin(angle) * endRadius +
          math.sin(perpAngle) * (endWidth / 2);
      final endX2 = center.dx +
          math.cos(angle) * endRadius +
          math.cos(perpAngle) * (-endWidth / 2);
      final endY2 = center.dy +
          math.sin(angle) * endRadius +
          math.sin(perpAngle) * (-endWidth / 2);

      final rayPath = Path()
        ..moveTo(startX1, startY1)
        ..lineTo(endX1, endY1)
        ..lineTo(endX2, endY2)
        ..lineTo(startX2, startY2)
        ..close();

      final rayGradient = LinearGradient(
        begin: Alignment.center,
        end: Alignment(math.cos(angle).toDouble(), math.sin(angle).toDouble()),
        colors: [
          Colors.yellow.withValues(alpha: 0.7),
          Colors.amber.withValues(alpha: 0.6),
          Colors.orange.withValues(alpha: 0.4),
          Colors.orange.withValues(alpha: 0.1),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );

      final rayPaint = Paint()
        ..shader = rayGradient.createShader(
          Rect.fromPoints(Offset(startX1, startY1), Offset(endX2, endY2)),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(rayPath, rayPaint);
    }

    // Puntos brillantes en el perímetro
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi * 2) / 16;
      final pointX = center.dx + math.cos(angle) * radius * 0.96;
      final pointY = center.dy + math.sin(angle) * radius * 0.96;

      final pointHaloPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pointX, pointY), 4, pointHaloPaint);

      final pointPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(pointX, pointY), 2.5, pointPaint);
    }

    // Anillo exterior
    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.amber.withValues(alpha: 0.3)
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.98, outerRingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget simplificado para mostrar la animación de Rive del bebé en el diálogo
class _BabyRiveAnimationDialog extends StatefulWidget {
  final String babyStage; // 'baby_born', 'baby_3months', 'baby_6months'
  final double size;

  const _BabyRiveAnimationDialog({
    required this.babyStage,
    required this.size,
  });

  @override
  State<_BabyRiveAnimationDialog> createState() =>
      _BabyRiveAnimationDialogState();
}

class _BabyRiveAnimationDialogState extends State<_BabyRiveAnimationDialog> {
  late final rive.FileLoader _fileLoader;

  /// Obtiene la ruta del archivo Rive según la etapa del bebé
  String _getRiveFilePath(String babyStage) {
    switch (babyStage) {
      case 'baby_born':
        return 'assets/animations/0meses.riv';
      case 'baby_3months':
        return 'assets/animations/3meses.riv';
      case 'baby_6months':
        return 'assets/animations/6meses.riv';
      default:
        return 'assets/animations/0meses.riv';
    }
  }

  @override
  void initState() {
    super.initState();
    final filePath = _getRiveFilePath(widget.babyStage);
    if (kDebugMode) {
      print('📁 Diálogo: Cargando archivo Rive: $filePath para etapa: ${widget.babyStage}');
    }
    _fileLoader = rive.FileLoader.fromAsset(
      filePath,
      riveFactory: rive.Factory.rive,
    );
  }

  @override
  void didUpdateWidget(_BabyRiveAnimationDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió la etapa del bebé, recargar el archivo
    if (oldWidget.babyStage != widget.babyStage) {
      if (kDebugMode) {
        print(
          '🔄 Diálogo: Etapa del bebé cambió: ${oldWidget.babyStage} -> ${widget.babyStage}',
        );
      }
      _fileLoader.dispose();
      final filePath = _getRiveFilePath(widget.babyStage);
      _fileLoader = rive.FileLoader.fromAsset(
        filePath,
        riveFactory: rive.Factory.rive,
      );
    }
  }

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cada archivo Rive tiene un solo artboard, así que no necesitamos especificar el artboard
    return rive.RiveWidgetBuilder(
      fileLoader: _fileLoader,
      // No especificamos artboardSelector porque cada archivo solo tiene un artboard
      stateMachineSelector: rive.StateMachineSelector.byName('State Machine 1'),
      builder: (context, state) {
        if (state is rive.RiveLoading) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        if (state is rive.RiveFailed) {
          if (kDebugMode) {
            print(
              '❌ Diálogo: Rive falló al cargar archivo para etapa "${widget.babyStage}": ${state.error}',
            );
          }
          // Mostrar error
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
            ),
          );
        }

        if (state is rive.RiveLoaded) {
          // Establecer estado idle para la celebración
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                final stateMachine = state.controller.stateMachine;
                if (stateMachine.inputs.isNotEmpty) {
                  final input = stateMachine.inputs.first;
                  if (input.name == 'state' || input.name == 'Number 1') {
                    (input as dynamic).value = 0.0; // idle
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                  print('⚠️ Error estableciendo estado idle: $e');
                }
              }
            }
          });

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: rive.RiveWidget(
              controller: state.controller,
              fit: rive.Fit.contain,
            ),
          );
        }

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: const Icon(
            Icons.child_care,
            size: 100,
            color: Colors.white,
          ),
        );
      },
    );
  }
}


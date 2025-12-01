import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
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
import 'dart:ui' as ui;
import '../../../gamification/domain/entities/user_gamification_profile.dart';

/// Widget wrapper que agrega interactividad a la mascota
class CompanionMascotWrapper extends StatefulWidget {
  final UserGamificationProfile profile;
  final double size;

  const CompanionMascotWrapper({
    required this.profile,
    required this.size,
    super.key,
  });

  @override
  State<CompanionMascotWrapper> createState() => _CompanionMascotWrapperState();
}

class _CompanionMascotWrapperState extends State<CompanionMascotWrapper>
    with TickerProviderStateMixin {
  int _tapCount = 0;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  String? _currentMessage;

  // Mensajes rotativos para la mascota (se traducirán dinámicamente)
  List<String> get _messages => [
    'gamification.messages.helloHowAreYou'.tr(),
    'companion.mascotMessages.keepGoing'.tr(),
    'companion.mascotMessages.everyRecordCounts'.tr(),
    'companion.mascotMessages.yourWellbeing'.tr(),
    'companion.mascotMessages.youAreAdvancing'.tr(),
    'companion.mascotMessages.takeYourTime'.tr(),
    'companion.mascotMessages.youAreSuperMom'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    // Controlador para animación de escala de la mascota
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Vibración suave
    HapticFeedback.lightImpact();

    // Animación de escala de la mascota
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    // Mostrar mensaje rotativo
    setState(() {
      _tapCount = (_tapCount + 1) % _messages.length;
      _currentMessage = _messages[_tapCount];
    });

    // Ocultar el mensaje después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentMessage = null;
        });
      }
    });
  }

  /// Mapea el estado de la mascota al estado de la state machine de Rive
  String _getRiveState(String mascotState) {
    switch (mascotState) {
      case 'worried':
        return 'worried';
      case 'happy':
      case 'celebrating':
      case 'supporting':
      case 'thinking':
        return 'happy';
      case 'sleeping':
      default:
        return 'idle';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener mensaje por defecto según el estado
    String defaultMessage;
    switch (widget.profile.mascotState) {
      case 'celebrating':
        defaultMessage = 'gamification.messages.excellentWork'.tr();
        break;
      case 'thinking':
        defaultMessage = 'gamification.messages.closeToLevelUp'.tr();
        break;
      case 'worried':
        defaultMessage = 'gamification.messages.streakAtRisk'.tr();
        break;
      case 'supporting':
        defaultMessage = 'gamification.messages.takeYourTime'.tr();
        break;
      case 'sleeping':
        defaultMessage = 'gamification.messages.restWell'.tr();
        break;
      case 'happy':
      default:
        defaultMessage = 'gamification.messages.helloHowAreYou'.tr();
        break;
    }

    final messageToShow = _currentMessage ?? defaultMessage;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 1. LA MASCOTA (centrada, ligeramente más abajo)
            Padding(
              padding: const EdgeInsets.only(top: 35),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: _BabyRiveAnimation(
                    state: _getRiveState(widget.profile.mascotState),
                    babyStage: widget.profile.babyStage,
                    size: widget.size,
                  ),
                ),
              ),
            ),
            // 2. LA BURBUJA (posición fija arriba y a la derecha de la mascota)
            if (messageToShow.isNotEmpty)
              Positioned(
                top: -20,
                left: widget.size * 0.3,
                child: ZoomIn(
                  key: ValueKey(messageToShow),
                  duration: const Duration(milliseconds: 600),
                  child: CompanionSpeechBubble(message: messageToShow),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget de burbuja de mensaje estilo cómic
class CompanionSpeechBubble extends StatelessWidget {
  final String message;

  const CompanionSpeechBubble({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    // Calcular el tamaño dinámico basado en el contenido del mensaje
    final textPainter = TextPainter(
      text: TextSpan(
        text: message,
        style: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C3E50),
          height: 1.3,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 3,
    );
    textPainter.layout(maxWidth: 200);

    // El ancho se ajusta dinámicamente al contenido, con límites
    final dynamicWidth = (textPainter.width + 32).clamp(120.0, 220.0);

    return CustomPaint(
      // Usamos el nuevo painter de nube
      painter: _CloudBubblePainter(),
      child: Container(
        width: dynamicWidth,
        // --- PADDING CRÍTICO ---
        // Aumentamos mucho el padding para que el texto quede centrado
        // y seguro dentro de la forma irregular de la nube.
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
            height: 1.3,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Painter para dibujar la burbuja con forma de nube
class _CloudBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = ui.PaintingStyle.fill;

    // El path que define la forma de la nube
    final path = Path();
    final w = size.width;
    final h = size.height;

    // --- DIBUJO DE LA FORMA DE NUBE ---
    // Empezamos en la parte inferior izquierda
    path.moveTo(w * 0.25, h * 0.9);

    // Curva hacia el bulto inferior izquierdo
    path.quadraticBezierTo(w * 0.05, h * 0.95, w * 0.02, h * 0.6);

    // Bulto grande superior izquierdo
    path.cubicTo(
      w * -0.05,
      h * 0.3, // Control 1: hacia afuera y arriba
      w * 0.2,
      h * -0.1, // Control 2: muy arriba y al centro
      w * 0.45,
      h * 0.1, // Destino: el "valle" superior
    );

    // Bulto grande superior derecho
    path.cubicTo(
      w * 0.65,
      h * -0.1, // Control 1: arriba y a la derecha
      w * 1.05,
      h * 0.2, // Control 2: muy a la derecha y abajo
      w * 0.98,
      h * 0.6, // Destino: lateral derecho
    );

    // Curva hacia el bulto inferior derecho
    path.quadraticBezierTo(w * 1.0, h * 0.9, w * 0.75, h * 0.95);

    // Cierre por la parte inferior con una curva suave
    path.quadraticBezierTo(w * 0.5, h * 1.02, w * 0.25, h * 0.9);
    path.close();

    // --- DIBUJADO DE LA SOMBRA ---
    // Usamos un color oscuro con transparencia y un filtro de desenfoque
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        12.0,
      ); // Mucho desenfoque para suavidad

    // Dibujamos la sombra desplazada ligeramente hacia abajo (Offset(0, 6))
    canvas.drawPath(path.shift(const Offset(0, 6)), shadowPaint);

    // --- DIBUJADO DE LA NUBE BLANCA ---
    // Dibujamos la forma blanca encima de la sombra
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget helper para mostrar la animación Rive del bebé
class _BabyRiveAnimation extends StatefulWidget {
  final String state; // 'idle', 'happy', 'worried'
  final String babyStage; // 'baby_born', 'baby_3months', 'baby_6months'
  final double size;

  const _BabyRiveAnimation({
    required this.state,
    required this.babyStage,
    required this.size,
  });

  @override
  State<_BabyRiveAnimation> createState() => _BabyRiveAnimationState();
}

class _BabyRiveAnimationState extends State<_BabyRiveAnimation> {
  late final rive.FileLoader _fileLoader;
  rive.RiveWidgetController? _controller;

  @override
  void initState() {
    super.initState();
    _fileLoader = rive.FileLoader.fromAsset(
      'assets/animations/baby_born.riv',
      riveFactory: rive.Factory.rive,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _fileLoader.dispose();
    super.dispose();
  }

  void _updateState(String newState) {
    if (kDebugMode) {
      print(
        '🔍 _updateState llamado: newState=$newState, babyStage=${widget.babyStage}',
      );
    }

    if (_controller == null) {
      if (kDebugMode) {
        print('❌ _controller es null, no se puede actualizar el estado');
      }
      return;
    }

    // Obtener la máquina de estados del controlador
    final stateMachine = _controller!.stateMachine;

    if (stateMachine.inputs.isEmpty) {
      if (kDebugMode) {
        print('❌ stateMachine.inputs está vacío');
      }
      return;
    }

    if (kDebugMode) {
      print('📋 Inputs disponibles en la máquina de estados:');
      for (var i = 0; i < stateMachine.inputs.length; i++) {
        final input = stateMachine.inputs[i];
        print(
          '   - Input $i: nombre="${input.name}", tipo=${input.runtimeType}',
        );
      }
    }

    // Si es baby_6months, solo usar idle (no tiene happy/worried)
    final stateToUse = widget.babyStage == 'baby_6months' ? 'idle' : newState;

    // Mapear el estado a un valor numérico para el input "Number 1"
    // 0 = idle, 1 = happy, 2 = worried (ajustar según tu configuración en Rive)
    double stateValue = 0.0;
    switch (stateToUse) {
      case 'happy':
        stateValue = 1.0;
        break;
      case 'worried':
        stateValue = 2.0;
        break;
      case 'idle':
      default:
        stateValue = 0.0;
        break;
    }

    if (kDebugMode) {
      print(
        '🎯 Intentando establecer estado: $stateToUse -> valor numérico: $stateValue',
      );
    }

    // Buscar y establecer el valor del input "Number 1"
    bool inputFound = false;
    try {
      // Acceder a los inputs de la máquina de estados
      for (var i = 0; i < stateMachine.inputs.length; i++) {
        final input = stateMachine.inputs[i];
        if (kDebugMode) {
          print('   Verificando input $i: nombre="${input.name}"');
        }

        // Buscar el input "Number 1" (nombre correcto según Rive)
        if (input.name == 'Number 1' || input.name == 'state') {
          inputFound = true;
          if (kDebugMode) {
            print(
              '✅ Input encontrado: "${input.name}", estableciendo valor: $stateValue',
            );
          }

          // Establecer el valor del input numérico
          try {
            (input as dynamic).value = stateValue;
            if (kDebugMode) {
              print(
                '✅✅ Valor establecido correctamente en input "${input.name}"',
              );
            }
            break;
          } catch (e, stackTrace) {
            if (kDebugMode) {
              print('⚠️ Error estableciendo valor del input: $e');
              print('   Stack trace: $stackTrace');
            }
          }
        }
      }

      if (!inputFound && kDebugMode) {
        print(
          '❌ No se encontró el input "Number 1" o "state" en la máquina de estados',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error general actualizando estado Rive: $e');
        print('   Stack trace: $stackTrace');
      }
    }
  }

  @override
  void didUpdateWidget(_BabyRiveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state ||
        oldWidget.babyStage != widget.babyStage) {
      _updateState(widget.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(
        '🎨 _BabyRiveAnimation.build: babyStage=${widget.babyStage}, state=${widget.state}',
      );
    }

    // Intentar cargar el artboard solicitado, con fallback a baby_born
    return rive.RiveWidgetBuilder(
      fileLoader: _fileLoader,
      artboardSelector: rive.ArtboardSelector.byName(widget.babyStage),
      stateMachineSelector: rive.StateMachineSelector.byName('State Machine 1'),
      builder: (context, state) {
        if (state is rive.RiveLoading) {
          if (kDebugMode) {
            print('⏳ Rive cargando artboard: ${widget.babyStage}...');
          }
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is rive.RiveFailed) {
          if (kDebugMode) {
            print(
              '❌ Rive falló al cargar artboard "${widget.babyStage}": ${state.error}',
            );
            // Si el error es que no se encuentra el artboard, intentar con baby_born
            if (state.error.toString().contains('not found') &&
                widget.babyStage != 'baby_born') {
              print('🔄 Intentando fallback a artboard "baby_born"...');
            }
          }

          // Si el artboard solicitado no existe, intentar sin especificar artboard (usará el por defecto)
          if (state.error.toString().contains('not found')) {
            if (kDebugMode) {
              print('🔄 Intentando usar el artboard por defecto...');
            }
            return rive.RiveWidgetBuilder(
              fileLoader: _fileLoader,
              // Sin artboardSelector, usará el artboard por defecto del archivo
              stateMachineSelector: rive.StateMachineSelector.byName(
                'State Machine 1',
              ),
              builder: (context, fallbackState) {
                if (fallbackState is rive.RiveLoading) {
                  return SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (fallbackState is rive.RiveFailed) {
                  if (kDebugMode) {
                    print('❌ Fallback también falló: ${fallbackState.error}');
                  }
                  return SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        if (kDebugMode)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Error: ${fallbackState.error}',
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  );
                }

                if (fallbackState is rive.RiveLoaded) {
                  if (kDebugMode) {
                    print('✅ Fallback exitoso: usando el artboard por defecto');
                    // Intentar obtener información del artboard cargado
                    try {
                      final artboard = fallbackState.controller.artboard;
                      print('   📋 Artboard cargado: ${artboard.name}');

                      // Intentar listar todos los artboards disponibles
                      try {
                        final riveFile = fallbackState.controller.file;
                        print(
                          '   📚 Intentando listar artboards disponibles...',
                        );
                        // Nota: La API de Rive puede variar, intentamos acceder de diferentes formas
                        try {
                          // Intentar acceder a los artboards a través del archivo
                          final artboards = (riveFile as dynamic).artboards;
                          if (artboards != null) {
                            if (artboards is List && artboards.isNotEmpty) {
                              print(
                                '   📚 Artboards disponibles en el archivo:',
                              );
                              for (var i = 0; i < artboards.length; i++) {
                                final ab = artboards[i];
                                final name = (ab as dynamic).name;
                                print('      ${i + 1}. "$name"');
                              }
                            } else {
                              print(
                                '      ⚠️ La lista de artboards está vacía',
                              );
                            }
                          } else {
                            print(
                              '      ⚠️ No se pudieron obtener los artboards del archivo',
                            );
                          }
                        } catch (e) {
                          print('      ⚠️ Error al acceder a artboards: $e');
                          print(
                            '      💡 Tip: Verifica los nombres de los artboards en Rive',
                          );
                        }
                      } catch (e) {
                        print('   ⚠️ No se pudo acceder al archivo Rive: $e');
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print(
                          '   ⚠️ No se pudo obtener el nombre del artboard: $e',
                        );
                      }
                    }
                  }
                  _controller = fallbackState.controller;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _updateState(widget.state);
                    }
                  });
                  return SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: rive.RiveWidget(
                      controller: fallbackState.controller,
                      fit: rive.Fit.contain,
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            );
          }

          // Si no es un error de artboard no encontrado, mostrar el error
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                if (kDebugMode)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error: ${state.error}',
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        }

        if (state is rive.RiveLoaded) {
          if (kDebugMode) {
            print('✅ Rive cargado exitosamente');
            print('   Artboard solicitado: ${widget.babyStage}');
            print('   State Machine: State Machine 1');
            print('   Controller: ${state.controller}');
            print(
              '   State Machine del controller: ${state.controller.stateMachine}',
            );

            // Intentar listar todos los artboards disponibles
            try {
              final artboard = state.controller.artboard;
              if (artboard != null) {
                print('   📋 Artboard actual cargado: ${artboard.name}');
              }

              // Intentar acceder al archivo Rive para listar todos los artboards
              try {
                final riveFile = state.controller.file;
                print('   📚 Intentando listar artboards disponibles...');
                // Nota: La API de Rive puede variar, intentamos acceder de diferentes formas
                try {
                  // Intentar acceder a los artboards a través del archivo
                  final artboards = (riveFile as dynamic).artboards;
                  if (artboards != null) {
                    if (artboards is List && artboards.isNotEmpty) {
                      print('   📚 Artboards disponibles en el archivo:');
                      for (var i = 0; i < artboards.length; i++) {
                        final ab = artboards[i];
                        final name = (ab as dynamic).name;
                        print('      ${i + 1}. "$name"');
                      }
                    } else {
                      print('      ⚠️ La lista de artboards está vacía');
                    }
                  } else {
                    print(
                      '      ⚠️ No se pudieron obtener los artboards del archivo',
                    );
                  }
                } catch (e) {
                  print('      ⚠️ Error al acceder a artboards: $e');
                  print(
                    '      💡 Tip: Verifica los nombres de los artboards en Rive',
                  );
                }
              } catch (e) {
                print('   ⚠️ No se pudo acceder al archivo Rive: $e');
              }
            } catch (e) {
              if (kDebugMode) {
                print('   ⚠️ Error al obtener información de artboards: $e');
              }
            }
          }

          // Guardar el controlador para poder actualizar el estado
          _controller = state.controller;

          // Actualizar el estado después de que se carga
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (kDebugMode) {
                print(
                  '🔄 PostFrameCallback: actualizando estado a ${widget.state}',
                );
              }
              _updateState(widget.state);
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

        if (kDebugMode) {
          print('⚠️ Estado desconocido de Rive: ${state.runtimeType}');
        }
        return const SizedBox.shrink();
      },
    );
  }
}

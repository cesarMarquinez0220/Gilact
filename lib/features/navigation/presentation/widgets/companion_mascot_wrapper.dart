import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_shadow/simple_shadow.dart';
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
  Timer? _messageTimer;

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

  /// Obtiene el mensaje por defecto según el estado de la mascota
  String _getDefaultMessage(String mascotState) {
    switch (mascotState) {
      case 'celebrating':
        return 'gamification.messages.excellentWork'.tr();
      case 'thinking':
        return 'gamification.messages.closeToLevelUp'.tr();
      case 'worried':
        return 'gamification.messages.streakAtRisk'.tr();
      case 'supporting':
        return 'gamification.messages.takeYourTime'.tr();
      case 'sleeping':
        return 'gamification.messages.restWell'.tr();
      case 'happy':
      default:
        return 'gamification.messages.helloHowAreYou'.tr();
    }
  }

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
    _messageTimer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Vibración suave
    HapticFeedback.lightImpact();

    // Cancelar el timer anterior si existe
    _messageTimer?.cancel();

    // Animación de escala de la mascota
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    // Mostrar mensaje rotativo
    // Incrementar primero el contador para obtener el siguiente mensaje
    _tapCount = (_tapCount + 1) % _messages.length;
    final selectedMessage = _messages[_tapCount];
    setState(() {
      _currentMessage = selectedMessage;
    });

    // Mantener el mensaje visible por más tiempo (6 segundos)
    // y luego volver al mensaje por defecto solo si el usuario no ha tocado de nuevo
    _messageTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        // Solo volver al mensaje por defecto si el mensaje actual sigue siendo el mismo
        setState(() {
          if (_currentMessage == selectedMessage) {
            _currentMessage = null;
          }
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
    // Cachear el mensaje para evitar reconstrucciones innecesarias
    final defaultMessage = _getDefaultMessage(widget.profile.mascotState);
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
            // 1. LA MASCOTA (centrada, más abajo para dar más espacio)
            // Usar RepaintBoundary para aislar la animación Rive del scroll
            // Esto previene los warnings de "Unable to acquire buffer item"
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: RepaintBoundary(
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
            ),
            // 2. LA BURBUJA (posición fija arriba y a la derecha de la mascota, más abajo)
            if (messageToShow.isNotEmpty)
              Positioned(
                top: -20,
                left: widget.size * 0.45,
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
    // Aumentamos significativamente el padding para asegurar que el texto siempre quepa
    const maxTextWidth = 200.0; // Reducimos un poco para forzar más padding
    const horizontalPadding = 80.0; // Padding horizontal muy generoso
    const verticalPadding = 60.0; // Padding vertical muy generoso

    final textPainter = TextPainter(
      text: TextSpan(
        text: message,
        style: GoogleFonts.quicksand(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C3E50),
          height: 1.25,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 3,
    );
    textPainter.layout(maxWidth: maxTextWidth);

    // El ancho se ajusta dinámicamente al contenido, con mucho padding
    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    // Aumentamos significativamente los límites para hacer la nube más grande
    // y asegurar que el texto siempre quepa con mucho margen
    final dynamicWidth = (textWidth + horizontalPadding).clamp(200.0, 320.0);
    // Altura calculada basada en el contenido del texto con mucho padding vertical
    final dynamicHeight = (textHeight + verticalPadding).clamp(120.0, 180.0);

    return Stack(
      alignment:
          Alignment.center, // 1. Asegura que todo parta del centro exacto
      children: [
        // SVG de la nube (Fondo)
        SimpleShadow(
          opacity: 0.20,
          color: Colors.black,
          offset: const Offset(0, 4),
          sigma: 4,
          child: SvgPicture.asset(
            'assets/images/nube.svg',
            width: dynamicWidth,
            height: dynamicHeight,
            fit: BoxFit.contain,
          ),
        ),

        // Contenedor del Texto
        Container(
          // 2. CORRECCIÓN CLAVE:
          // Bajamos de 0.75 a 0.60. Esto obliga al texto a quedarse
          // en el centro seguro de la nube, lejos de los bordes curvos.
          width: dynamicWidth * 0.45,

          // 3. PADDING ESTRATÉGICO:
          // - Horizontal: 0 (ya lo controlamos con el width de arriba).
          // - Top: Poco padding.
          // - Bottom: MÁS padding para salvar la "colita" de la nube.
          padding: const EdgeInsets.only(top: 30, bottom: 25),

          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700, // Subí un poco el peso para legibilidad
              color: const Color(0xFF2C3E50),
              height: 1.2,
            ),
            maxLines: 3,
            // Si el texto es muy largo, ajusta el tamaño automáticamente para que quepa
            // Esto es un truco extra por si el usuario tiene una pantalla pequeña
            textScaleFactor: 1.0,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Widget helper para mostrar la animación Rive del bebé
/// Optimizado para evitar reconstrucciones durante el scroll
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

class _BabyRiveAnimationState extends State<_BabyRiveAnimation>
    with AutomaticKeepAliveClientMixin {
  late final rive.FileLoader _fileLoader;
  rive.RiveWidgetController? _controller;

  @override
  bool get wantKeepAlive => true; // Mantener el estado vivo para evitar reconstrucciones

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
      print(
        '📁 Cargando archivo Rive: $filePath para etapa: ${widget.babyStage}',
      );
    }
    _fileLoader = rive.FileLoader.fromAsset(
      filePath,
      riveFactory: rive.Factory.rive,
    );
  }

  @override
  void didUpdateWidget(_BabyRiveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió la etapa del bebé, necesitamos recargar el archivo
    if (oldWidget.babyStage != widget.babyStage) {
      if (kDebugMode) {
        print(
          '🔄 Etapa del bebé cambió: ${oldWidget.babyStage} -> ${widget.babyStage}',
        );
      }
      _fileLoader.dispose();
      final filePath = _getRiveFilePath(widget.babyStage);
      _fileLoader = rive.FileLoader.fromAsset(
        filePath,
        riveFactory: rive.Factory.rive,
      );
      // Resetear el controlador para que se recargue con el nuevo archivo
      _controller = null;
    }
    // Si cambió el estado, actualizar
    if (oldWidget.state != widget.state && _controller != null) {
      _updateState(widget.state);
    }
  }

  @override
  void dispose() {
    // No desechar _controller manualmente - RiveWidget lo maneja automáticamente
    // Desecharlo manualmente causa un error de doble disposición
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

    // Obtener la máquina de estados del controlador9
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

  /// Construye el widget de Rive basándose en el estado
  Widget _buildRiveWidget(dynamic state, String fallbackName) {
    if (state is rive.RiveLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state is rive.RiveFailed) {
      if (kDebugMode) {
        print('❌ Fallback "$fallbackName" también falló: ${state.error}');
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
        final artboard = state.controller.artboard;
        print(
          '✅ Artboard cargado exitosamente: "${artboard.name}" (solicitado: "${widget.babyStage}", fallback: "$fallbackName")',
        );
      }

      _controller = state.controller;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateState(widget.state);
        }
      });

      // Usar RepaintBoundary para aislar la animación Rive y evitar reconstrucciones
      // durante el scroll. Esto previene los warnings de "Unable to acquire buffer item"
      return RepaintBoundary(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: rive.RiveWidget(
            controller: state.controller,
            fit: rive.Fit.contain,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Requerido para AutomaticKeepAliveClientMixin

    if (kDebugMode) {
      print(
        '🎨 _BabyRiveAnimation.build: babyStage=${widget.babyStage}, state=${widget.state}',
      );
    }

    // Cada archivo Rive tiene un solo artboard, así que no necesitamos especificar el artboard
    // El archivo correcto ya se carga según la etapa del bebé
    // Usar RepaintBoundary para aislar completamente la animación
    return RepaintBoundary(
      child: rive.RiveWidgetBuilder(
        fileLoader: _fileLoader,
        // No especificamos artboardSelector porque cada archivo solo tiene un artboard
        stateMachineSelector: rive.StateMachineSelector.byName(
          'State Machine 1',
        ),
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

            // Si el artboard solicitado no existe, intentar con artboards alternativos en orden
            if (state.error.toString().contains('not found')) {
              if (kDebugMode) {
                print(
                  '🔄 Artboard "${widget.babyStage}" no encontrado, intentando fallback...',
                );
              }

              // Lista de artboards a intentar en orden de prioridad
              final fallbackArtboards = <String>[];
              if (widget.babyStage == 'baby_6months') {
                // Si se solicita baby_6months y no existe, intentar baby_3months y luego baby_born
                fallbackArtboards.addAll(['baby_3months', 'baby_born']);
              } else if (widget.babyStage == 'baby_3months') {
                // Si se solicita baby_3months y no existe, intentar baby_born
                fallbackArtboards.add('baby_born');
              } else {
                // Si se solicita baby_born y no existe, usar el artboard por defecto
                fallbackArtboards.add('baby_born');
              }

              // Intentar cargar el primer artboard de fallback
              if (fallbackArtboards.isNotEmpty) {
                final fallbackArtboard = fallbackArtboards.first;
                if (kDebugMode) {
                  print(
                    '🔄 Intentando cargar artboard de fallback: "$fallbackArtboard"',
                  );
                }
                return rive.RiveWidgetBuilder(
                  fileLoader: _fileLoader,
                  artboardSelector: rive.ArtboardSelector.byName(
                    fallbackArtboard,
                  ),
                  stateMachineSelector: rive.StateMachineSelector.byName(
                    'State Machine 1',
                  ),
                  builder: (context, fallbackState) {
                    if (fallbackState is rive.RiveFailed) {
                      // Si el fallback también falla, intentar sin especificar artboard
                      if (kDebugMode) {
                        print(
                          '🔄 Fallback "$fallbackArtboard" también falló, usando artboard por defecto...',
                        );
                      }
                      return rive.RiveWidgetBuilder(
                        fileLoader: _fileLoader,
                        stateMachineSelector: rive.StateMachineSelector.byName(
                          'State Machine 1',
                        ),
                        builder: (context, defaultState) {
                          return _buildRiveWidget(defaultState, 'default');
                        },
                      );
                    }
                    return _buildRiveWidget(fallbackState, fallbackArtboard);
                  },
                );
              }

              // Si no hay fallbacks, usar el artboard por defecto
              if (kDebugMode) {
                print('🔄 Usando el artboard por defecto del archivo...');
              }
              return rive.RiveWidgetBuilder(
                fileLoader: _fileLoader,
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

                  return _buildRiveWidget(fallbackState, 'default');
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
              print('   Etapa del bebé: ${widget.babyStage}');
              print(
                '   Archivo cargado: ${_getRiveFilePath(widget.babyStage)}',
              );
              try {
                final artboard = state.controller.artboard;
                print('   📋 Artboard cargado: ${artboard.name}');
              } catch (e) {
                // Ignorar error al obtener nombre del artboard
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

            // Usar múltiples capas de optimización para evitar warnings de buffer
            // 1. RepaintBoundary aísla el renderizado
            // 2. ClipRect previene overflow de renderizado
            // 3. SizedBox limita el área de renderizado
            return RepaintBoundary(
              child: ClipRect(
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: rive.RiveWidget(
                    controller: state.controller,
                    fit: rive.Fit.contain,
                  ),
                ),
              ),
            );
          }

          if (kDebugMode) {
            print('⚠️ Estado desconocido de Rive: ${state.runtimeType}');
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

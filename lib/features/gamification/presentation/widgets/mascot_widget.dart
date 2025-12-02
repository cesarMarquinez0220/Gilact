import 'package:flutter/material.dart';
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
import '../../domain/entities/user_gamification_profile.dart';

/// Widget mejorado que muestra el muñequito animado con información de gamificación
/// Estados: happy, celebrating, thinking, worried, supporting, sleeping
class MascotWidget extends StatelessWidget {
  final UserGamificationProfile profile;
  final double size;
  final VoidCallback? onTap;

  const MascotWidget({
    super.key,
    required this.profile,
    this.size = 120,
    this.onTap,
  });

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
    String message;
    Color messageColor;
    Color cardGradientStart;
    Color cardGradientEnd;

    switch (profile.mascotState) {
      case 'celebrating':
        message = 'gamification.messages.excellentWork'.tr();
        messageColor = const Color(0xFFE74C3C);
        cardGradientStart = const Color(0xFFFFE5E5);
        cardGradientEnd = Colors.white;
        break;
      case 'thinking':
        message = 'gamification.messages.closeToLevelUp'.tr();
        messageColor = const Color(0xFF3498DB);
        cardGradientStart = const Color(0xFFE3F2FD);
        cardGradientEnd = Colors.white;
        break;
      case 'worried':
        message = 'gamification.messages.streakAtRisk'.tr();
        messageColor = const Color(0xFFF39C12);
        cardGradientStart = const Color(0xFFFFF3E0);
        cardGradientEnd = Colors.white;
        break;
      case 'supporting':
        message = 'gamification.messages.takeYourTime'.tr();
        messageColor = const Color(0xFF3498DB);
        cardGradientStart = const Color(0xFFE3F2FD);
        cardGradientEnd = Colors.white;
        break;
      case 'sleeping':
        message = 'gamification.messages.restWell'.tr();
        messageColor = Colors.grey;
        cardGradientStart = const Color(0xFFF5F5F5);
        cardGradientEnd = Colors.white;
        break;
      case 'happy':
      default:
        message = 'gamification.messages.helloHowAreYou'.tr();
        messageColor = const Color(0xFF2ECC71);
        cardGradientStart = const Color(0xFFE8F5E9);
        cardGradientEnd = Colors.white;
        break;
    }

    // Calcular progreso del nivel
    final levelProgress = profile.nextLevelXP > 0
        ? profile.currentLevelXP / profile.nextLevelXP
        : 0.0;

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardGradientStart, cardGradientEnd],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: messageColor.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Icono decorativo en esquina superior derecha
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: messageColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStateIcon(profile.mascotState),
                    color: messageColor,
                    size: 18,
                  ),
                ),
              ),

              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Animación de la mascota con Rive
                    FadeIn(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: messageColor.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: _BabyRiveAnimation(
                          state: _getRiveState(profile.mascotState),
                          babyStage: profile.babyStage,
                          size: size,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Mensaje del estado
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: messageColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Información de nivel y XP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Nivel
                        _buildStatItem(
                          icon: Icons.star,
                          label: 'gamification.level'.tr(),
                          value: '${profile.currentLevel}',
                          color: messageColor,
                        ),

                        // Racha
                        if (profile.currentStreak > 0)
                          _buildStatItem(
                            icon: Icons.local_fire_department,
                            label: 'companion.streak'.tr(),
                            value: '${profile.currentStreak}',
                            color: const Color(0xFFFF6B35),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Barra de progreso del nivel
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progreso al nivel ${profile.currentLevel + 1}',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF7F8C8D),
                              ),
                            ),
                            Text(
                              '${profile.currentLevelXP}/${profile.nextLevelXP} XP',
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: messageColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: levelProgress.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              messageColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Badges recientes (si hay)
                    if (profile.unlockedAchievements.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 14,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.unlockedAchievements.length} logros',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye un item de estadística
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }

  /// Obtiene el icono según el estado de la mascota
  IconData _getStateIcon(String state) {
    switch (state) {
      case 'celebrating':
        return Icons.celebration;
      case 'thinking':
        return Icons.lightbulb;
      case 'worried':
        return Icons.warning_amber;
      case 'supporting':
        return Icons.favorite;
      case 'sleeping':
        return Icons.bedtime;
      case 'happy':
      default:
        return Icons.mood;
    }
  }
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
      print('📁 MascotWidget: Cargando archivo Rive: $filePath para etapa: ${widget.babyStage}');
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
          '🔄 MascotWidget: Etapa del bebé cambió: ${oldWidget.babyStage} -> ${widget.babyStage}',
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
    _controller?.dispose();
    _fileLoader.dispose();
    super.dispose();
  }

  void _updateState(String newState) {
    if (_controller == null) return;

    // Obtener la máquina de estados del controlador
    final stateMachine = _controller!.stateMachine;

    // Si es baby_6months, solo usar idle (no tiene happy/worried)
    final stateToUse = widget.babyStage == 'baby_6months' ? 'idle' : newState;

    // Mapear el estado a un valor numérico para el input "state"
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

    // Buscar y establecer el valor del input "state"
    try {
      // Acceder a los inputs de la máquina de estados
      // En Rive 0.14.0-dev, los inputs se acceden a través de stateMachine.inputs
      for (var i = 0; i < stateMachine.inputs.length; i++) {
        final input = stateMachine.inputs[i];
        if (input.name == 'state') {
          // Establecer el valor del input numérico
          // Usar dynamic para evitar problemas de tipo en tiempo de compilación
          try {
            // Intentar establecer el valor usando reflexión o método directo
            (input as dynamic).value = stateValue;
            if (kDebugMode) {
              print(
                '✅ Estado Rive actualizado: $stateToUse (valor: $stateValue)',
              );
            }
            break;
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error estableciendo valor del input: $e');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error actualizando estado Rive: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(
        '🎨 _BabyRiveAnimation.build: babyStage=${widget.babyStage}, state=${widget.state}',
      );
    }

    // Cada archivo Rive tiene un solo artboard, así que no necesitamos especificar el artboard
    // El archivo correcto ya se carga según la etapa del bebé
    return rive.RiveWidgetBuilder(
      fileLoader: _fileLoader,
      // No especificamos artboardSelector porque cada archivo solo tiene un artboard
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
              '❌ MascotWidget: Rive falló al cargar archivo para etapa "${widget.babyStage}": ${state.error}',
            );
          }
          // Mostrar error
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

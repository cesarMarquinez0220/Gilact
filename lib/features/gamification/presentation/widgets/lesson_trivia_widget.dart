import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/trivia_question.dart';
import '../../domain/services/trivia_service.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/di/injection.dart';
import '../../domain/services/xp_calculation_service.dart';
import '../../domain/services/gamification_service.dart';
import '../../domain/services/user_statistics_service.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../../presentation/bloc/gamification_bloc.dart';
import '../../presentation/bloc/gamification_event.dart';
import '../../presentation/services/achievement_queue_service.dart';
import 'xp_celebration_animation.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget que muestra una trivia después de completar una lección
class LessonTriviaWidget extends StatefulWidget {
  final String lessonId;
  final String userId;
  final VoidCallback? onComplete;
  final BuildContext?
  originalContext; // Contexto original con acceso al Overlay

  const LessonTriviaWidget({
    super.key,
    required this.lessonId,
    required this.userId,
    this.onComplete,
    this.originalContext,
  });

  @override
  State<LessonTriviaWidget> createState() => _LessonTriviaWidgetState();

  /// Muestra el widget de trivia como diálogo
  static Future<void> show(
    BuildContext context, {
    required String lessonId,
    required String userId,
    VoidCallback? onComplete,
  }) async {
    // Guardar el contexto original antes de mostrar el diálogo
    // Este contexto tiene acceso al Overlay
    final originalContext = context;

    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2C5F5D), // Azul teal oscuro
                Color(0xFF1A365D), // Azul marino oscuro
                Color(0xFF4FD1C7), // Verde azulado vibrante
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: LessonTriviaWidget(
              lessonId: lessonId,
              userId: userId,
              onComplete: onComplete,
              originalContext: originalContext, // Pasar el contexto original
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonTriviaWidgetState extends State<LessonTriviaWidget> {
  final TriviaService _triviaService = TriviaService();
  final XPCalculationService _xpCalculationService = XPCalculationService();

  List<TriviaQuestion> _questions = [];
  List<int> _selectedAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isCompleted = false;
  int _correctAnswers = 0;
  bool _isSubmitting = false;
  int _totalXP = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    final questions = _triviaService.getTriviaForLesson(widget.lessonId);
    // Seleccionar 3-4 preguntas aleatorias
    questions.shuffle();
    setState(() {
      _questions = questions.take(4).toList();
      _selectedAnswers = List.filled(_questions.length, -1);
    });
  }

  void _selectAnswer(int answerIndex) {
    if (_isCompleted) return;

    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
    });

    // Vibración suave al seleccionar usando el servicio
    final vibrationService = getIt<VibrationService>();
    vibrationService.selectionClick();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitTrivia();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitTrivia() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    // Calcular respuestas correctas
    _correctAnswers = _triviaService.calculateScore(
      _questions,
      _selectedAnswers,
    );

    final timestamp = DateTime.now();

    // Calcular XP de trivia
    final triviaTransaction = _xpCalculationService.calculateXPForTrivia(
      userId: widget.userId,
      lessonId: widget.lessonId,
      correctAnswers: _correctAnswers,
      totalQuestions: _questions.length,
      timestamp: timestamp,
    );

    // Calcular XP de lección completada
    final lessonTransaction = _xpCalculationService
        .calculateXPForLessonCompleted(
          userId: widget.userId,
          lessonId: widget.lessonId,
          timestamp: timestamp,
          isFirstOfDay: false, // TODO: Verificar si es primera lección del día
        );

    // Calcular XP total para la animación
    _totalXP = triviaTransaction.amount + lessonTransaction.amount;

    // Logs para debugging del cálculo de XP
    if (kDebugMode) {
      print('📊 [LessonTriviaWidget] Cálculo de XP:');
      print('   └─ Preguntas totales: ${_questions.length}');
      print('   └─ Respuestas correctas: $_correctAnswers');
      print(
        '   └─ XP Trivia: ${triviaTransaction.amount} (${_correctAnswers} × 5 + ${_correctAnswers == _questions.length ? 20 : 0} bonus)',
      );
      print('   └─ XP Lección: ${lessonTransaction.amount}');
      print('   └─ XP Total mostrado: $_totalXP');
      print(
        '   └─ Nota: El registro rápido (10 XP) se agrega por separado cuando se hace el registro',
      );
    }

    // Obtener el bloc y agregar XP
    final gamificationBloc = context.read<GamificationBloc>();

    try {
      // Agregar XP de trivia al bloc
      gamificationBloc.add(AddXP(triviaTransaction));

      // Esperar un poco para que se procese
      await Future.delayed(const Duration(milliseconds: 100));

      // Agregar XP de lección al bloc
      gamificationBloc.add(AddXP(lessonTransaction));

      // Recargar el perfil para actualizar la UI
      await Future.delayed(const Duration(milliseconds: 200));
      gamificationBloc.add(LoadGamificationProfile(widget.userId));

      // Detectar logros nuevos después de completar la lección
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        final gamificationRepository = getIt<GamificationRepository>();
        final gamificationService = GamificationService(
          repository: gamificationRepository,
        );
        final userStatisticsService = getIt<UserStatisticsService>();
        final userStats = await userStatisticsService.getUserStatistics(
          widget.userId,
        );

        final achievements = await gamificationService
            .detectAndUnlockAchievements(
              userId: widget.userId,
              totalLactationRecords: userStats.totalLactationRecords,
              completeLactationRecords: userStats.completeLactationRecords,
              totalLessonsCompleted: userStats.totalLessonsCompleted,
              babyWeightRecords: userStats.babyWeightRecords,
              hasNocturnalRecord: userStats.hasNocturnalRecord,
              dailyRecordsToday: userStats.dailyRecordsToday,
              babySleepRecords: userStats.babySleepRecords,
              perfectTrivias: userStats.perfectTrivias,
              nocturnalRecordsCount: userStats.nocturnalRecordsCount,
              daysUsingApp: userStats.daysUsingApp,
            );

        // Mostrar diálogo si hay logros nuevos
        if (achievements.isRight()) {
          final newAchievements = achievements.getOrElse(() => []);
          if (newAchievements.isNotEmpty && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && context.mounted) {
                // Mostrar logros uno a la vez usando el servicio de cola
                final achievementQueueService =
                    getIt<AchievementQueueService>();
                achievementQueueService.queueAchievements(
                  context,
                  newAchievements,
                );
              }
            });
          }
        }
      } catch (e) {
        // Ignorar errores en la detección de logros para no interrumpir el flujo
        if (kDebugMode) {
          print('Error detectando logros después de lección: $e');
        }
      }

      // Vibración y sonido de éxito usando los servicios mejorados
      final vibrationService = getIt<VibrationService>();
      final soundService = getIt<SoundService>();
      if (_correctAnswers == _questions.length) {
        // Trivia perfecta - vibración y sonido especiales
        vibrationService.vibrateOnTriviaCorrect();
        soundService.playTriviaCorrectSound();
      } else {
        vibrationService.vibrateOnSuccess();
        soundService.playSuccessSound(); // Sonido de éxito general
      }

      // NO mostrar la animación de XP aquí - se mostrará cuando el usuario presione "Continuar"
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'gamification.messages.errorSavingXP'.tr(
                namedArgs: {'error': e.toString()},
              ),
            ),
          ),
        );
      }
    }

    setState(() {
      _isCompleted = true;
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isCompleted) {
      return _buildResults();
    }

    return _buildQuestion();
  }

  Widget _buildQuestion() {
    final question = _questions[_currentQuestionIndex];
    final selectedIndex = _selectedAnswers[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de progreso
            Row(
              children: [
                Text(
                  '${'trivia.question'.tr()} ${_currentQuestionIndex + 1} ${'trivia.of'.tr()} ${_questions.length}',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                ...List.generate(
                  _questions.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index <= _currentQuestionIndex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pregunta
            FadeInDown(
              child: Text(
                question.question,
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Opciones
            ...List.generate(
              question.options.length,
              (index) => FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: _buildOptionButton(
                  question.options[index],
                  index,
                  selectedIndex == index,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botones de navegación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  TextButton(
                    onPressed: _previousQuestion,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'trivia.previous'.tr(),
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: selectedIndex == -1 ? null : _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.white.withValues(
                      alpha: 0.3,
                    ),
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 16,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    isLastQuestion ? 'trivia.finish'.tr() : 'trivia.next'.tr(),
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option, int index, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                width: isSelected ? 2.5 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.white : Colors.transparent,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: AppColors.primary,
                          size: 18,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final percentage = (_correctAnswers / _questions.length * 100).round();
    final isPerfect = _correctAnswers == _questions.length;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeInDown(
              child: Text(
                isPerfect
                    ? '🎉 ${'trivia.perfect'.tr()}'
                    : 'trivia.wellDone'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'trivia.youGot'.tr(
                  namedArgs: {
                    'correct': _correctAnswers.toString(),
                    'total': _questions.length.toString(),
                  },
                ),
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$percentage%',
                      style: GoogleFonts.quicksand(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'trivia.continue'.tr(),
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Mostrar XP ganado
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF03A696),
                      Color(0xFF26A69A),
                      Color(0xFF4DB6AC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+$_totalXP XP',
                          style: GoogleFonts.quicksand(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'trivia.xpEarned'.tr(),
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: ElevatedButton(
                onPressed: () async {
                  // Calcular porcentaje y determinar si mostrar estrellitas
                  final percentage = (_correctAnswers / _questions.length * 100)
                      .round();
                  final showStars = percentage >= 75;

                  // Cerrar el diálogo primero
                  Navigator.of(context).pop();

                  // Esperar un momento para que el diálogo se cierre completamente
                  await Future.delayed(const Duration(milliseconds: 300));

                  if (!mounted) {
                    widget.onComplete?.call();
                    return;
                  }

                  // Usar el contexto original que tiene acceso al Overlay
                  final animationContext = widget.originalContext;

                  if (animationContext != null && animationContext.mounted) {
                    // Verificar que el contexto aún sea válido
                    try {
                      // Intentar obtener el overlay para verificar que el contexto es válido
                      final overlay = Overlay.of(animationContext);
                      if (overlay.mounted) {
                        XPCelebrationAnimation.show(
                          animationContext,
                          _totalXP,
                          showStars: showStars,
                          onComplete: () {
                            widget.onComplete?.call();
                          },
                        );
                      } else {
                        widget.onComplete?.call();
                      }
                    } catch (e) {
                      widget.onComplete?.call();
                    }
                  } else {
                    widget.onComplete?.call();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Continuar',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

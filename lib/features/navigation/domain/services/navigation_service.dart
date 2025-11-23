import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../user/presentation/bloc/user_profile_bloc.dart' as user_bloc;
import '../../../lessons/presentation/pages/lesson_videos_page.dart';
import '../../../videos/presentation/pages/user_videos_page.dart';
import '../../../lactation/presentation/pages/lactation_record_page.dart';
import '../../../lactation/presentation/pages/lactation_flow_page.dart';

/// Servicio para manejar la lógica de navegación y estado del usuario
class NavigationService {
  /// Obtiene el estado postparto del usuario
  static bool getUserPostPartumStatus(user_bloc.UserProfileState state) {
    if (state is user_bloc.UserProfileLoaded) {
      return state.profile.isPostPartum;
    } else if (state is user_bloc.UserProfileUpdated) {
      return state.profile.isPostPartum;
    }
    return false;
  }

  /// Obtiene el nombre del usuario
  static String getUserName(user_bloc.UserProfileState state) {
    if (state is user_bloc.UserProfileLoaded) {
      return state.profile.username;
    } else if (state is user_bloc.UserProfileUpdated) {
      return state.profile.username;
    }
    return '';
  }

  /// Navega a la página de lecciones
  static void navigateToLessons(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LessonVideosPage(
          videos: [], // Se cargarán desde el servicio
        ),
      ),
    );
  }

  /// Navega a la página de videos del usuario
  static void navigateToUserVideos(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const UserVideosPage()));
  }

  /// Navega al nuevo flujo de lactancia inteligente
  static void navigateToCalendar(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<bool>(
            builder: (context) => const LactationFlowPage(),
          ),
        )
        .then((result) {
          // Si el usuario completó el registro exitosamente, refrescar datos
          if (result == true) {
            // Aquí podrías agregar lógica para refrescar datos si es necesario
            print('✅ Registro de lactancia completado exitosamente');
          }
        });
  }

  /// Navega al nuevo flujo de lactancia inteligente con fecha específica
  static void navigateToLactationFlow(
    BuildContext context, {
    DateTime? selectedDate,
  }) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<bool>(
            builder: (context) => LactationFlowPage(selectedDate: selectedDate),
          ),
        )
        .then((result) {
          if (result == true) {
            print('✅ Registro de lactancia completado exitosamente');
          }
        });
  }

  /// Navega al registro tradicional de lactancia (para casos especiales)
  static void navigateToTraditionalRecord(
    BuildContext context, {
    DateTime? selectedDate,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            LactationRecordPage(selectedDate: selectedDate ?? DateTime.now()),
      ),
    );
  }

  /// Navega a la página de tips
  static void navigateToTips(BuildContext context) {
    Navigator.pushNamed(context, '/tips');
  }
}

/// Servicio para manejar la lógica del contador de cuenta regresiva
class CountdownService {
  /// Calcula los días restantes hasta la fecha esperada
  static int calculateDaysLeft(String expectedBirthDate) {
    try {
      final birthDate = DateTime.parse(expectedBirthDate);
      final now = DateTime.now();
      final difference = birthDate.difference(now);
      return difference.inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Calcula el progreso del embarazo
  static double calculatePregnancyProgress(String expectedBirthDate) {
    try {
      final birthDate = DateTime.parse(expectedBirthDate);
      final now = DateTime.now();
      final totalDays = 280; // 40 semanas promedio
      final daysPassed = now
          .difference(birthDate.subtract(Duration(days: totalDays)))
          .inDays;
      return (daysPassed / totalDays).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  /// Obtiene un mensaje motivacional basado en los días restantes
  static String getMotivationalMessage(String expectedBirthDate) {
    try {
      final birthDate = DateTime.parse(expectedBirthDate);
      final now = DateTime.now();
      final difference = birthDate.difference(now);
      final daysLeft = difference.inDays;

      if (daysLeft < 0) {
        return 'countdown.newAdventure'.tr();
      } else if (daysLeft == 0) {
        return 'countdown.greatDayArrived'.tr();
      } else if (daysLeft <= 7) {
        return 'countdown.verySoon'.tr();
      } else if (daysLeft <= 30) {
        return 'countdown.oneMonthLeft'.tr();
      } else {
        return 'countdown.motivationalMessage'.tr();
      }
    } catch (e) {
      return 'countdown.stayStrong'.tr();
    }
  }
}

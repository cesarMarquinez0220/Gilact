import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/user/presentation/bloc/user_profile_bloc.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/lessons/presentation/pages/lessons_page.dart';
import 'features/lessons/presentation/bloc/lesson_bloc.dart';
import 'features/lessons/presentation/providers/lecciones_provider.dart';
import 'features/lessons/presentation/providers/video_images_provider.dart';
import 'features/tips/presentation/pages/tips_page.dart';
import 'features/tips/presentation/bloc/tip_bloc.dart';
import 'features/navigation/presentation/pages/main_navigation_page.dart';
import 'features/auth/presentation/pages/registration_page.dart';
import 'features/auth/presentation/pages/welcome_screen.dart';
import 'features/videos/presentation/pages/user_videos_page.dart';

//flutter_native_splash:
// color: "#03A696"
// image: "assets/images/splash.png"
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Firebase de forma segura
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (kDebugMode) {
      print('✅ Firebase inicializado correctamente');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error al inicializar Firebase: $e');
    }
  }

  // Comentamos temporalmente los servicios que pueden causar problemas
  // final performanceService = PerformanceService();
  // final securityService = SecurityAnalysisService();

  // await performanceService.measureAppInitialization();
  // final securityReport = await securityService.analyzeSecurity();

  await updateLastOpened();

  // Configurar inyección de dependencias
  await configureDependencies();

  runApp(const MyApp());
}

Future<void> updateLastOpened() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  DateTime now = DateTime.now();
  await prefs.setString('last_opened', now.toString());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeccionesProvider()),
        ChangeNotifierProvider(create: (_) => VideoImagesProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => getIt<AuthBloc>()),
          BlocProvider<UserProfileBloc>(
            create: (context) => getIt<UserProfileBloc>(),
          ),
          BlocProvider<TipBloc>(create: (context) => getIt<TipBloc>()),
          BlocProvider<LessonBloc>(create: (context) => getIt<LessonBloc>()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          home: const LoginPage(),
          routes: {
            '/welcome': (context) => const WelcomeScreen(),
            '/home': (context) => const MainNavigationPage(),
            '/register': (context) => const RegistrationPage(),
            '/configuracion': (context) => const SettingsPage(),
            '/perfil': (context) => const MainNavigationPage(),
            '/lecciones': (context) => const LessonsPage(),
            '/secciones': (context) => const MainNavigationPage(),
            '/historial': (context) => const UserVideosPage(),
            '/edicion': (context) => const MainNavigationPage(),
            '/tips': (context) => const TipsPage(),
            '/Onboar_Info': (context) => const MainNavigationPage(),
          },
        ),
      ),
    );
  }
}

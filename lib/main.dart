import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'pages/Configuracion_Estadistica/configuracion.dart';
import 'pages/PerfilContinuacion/perfilnuevo.dart';
import 'pages/onboard_info.dart';
import 'pages/paginadepruebas.dart';
import 'pages/proveedor_boleanos/notifire.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_performance/firebase_performance.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'pages/PerfilContinuacion/edicionperfil.dart';
import 'pages/UsersVideos/user_videos.dart';
import 'pages/login.dart';
import 'pages/tips.dart';
import 'package:provider/provider.dart';
// import 'services/performance_service.dart';
// import 'services/security_analysis_service.dart';
// import 'pages/performance_analysis_page.dart';
import 'firebase_options.dart';
//import 'package:flutter_native_splash/flutter_native_splash.dart';

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeccionesProvider()),
        ChangeNotifierProvider(create: (_) => Avancesprovider()),
      ],
      child: const MyApp(),
    ),
  );
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const LoginScreen(),
      //home: SeccionVideos(),
      routes: {
        '/configuracion': (context) => ConfiguracionScreen(),
        '/perfil': (context) => const Perfilnuevo(),
        '/lecciones': (context) => const lecciones(videos: []),
        '/secciones': (context) => const User_videos(videos: []),
        '/edicion': (context) => const editProfile(),
        '/tips': (context) => const Tips(),
        '/Onboar_Info': (context) => Onboar_Info(),
        // '/performance': (context) => const PerformanceAnalysisPage(),
      },
    );
  }
}

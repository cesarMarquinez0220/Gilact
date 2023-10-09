import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_login/pages/LecionesVideos/secionvideos.dart';
import 'package:flutter_login/pages/PerfilContinuacion/Progreso/Lecciones.dart';
import 'package:flutter_login/pages/UsersVideos/user_videos.dart';
import 'package:flutter_login/pages/login.dart';
import 'firebase_options.dart';
//import 'package:flutter_native_splash/flutter_native_splash.dart';

//flutter_native_splash:
// color: "#03A696"
// image: "assets/images/splash.png"
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  //FlutterNativeSplash.remove();
  //FlutterNativeSplash.preserve(widgetsBinding: ); falta por mencionar
  //preuba
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: User_videos(),
      routes: {
        '/lecciones': (context) => lecciones(),
        '/secciones': (context) => SeccionVideos(),
        // Otras rutas aquí...
      },
    );
  }
}
// 'https://drive.google.com/uc?export=view&id=1Mcvaa8TLuZoNQ0WHF0W3YphcoixoMdes', 

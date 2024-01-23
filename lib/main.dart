import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_login/pages/ComingSoonPage.dart';
import 'package:flutter_login/pages/Configuracion_Estadistica/configuracion.dart';
import 'package:flutter_login/pages/PerfilContinuacion/Progreso/Lecciones.dart';
import 'package:flutter_login/pages/PerfilContinuacion/edicionperfil.dart';
import 'package:flutter_login/pages/paginadepruebas.dart';
import 'package:flutter_login/pages/tips.dart';
import 'package:provider/provider.dart';
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
  runApp(
    MultiProvider(
      providers: [
        // Otros providers...
        ChangeNotifierProvider(create: (_) => TemaProvider()),
        ChangeNotifierProvider(create: (_) => NotificacionesProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home:Prueba(),
      //home: SeccionVideos(),
      routes: {
        '/lecciones': (context) => lecciones(),
        //'/secciones': (context) => SeccionVideos(),
        '/comingSoon': (context) => ComingSoonPage(),
        '/edicion': (context) => editProfile(),
        '/tips': (context) => Tips(),
        // Otras rutas aquí...
      },
    );
  }
}
// 'https://drive.google.com/uc?export=view&id=1Mcvaa8TLuZoNQ0WHF0W3YphcoixoMdes', 
        //'https://www.googleapis.com/drive/v3/files/1Mcvaa8TLuZoNQ0WHF0W3YphcoixoMdes?alt=media', // Reemplaza con la URL del video de Google Drive
        //'https://drive.google.com/file/d/1N1XZlXSJKRDouSeqrAjEzUkijzlGzhB4/view',

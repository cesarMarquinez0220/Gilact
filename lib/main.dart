import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/paginadepruebas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_login/pages/ComingSoonPage.dart';
import 'package:flutter_login/pages/Configuracion_Estadistica/configuracion.dart';
import 'package:flutter_login/pages/Configuracion_Estadistica/services.dart';
import 'package:flutter_login/pages/PerfilContinuacion/Progreso/Lecciones.dart';
import 'package:flutter_login/pages/PerfilContinuacion/edicionperfil.dart';
import 'package:flutter_login/pages/UsersVideos/user_videos.dart';
import 'package:flutter_login/pages/enlaces%20de%20videos/notifire.dart';
import 'package:flutter_login/pages/login.dart';
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
  await initNotifications();
  await updateLastOpened();

  // Configura el plugin background_fetch
  await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 2, // Ejecutar cada 2 minutos
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ),
     notificacionPrueba,
      );

  // TODO:1
  // MARK: ///// CONFIGURACION DE FIRESTORE //////////
  // final FirebaseFirestore database = FirebaseFirestore.instance;
  // final CollectionReference videosCollections = database.collection('videos');
  // final QuerySnapshot videoSnapshot = await videosCollections.get();
  // final List<QueryDocumentSnapshot> documents = videoSnapshot.docs;
  // documents.forEach((doc) {
  //   print('Document ID: ${doc.id}');
  //   Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //   data.forEach((key, value) {
  //     print('$key: $value');
  //   });
  // });

  runApp(
    MultiProvider(
      providers: [
        // Otros providers...
        ChangeNotifierProvider(create: (_) => LeccionesProvider()),
        ChangeNotifierProvider(create: (_) => TemaProvider()),
        ChangeNotifierProvider(create: (_) => NotificacionesProvider()),
      ],
      child: MyApp(),
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
    final changeTheme = Provider.of<TemaProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: changeTheme.temaOscuro?ThemeData.dark():ThemeData.light(),
      home: LoginScreen(),
      //home: SeccionVideos(),
      routes: {
        '/lecciones': (context) => lecciones(videos: []),
        '/secciones': (context) => User_videos(),
        '/edicion': (context) => editProfile(),
        '/tips': (context) => Tips(),
     
      },
    );
  }
}

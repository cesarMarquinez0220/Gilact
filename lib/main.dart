import 'package:flutter/material.dart';
import 'package:flutter_login/pages/Configuracion_Estadistica/configuracion.dart';
import 'package:flutter_login/pages/PerfilContinuacion/perfilnuevo.dart';
import 'package:flutter_login/pages/onboard_info.dart';
import 'package:flutter_login/pages/paginadepruebas.dart';
import 'package:flutter_login/pages/proveedor_boleanos/notifire.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_login/pages/PerfilContinuacion/edicionperfil.dart';
import 'package:flutter_login/pages/UsersVideos/user_videos.dart';
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

  await updateLastOpened();

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
      },
    );
  }
}

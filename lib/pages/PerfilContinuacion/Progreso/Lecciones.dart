// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_login/pages/LecionesVideos/reproductorsesiones.dart';
// import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
// import 'package:flutter_login/pages/enlaces%20de%20videos/notifire.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:flutter_login/pages/registro_lactancia.dart';
// import 'package:provider/provider.dart';

// class lecciones extends StatefulWidget {
//   const lecciones({Key? key});

//   @override
//   State<lecciones> createState() => _leccionesState();
// }

// class _leccionesState extends State<lecciones> {
//   Key leccionesKey = UniqueKey();
//   bool _showLeccionCompletada = false;
//   int _selectedIndex = 0;
//   Timer? _timer;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late String usuario;
//   int lastCompletedLesson = 0; // Número de la última lección completada
  

//   @override
//   void initState() {
//     super.initState();
//     usuario = UserDataStorage.getUserName();
//     // _getUltimaLeccionCompletada();
//     _timer = Timer.periodic(Duration(minutes: 2), (timer) {
//       setState(() {
//         _getUltimaLeccionCompletada(); // Aquí puedes realizar cualquier acción que desees al recargar cada 8 segundos
//       });
//     });
//   }

//   @override
//   void dispose() {
//     // Asegurarse de cancelar el temporizador al destruir el widget
//     _timer?.cancel();
//     super.dispose();
//   }

//   Future<void> _getUltimaLeccionCompletada() async {
//     try {
//       final usuarioDocRef = await _getUsuarioDocumento(usuario);
//       if (usuarioDocRef != null) {
//         final videosCollectionRef = usuarioDocRef.collection('videos');
//         final videosCollection =
//             await videosCollectionRef.orderBy(FieldPath.documentId).get();

//         if (videosCollection.docs.isNotEmpty) {
//           // Filtrar los documentos con contadorVisualizaciones distinto de 0
//           final videosConContador = videosCollection.docs
//               .where(
//                   (videoDoc) => (videoDoc['contadorVisualizaciones'] ?? 0) > 0)
//               .toList();

//           if (videosConContador.isNotEmpty) {
//             // Ordenar los documentos de menor a mayor (por número de lección)
//             videosConContador
//                 .sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

//             // Obtener el último documento (mayor número de lección)
//             final lastLessonDoc = videosConContador.last;

//             // Obtener el número de lección
//             lastCompletedLesson = int.parse(lastLessonDoc.id);
//             print('Ultima leccion $lastCompletedLesson');
//           }
//         }
//       }
//       print('Ultima leccion $lastCompletedLesson');
//     } catch (error) {
//       print('Error al obtener la última lección completada: $error');
//     }
//   }

//   Future<DocumentReference?> _getUsuarioDocumento(String usuario) async {
//     final usersQuery = await _firestore
//         .collection('Users')
//         .where('usuario', isEqualTo: usuario)
//         .limit(1)
//         .get();

//     return usersQuery.docs.isNotEmpty ? usersQuery.docs[0].reference : null;
//   }

//   Future<void> _navigateToReproductorVideo(int videoId, int duracionId) async {
//     try {
//       final usuarioDocRef = await _getUsuarioDocumento(usuario);

//       if (usuarioDocRef != null) {
//         // Verificar la existencia de la colección 'videos'
//         final videosCollectionRef = usuarioDocRef.collection('videos');
//         final videosCollection = await videosCollectionRef.get();

//         if (videosCollection.docs.isEmpty) {
//           // Si la colección 'videos' no existe, permite la navegación a la primera lección
//           _navigateToReproductorVideoHelper(videoId, duracionId);
//         } else {
//           // Obtener el último documento en la colección 'videos'
//           final ultimoVideoDocRef = videosCollection.docs.last.reference;

//           final ultimoVideoDoc = await ultimoVideoDocRef.get();

//           if (ultimoVideoDoc.exists &&
//               (ultimoVideoDoc['contadorVisualizaciones'] ?? 0) > 0) {
//             // Si el último documento existe y el contadorVisualizaciones es mayor que 0,
//             // permite la navegación al siguiente video
//             _navigateToReproductorVideoHelper(videoId, duracionId);
//           } else {
//             // Mostrar un mensaje indicando que el usuario debe ver la lección anterior
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: const Text("Lección no disponible"),
//                   content: const Text(
//                     "Debes completar la lección anterior antes de acceder a esta o el video no ha sido visto.",
//                   ),
//                   actions: <Widget>[
//                     TextButton(
//                       child: const Text("Cerrar"),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ],
//                 );
//               },
//             );
//           }
//         }
//       } else {
//         print('No se encontró un usuario con el nombre: $usuario');
//       }
//     } catch (error) {
//       print('Error al verificar la información del video en Firestore: $error');
//     }
//   }

//   Future<void> _navigateToReproductorVideoHelper(
//       int videoId, int duracionId) async {
//     final result = await Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation1, animation2) => ReproductorVideo(
//           videoId: videoId,
//           duracionId: duracionId,
//         ),
//         transitionsBuilder: (context, animation1, animation2, child) {
//           const begin = Offset(1.0, 0.0);
//           const end = Offset.zero;
//           const curve = Curves.easeInOutCubic;

//           var tween =
//               Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

//           var offsetAnimation = animation1.drive(tween);

//           return SlideTransition(
//             position: offsetAnimation,
//             child: child,
//           );
//         },
//       ),
//     );

//     // Actualizar la última lección completada después de regresar del reproductor
//     await _getUltimaLeccionCompletada();

//     // Mostrar la animación de LeccionCompletada solo si se completó la lección
//     if (result == true) {
//       setState(() {
//         _showLeccionCompletada = true;
//       });
//     }
//   }

//   // Future<void> _navigateToReproductorVideoHelper(
//   //     int videoId, int duracionId) async {
//   //   final result = await Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => ReproductorVideo(
//   //         videoId: videoId,
//   //         duracionId: duracionId,
//   //       ),
//   //     ),
//   //   );
//   //   print(
//   //       'Se regresó del reproductor y se actualizó la interfaz, PARTE DEL AWAIT');

//   // Por ejemplo, puedes llamar a _getUltimaLeccionCompletada nuevamente si es necesario
//   //   await _getUltimaLeccionCompletada();

//   //   // Finalmente, si necesitas reconstruir la interfaz, puedes llamar a setState
//   //   setState(() {
//   //     print('PARTE DEL SETSTATE');

//   //   });

//   //   if (result == true) {
//   //     await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => LeccionCompletada(),
//   //       ),
//   //     );
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<void>(
//           future: _getUltimaLeccionCompletada(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               // Muestra un indicador de carga mientras se obtiene la información
//               return Scaffold(
//                 body: Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topRight,
//                       end: Alignment.centerLeft,
//                       colors: [
//                         Color(0xffD9ACF5),
//                         Color.fromARGB(255, 122, 231, 211),
//                         //Color(0xffF2F2F2),
//                       ],
//                     ),
//                   ),
//                   child: Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 ),
//               );
//             } else if (snapshot.hasError) {
//               // Muestra un mensaje de error si ocurre un error
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else {
//               // Muestra la interfaz de usuario con la información cargada
//               return Scaffold(
//                 body: Stack(children: [
//                   Container(
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topRight,
//                         end: Alignment.centerLeft,
//                         colors: [
//                           Color(0xffD9ACF5),
//                           Color.fromARGB(255, 122, 231, 211),
//                           //Color(0xffF2F2F2),
//                         ],
//                       ),
//                     ),
//                     child: SafeArea(
//                       child: SingleChildScrollView(
//                         child: Column(
//                           children: <Widget>[
//                             _buildAppBar(),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 16.0),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   _Title1('Lección 1'),
//                                   GestureDetector(
//                                     onTap: () {
//                                       // Mostrar un mensaje cuando se presione
//                                       showDialog(
//                                         context: context,
//                                         builder: (BuildContext context) {
//                                           return AlertDialog(
//                                             title: const Text(
//                                                 "Sección de Lecciones de Videos"),
//                                             content: const Text(
//                                                 "En esta sección se encuentran las lecciones de videos a ver."),
//                                             actions: <Widget>[
//                                               TextButton(
//                                                 child: const Text("Cerrar"),
//                                                 onPressed: () {
//                                                   Navigator.of(context)
//                                                       .pop(); // Cerrar el cuadro de diálogo
//                                                 },
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       );
//                                     },
//                                     child: Container(
//                                       width: 40.0,
//                                       height: 40.0,
//                                       decoration: const BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color:
//                                             Color.fromARGB(255, 255, 255, 255),
//                                       ),
//                                       child: const Icon(
//                                         Icons.help,
//                                         size: 24,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             _Subtitle1('Lactancia materna y sus beneficios'),
//                             _PercentIndicator1(
//                               69.0,
//                               'Homevideo.png',
//                               Colors.blue,
//                               1,
//                               1,
//                               leccionId: 1,
//                               isEnabled: true,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'Writingvideo.png',
//                               Colors.blue,
//                               2,
//                               2,
//                               leccionId: 2,
//                               isEnabled: lastCompletedLesson >= 1,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'working.png',
//                               Colors.blue,
//                               3,
//                               3,
//                               leccionId: 3,
//                               isEnabled: lastCompletedLesson >= 2,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _Title1('Lección 2'),
//                             _Subtitle1(
//                                 'Calostro, leche de transisicon y leche madura'),
//                             _PercentIndicator1(
//                               69.0,
//                               'Softvideo.png',
//                               Colors.blue,
//                               4,
//                               4,
//                               leccionId: 4,
//                               isEnabled: lastCompletedLesson >= 3,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'bebemujer1.png',
//                               Colors.blue,
//                               5,
//                               5,
//                               leccionId: 5,
//                               isEnabled: lastCompletedLesson >= 4,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'bebevientre.png',
//                               Colors.blue,
//                               6,
//                               6,
//                               leccionId: 6,
//                               isEnabled: lastCompletedLesson >= 5,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,),),
                                

//                             _Title1('Lección 4'),
//                             _Subtitle1(
//                                 'Composición Nutricional de la Leche Materna'),
//                             _PercentIndicator1(
//                               69.0,
//                               'mujereshablando.png',
//                               Colors.blue,
//                               7,
//                               7,
//                               leccionId: 7,
//                               isEnabled: lastCompletedLesson >= 6,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _Title1('Lección 5'),
//                             _Subtitle1(
//                                 '¿Cómo saber que el bebé se alimentó lo suficiente?'),
//                             _PercentIndicator1(
//                               69.0,
//                               'food2.png',
//                               Colors.blue,
//                               8,
//                               8,
//                               leccionId: 8,
//                               isEnabled: lastCompletedLesson >= 7,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'food3.png',
//                               Colors.blue,
//                               9,
//                               9,
//                               leccionId: 9,
//                               isEnabled: lastCompletedLesson >= 8,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _Title1('Lección 6'),
//                             _Subtitle1('Hitos de peso a vigilar'),
//                             _PercentIndicator1(
//                               69.0,
//                               'health1.png',
//                               Colors.blue,
//                               10,
//                               10,
//                               leccionId: 10,
//                               isEnabled: lastCompletedLesson >= 9,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'salud.png',
//                               Colors.blue,
//                               11,
//                               11,
//                               leccionId: 11,
//                               isEnabled: lastCompletedLesson >= 10,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'food1.png',
//                               Colors.blue,
//                               12,
//                               12,
//                               leccionId: 12,
//                               isEnabled: lastCompletedLesson >= 11,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _Title1('Lección 7'),
//                             _Subtitle1(
//                                 'Higiene de manos y técnicas de lactancia materna'),
//                             _PercentIndicator1(
//                               69.0,
//                               'health3.png',
//                               Colors.blue,
//                               13,
//                               13,
//                               leccionId: 13,
//                               isEnabled: lastCompletedLesson >= 12,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'health4.png',
//                               Colors.blue,
//                               14,
//                               14,
//                               leccionId: 14,
//                               isEnabled: lastCompletedLesson >= 13,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _Title1('Lección 8'),
//                             _Subtitle1(
//                                 'Medicamentos durante la lactancia materna'),
//                             _PercentIndicator1(
//                               69.0,
//                               'health2.png',
//                               Colors.yellow,
//                               15,
//                               15,
//                               leccionId: 15,
//                               isEnabled: lastCompletedLesson >= 14,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'health5.png',
//                               Colors.blue,
//                               16,
//                               16,
//                               leccionId: 16,
//                               isEnabled: lastCompletedLesson >= 15,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _Title1('Lección 9'),
//                             _Subtitle1(
//                                 'Signos o Complicaciones en la Lactancia'),
//                             _PercentIndicator1(
//                               69.0,
//                               'problema1.png',
//                               Colors.blue,
//                               17,
//                               17,
//                               leccionId: 17,
//                               isEnabled: lastCompletedLesson >= 16,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'problema2.png',
//                               const Color.fromARGB(255, 145, 243, 33),
//                               18,
//                               18,
//                               leccionId: 18,
//                               isEnabled: lastCompletedLesson >= 17,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'problema3.png',
//                               Colors.blue,
//                               19,
//                               19,
//                               leccionId: 19,
//                               isEnabled: lastCompletedLesson >= 18,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'problema4.png',
//                               Colors.blue,
//                               20,
//                               20,
//                               leccionId: 20,
//                               isEnabled: lastCompletedLesson >= 19,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'problema5.png',
//                               Colors.blue,
//                               21,
//                               21,
//                               leccionId: 21,
//                               isEnabled: lastCompletedLesson >= 20,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _Title1('Lección 10'),
//                             _Subtitle1(
//                                 'Masajes al seno antes de iniciar la lactancia'),
//                             _PercentIndicator1(
//                               69.0,
//                               'cuidadomujer.png',
//                               Colors.blue,
//                               22,
//                               22,
//                               leccionId: 22,
//                               isEnabled: lastCompletedLesson >= 21,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _Title1('Lección 11'),
//                             _Subtitle1(
//                                 'Mi banco de leche en casa y su preservacion'),
//                             _PercentIndicator1(
//                               69.0,
//                               'banco1.png',
//                               Colors.blue,
//                               23,
//                               23,
//                               leccionId: 23,
//                               isEnabled: lastCompletedLesson >= 22,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'banco2.png',
//                               Colors.blue,
//                               24,
//                               24,
//                               leccionId: 24,
//                               isEnabled: lastCompletedLesson >= 23,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'banco3.png',
//                               Colors.blue,
//                               25,
//                               25,
//                               leccionId: 25,
//                               isEnabled: lastCompletedLesson >= 24,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _Title1('Lección 12'),
//                             _Subtitle1(
//                                 'Leyes en Panamá que apoyan la lactancia materna'),
//                             _PercentIndicator1(
//                               69.0,
//                               'ley1.png',
//                               Colors.blue,
//                               26,
//                               26,
//                               leccionId: 26,
//                               isEnabled: lastCompletedLesson >= 25,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _PercentIndicator1(
//                               69.0,
//                               'ley2.png',
//                               Colors.blue,
//                               27,
//                               27,
//                               leccionId: 27,
//                               isEnabled: lastCompletedLesson >= 26,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _Title1('Lección 13'),
//                             _Subtitle1(
//                                 'Diferencias entre la leche materna y la leche de vaca'),
//                             _PercentIndicator1(
//                               69.0,
//                               'milk1.png',
//                               Colors.blue,
//                               28,
//                               28,
//                               leccionId: 28,
//                               isEnabled: lastCompletedLesson >= 27,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.1,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _Title1('Lección 14'),
//                             _Subtitle1('Mitos de la lactancia materna'),
//                             _PercentIndicator1(
//                               69.0,
//                               'mitos.png',
//                               Colors.blue,
//                               29,
//                               29,
//                               leccionId: 29,
//                               isEnabled: lastCompletedLesson >= 28,
//                               customPadding: EdgeInsets.only(
//                                 top: MediaQuery.of(context).size.height * 0.02,
//                                 right: MediaQuery.of(context).size.width * 0.55,
//                                 bottom:
//                                     MediaQuery.of(context).size.height * 0.01,
//                               ),
//                             ),
//                             _buildElevatedButton(),
                            
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                 ]),
//               );
//             }
//           }),
//     );
//   }               
            

//   Widget _buildAppBar() {
//     return AppBar(
//       forceMaterialTransparency: true,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.black),
//         onPressed: () => Navigator.of(context).pop(),
//       ),
//     );
//   }

//   // ignore: non_constant_identifier_names
//   Widget _Title1(String title) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Padding(
//         padding: const EdgeInsets.only(left: 10.0),
//         child: Text(
//           title,
//           style: GoogleFonts.quicksand(
//             color: Colors.white,
//             fontSize: 28.0,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   // ignore: non_constant_identifier_names
//   Widget _Subtitle1(String subtitle) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Padding(
//         padding: const EdgeInsets.only(left: 16.0),
//         child: Text(
//           subtitle,
//           style: GoogleFonts.quicksand(
//             color: Colors.white,
//             fontSize: 18.0,
//           ),
//         ),
//       ),
//     );
//   }

//   //circulo indicador de la derecha
//   // ignore: non_constant_identifier_names
//   Widget _PercentIndicator1(
//     double radius,
//     String imageName,
//     Color color,
//     int videoId,
//     int duracionId, {
//     required int leccionId,
//     required bool isEnabled,
//     required EdgeInsets customPadding,
//   }) {
//     return GestureDetector(
//       onTap: () async {
//         if (isEnabled) {
//           // Aquí debes verificar si la lección actual es la siguiente a la última completada
//           if (leccionId == lastCompletedLesson + 1) {
//             await _navigateToReproductorVideo(videoId, duracionId);
//           } else {
//             // Muestra un mensaje indicando que el usuario debe completar la lección anterior
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: const Text("Lección no disponible"),
//                   content: const Text(
//                     "Debes completar la lección anterior antes de acceder a esta.",
//                   ),
//                   actions: <Widget>[
//                     TextButton(
//                       child: const Text("Cerrar"),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ],
//                 );
//               },
//             );
//           }
//         } else {
//           // Muestra un mensaje indicando por qué la lección no está disponible
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Text("Lección no disponible"),
//                 content: const Text(
//                   "Debes completar esta lección antes de acceder a la siguiente.",
//                 ),
//                 actions: <Widget>[
//                   TextButton(
//                     child: const Text("Cerrar"),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               );
//             },
//           );
//         }
//       },
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: Padding(
//           padding: customPadding,
//           child: CircularPercentIndicator(
//             radius: radius,
//             lineWidth: 9.0,
//             percent: isEnabled ? 1.0 : 0.0,
//             center: _buildImageContainer(imageName),
//             circularStrokeCap: CircularStrokeCap.butt,
//             progressColor: color,
//             backgroundColor: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildImageContainer(String imageName) {
//     return Center(
//       child: Container(
//         width: 120.0,
//         height: 120.0,
//         decoration: const BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white,
//         ),
//         child: Center(
//           child:
//               Image.asset('assets/images/$imageName', height: 100, width: 100),
//         ),
//       ),
//     );
//   }

//   Widget _buildElevatedButton() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Padding(
//         padding: const EdgeInsets.only(left: 20.0, bottom: 10),
//         child: SizedBox(
//           width: 210,
//           child: ElevatedButton(
//             onPressed: () async {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const RegistroLactancia(),
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color.fromARGB(255, 199, 135, 240),
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               shadowColor: Colors.black.withOpacity(0.5),
//               elevation: 5,
//             ),
//             child: Text(
//               'Registro Lactancia',
//               style: GoogleFonts.quicksand(
//                   fontSize: 18,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

// }

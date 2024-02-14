// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_login/pages/LecionesVideos/reproductorsesiones.dart';
// import 'package:flutter_login/pages/enlaces%20de%20videos/notifire.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:provider/provider.dart';

// class lecciones extends StatefulWidget {
//   const lecciones({Key? key});

//   @override
//   State<lecciones> createState() => _leccionesState();
// }

// class _leccionesState extends State<lecciones> {
//   Key leccionesKey = UniqueKey();
//   int lastCompletedLesson = 0; // Número de la última lección completada

//   Future<void> _navigateToReproductorVideo(int videoId, int duracionId) async {
//     _navigateToReproductorVideoHelper(videoId, duracionId);
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

//     // Verifica si se completó una lección y actualiza lastCompletedLesson
//     if (result != null && result is int) {
//       setState(() {
//         lastCompletedLesson = result;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.centerLeft,
//                 colors: [
//                   Color(0xffD9ACF5),
//                   Color.fromARGB(255, 122, 231, 211),
//                   //Color(0xffF2F2F2),
//                 ],
//               ),
//             ),
//             child: SafeArea(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: <Widget>[
//                     _buildAppBar(),
//                     _buildLessons(),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           BackButton(
//             onPressed: () => Navigator.pop(context, false),
//           ),
//           GestureDetector(
//             onTap: () {
//               // Mostrar un mensaje cuando se presione
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: const Text("Sección de Lecciones de Videos"),
//                     content: const Text(
//                         "En esta sección se encuentran las lecciones de videos a ver."),
//                     actions: <Widget>[
//                       TextButton(
//                         child: const Text("Cerrar"),
//                         onPressed: () {
//                           Navigator.of(context)
//                               .pop(); // Cerrar el cuadro de diálogo
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//             child: Container(
//               width: 40.0,
//               height: 40.0,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color.fromARGB(255, 255, 255, 255),
//               ),
//               child: const Icon(
//                 Icons.help,
//                 size: 24,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLessons() {
//     return Column(
//       children: List.generate(
//         29,
//         (index) => Column(
//           children: [
//             _Title('Lección ${index + 1}'),
//             _Subtitle(_getSubtitleForLesson(index + 1)),
//             _PercentIndicator(
//               69.0,
//               'image_${index + 1}.png',
//               Colors.blue,
//               index + 1,
//               index + 1,
//               leccionId: index + 1,
//             ),
//           ],
//         ),
//       ),
//     );
//   }



//   String _getSubtitleForLesson(int lessonNumber) {
//     // Aquí puedes definir los subtítulos según el número de lección
//     switch (lessonNumber) {
//       case 1:
//         return 'Lactancia materna y sus beneficios';
//       case 2:
//         return 'Calostro, leche de transición y leche madura';
//       case 3:
//         return "Cosas en tomar en cuenta al momento de amamantar";
//       case 4:
//         return "Composición Nutricional de la Leche Materna";
//       case 5:
//         return '¿Cómo saber que el bebé se alimentó lo suficiente?';
//       case 6:
//         return "Hitos de peso a vigilar'";
//       case 7:
//         return "Higiene de manos y técnicas de lactancia materna";
//       case 8:
//         return 'Medicamentos durante la lactancia materna';
//       case 9:
//         return 'Signos o Complicaciones en la Lactancia';
//       case 10:
//         return 'Masajes al seno antes de iniciar la lactancia';
//       case 11:
//         return 'Mi banco de leche en casa y su preservacion';
//       case 12:
//         return 'Leyes en Panamá que apoyan la lactancia materna';
//       case 13:
//         return 'Diferencias entre la leche materna y la leche de vaca';
//       case 14:
//         return 'Mitos de la lactancia materna';

//       default:
//         return '';
//     }
//   }

//   // ignore: non_constant_identifier_names
//   Widget _Title(String title) {
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
//   Widget _Subtitle(String subtitle) {
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
//   Widget _PercentIndicator(
//     double radius,
//     String imageName,
//     Color color,
//     int videoId,
//     int duracionId, {
//     required int leccionId,
//   }) {
//     return Consumer<LeccionesProvider>(
//         builder: (context, leccionesProvider, child) {
//       return GestureDetector(
//         onTap: () {
//           final isEnabled =
//               context.read<LeccionesProvider>().isLeccionCompletada(leccionId);
//           if (isEnabled) {
//             print("Lección $leccionId completada");
//             _navigateToReproductorVideoHelper(videoId, duracionId);
//           } else {
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: const Text("Lección no disponible"),
//                   content: const Text(
//                       "Debes completar esta lección antes de acceder a la siguiente."),
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
//         },
//         child: Align(
//           alignment: Alignment.centerRight,
//           child: Padding(
//             padding: EdgeInsets.only(
//               top: MediaQuery.of(context).size.height * 0.02,
//               right: MediaQuery.of(context).size.width * 0.55,
//               bottom: MediaQuery.of(context).size.height * 0.01,
//             ),
//             child: CircularPercentIndicator(
//               radius: radius,
//               lineWidth: 9.0,
//               percent: context
//                       .read<LeccionesProvider>()
//                       .isLeccionCompletada(leccionId)
//                   ? 1.0
//                   : 0.0,
//               center: _buildImageContainer(imageName),
//               circularStrokeCap: CircularStrokeCap.butt,
//               progressColor: color,
//               backgroundColor: Colors.white,
//             ),
//           ),
//         ),
//       );
//     });
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
// }

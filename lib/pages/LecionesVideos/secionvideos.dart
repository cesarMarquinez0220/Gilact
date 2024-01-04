// import 'package:flutter/material.dart';
// import 'package:flutter_login/pages/LecionesVideos/reproductorsesiones.dart';
// import 'package:flutter_login/pages/enlaces%20de%20videos/enlaces.dart';
// import 'package:flutter_login/pages/paginadepruebas.dart';
// import 'package:google_fonts/google_fonts.dart';

// class VideoData {
//   final int id;
//   final String imageAsset;
//   final String timeWatched;
//   final String titleimage;

//   VideoData({
//     required this.id,
//     required this.imageAsset,
//     required this.timeWatched,
//     required this.titleimage,
//   });
// }

// class SeccionVideos extends StatefulWidget {
//   const SeccionVideos({Key? key}) : super(key: key);

//   @override
//   _SeccionVideosState createState() => _SeccionVideosState();
// }

// class _SeccionVideosState extends State<SeccionVideos> {
//   int _selectedIndex = 0;

//   List<VideoData> videos = [
//     VideoData(
//       id: 1,
//       imageAsset: 'assets/mini_videos/1.png', // Ruta de la imagen del video 1
//       timeWatched: '1:18', // Tiempo
//       titleimage:
//           "Que es lactancia materna\n y su importancia", //titulo o desripcion
//     ),
//     VideoData(
//       id: 2,
//       imageAsset: 'assets/mini_videos/2.1.png',
//       timeWatched: '2:38',
//       titleimage: "Beneficios de la lactancia\n materna",
//     ),
//     VideoData(
//       id: 4,
//       imageAsset: 'assets/mini_videos/3.1.png',
//       timeWatched: '4:52',
//       titleimage: "Que es el calostro, leche \nde transición y leche madura",
//     ),
//   ];

//   List<VideoData> sugeridos = [
//     VideoData(
//       id: 6,
//       imageAsset: 'assets/mini_videos/3.3.png',
//       timeWatched: '0:50',
//       titleimage: "Leche Madura",
//     ),
//     VideoData(
//       id: 11,
//       imageAsset: 'assets/mini_videos/6.png',
//       timeWatched: '1:13',
//       titleimage: "Higiene de manos, al\n ofrecer lactancia materna",
//     ),
//     VideoData(
//       id: 13,
//       imageAsset: 'assets/mini_videos/8.1.png',
//       timeWatched: '0:54',
//       titleimage:
//           "Que alimentación debe recibir una \nmadre durante la lactancia materna",
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height * 0.2,
//             decoration: const BoxDecoration(color: Colors.white
//                 // gradient: LinearGradient(
//                 //   begin: Alignment.topCenter,
//                 //   end: Alignment.bottomCenter,
//                 //   colors: [Color(0xffF2F2F2)],
//                 // ),
//                 ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Expanded(
//                 child: ListView(
//                   children: [
//                     SizedBox(
//                       height: 40,
//                     ),
//                     Text(
//                       'Sección de Videos',
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.quicksand(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xff034C8C)),
//                     ),
//                     _buildVideoListView("Videos", videos, isHorizontal: true),
//                     _buildVideoListView("Videos Relacionados", sugeridos,
//                         isHorizontal: false),
//                     SizedBox(
//                       height: 70,
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: 50,
//               decoration:
//                   const BoxDecoration(color: Colors.white // color del fondo del
//                       ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildNotificationButton(Icons.home, _selectedIndex == 0, 0),
//                   _buildNotificationButton(
//                       Icons.bar_chart, _selectedIndex == 1, 1),
//                   _buildNotificationButton(
//                       Icons.settings, _selectedIndex == 2, 2),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVideoListView(String title, List<VideoData> videos,
//       {bool isHorizontal = true}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Text(
//             title,
//             style: GoogleFonts.quicksand(
//               fontSize: 25,
//               fontWeight: FontWeight.bold,
//               color: Color(0xff034C8C),
//             ),
//           ),
//         ),
//         if (isHorizontal)
//           Container(
//             height: 230.0,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: videos.length,
//               itemBuilder: (context, index) {
//                 final videoData = videos[index];
//                 return Column(
//                   children: [
//                     Container(
//                       width: 250,
//                       height: 150,
//                       margin: const EdgeInsets.only(left: 8, right: 8),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(10),
//                             topRight: Radius.circular(10)),
//                         image: DecorationImage(
//                           image: AssetImage(videoData.imageAsset),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       child: InkWell(
//                         onTap: () {
//                           print("URL del video: ${videoData.id}");
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => Prueba(
//                                 videoId: videoData.id,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Stack(
//                           children: [
//                             const Center(
//                               child: Icon(
//                                 Icons.play_circle_outline,
//                                 size: 60,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               left: 0,
//                               right: 0,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text(
//                                     '${videoData.timeWatched}',
//                                     style: GoogleFonts.quicksand(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color.fromARGB(255, 255, 255, 255),
//                                     ),
//                                   ),
//                                   if (videoData.timeWatched.isNotEmpty)
//                                     SizedBox(height: 4),
//                                   if (videoData.timeWatched.isNotEmpty)
//                                     Stack(
//                                       children: [
//                                         Container(
//                                           height: 8,
//                                           color: Colors.grey,
//                                         ),
//                                         FractionallySizedBox(
//                                           widthFactor: 0.3,
//                                           child: Container(
//                                             height: 8,
//                                             color: Color.fromARGB(
//                                                 255, 224, 28, 14),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Container(
//                       width: 250,
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(
//                                 0.3), // Color y opacidad de la sombra
//                             offset:
//                                 Offset(0, 8), // Desplazamiento en el eje X y Y
//                             blurRadius: 15, // Radio de desenfoque
//                             spreadRadius:
//                                 0, // Radio de propagación de la sombra
//                           ),
//                         ],
//                         color: Colors.white, // Fondo blanco
//                         borderRadius: BorderRadius.only(
//                             bottomLeft: Radius.circular(10),
//                             bottomRight: Radius.circular(10)),
//                       ),
//                       child: Center(
//                         child: Text(
//                           videoData.titleimage,
//                           // Título del video
//                           style: GoogleFonts.quicksand(
//                             color: Color.fromARGB(
//                                 255, 117, 115, 115), // Letras negras
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           )
//         else
//           Column(
//             children: videos.map((videoData) {
//               return Row(
//                 children: [
//                   Container(
//                     height: 175,
//                     width: 250, // Altura fija para cada elemento vertical
//                     margin: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(10),
//                           bottomLeft: Radius.circular(10)),
//                       image: DecorationImage(
//                         image: AssetImage(videoData.imageAsset),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     child: InkWell(
//                       onTap: () {
//                         print("URL del video: ${videoData.id}");
//                         int duracionId = VideoLinks.videoDuracion[videoData.id] ?? 0;
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => ReproductorVideo(
//                               videoId: videoData.id,   duracionId: duracionId,
//                             ),
//                           ),
//                         );
//                       },
//                       child: Stack(
//                         children: [
//                           const Center(
//                             child: Icon(
//                               Icons.play_circle_outline,
//                               size: 60,
//                               color: Colors.white,
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             left: 0,
//                             right: 0,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text(
//                                   '${videoData.timeWatched}',
//                                   style: GoogleFonts.quicksand(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color.fromARGB(255, 255, 255, 255),
//                                   ),
//                                 ),
//                                 if (videoData.timeWatched.isNotEmpty)
//                                   SizedBox(height: 4),
//                                 if (videoData.timeWatched.isNotEmpty)
//                                   Stack(
//                                     children: [
//                                       Container(
//                                         height: 8,
//                                         color: Colors.grey,
//                                       ),
//                                       FractionallySizedBox(
//                                         widthFactor: 0.3,
//                                         child: Container(
//                                           height: 8,
//                                           color:
//                                               Color.fromARGB(255, 224, 28, 14),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Container(
//                     width: 150,
//                     height: 175,
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(
//                               0.3), // Color y opacidad de la sombra
//                           offset:
//                               Offset(0, 8), // Desplazamiento en el eje X y Y
//                           blurRadius: 15, // Radio de desenfoque
//                           spreadRadius: 0, // Radio de propagación de la sombra
//                         ),
//                       ],
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(10),
//                           bottomRight: Radius.circular(10)),
//                     ),
//                     child: Center(
//                       child: Text(
//                         videoData.titleimage, // Título del video
//                         style: GoogleFonts.quicksand(
//                           color: Color.fromARGB(
//                               255, 117, 115, 115), // Letras negras
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//       ],
//     );
//   }

//   Widget _buildNotificationButton(IconData icon, bool isActive, int index) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedIndex = index;
//         });
//       },
//       child: Column(
//         children: [
//           //const SizedBox(height: 7),
//           Container(
//             height: 15,
//             padding: const EdgeInsets.all(5),
//             decoration: BoxDecoration(
//               color: isActive ? Colors.white : Colors.transparent,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               color: isActive
//                   ? Colors.blue
//                   : const Color.fromARGB(255, 150, 148, 148),
//               size: 30,
//             ),
//           ),
//          // const SizedBox(height: 2),
//         ],
//       ),
//     );
//   }
// }

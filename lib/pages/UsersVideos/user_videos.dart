import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/LecionesVideos/reproductorsesiones.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:flutter_login/pages/UsersVideos/search_json.dart';
import 'package:flutter_login/pages/claseGlobal/firestoreService.dart';
import 'package:google_fonts/google_fonts.dart';

class User_videos extends StatefulWidget {
  const User_videos({Key? key, required List<Video> videos});

  @override
  State<User_videos> createState() => _User_videosState();
}

class _User_videosState extends State<User_videos> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String usuario;
  int lastCompletedLesson = 0;
  List<Video>? _videos;

  Future<void> _getUltimaLeccionCompletada() async {
    try {
      final usuarioDocRef = await _getUsuarioDocumento(usuario);
      if (usuarioDocRef != null) {
        final videosCollectionRef = usuarioDocRef.collection('videos');
        final videosCollection =
            await videosCollectionRef.orderBy(FieldPath.documentId).get();

        if (videosCollection.docs.isNotEmpty) {
          // Filtrar los documentos con contadorVisualizaciones distinto de 0
          final videosConContador = videosCollection.docs
              .where(
                  (videoDoc) => (videoDoc['contadorVisualizaciones'] ?? 0) > 0)
              .toList();

          if (videosConContador.isNotEmpty) {
            // Ordenar los documentos de menor a mayor (por número de lección)
            videosConContador
                .sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

            // Obtener el último documento (mayor número de lección)
            final lastLessonDoc = videosConContador.last;

            // Obtener el número de lección
            setState(() {
              lastCompletedLesson = int.parse(lastLessonDoc.id);
              print('Ultima leccion $lastCompletedLesson');
            });
          }
        }
      }
      print('Ultima leccion $lastCompletedLesson');
    } catch (error) {
      print('Error al obtener la última lección completada: $error');
    }
  }

  Future<DocumentReference?> _getUsuarioDocumento(String usuario) async {
    final usersQuery = await _firestore
        .collection('Users')
        .where('usuario', isEqualTo: usuario)
        .limit(1)
        .get();

    return usersQuery.docs.isNotEmpty ? usersQuery.docs[0].reference : null;
  }

  @override
  void initState() {
    super.initState();
    usuario = UserDataStorage.getUserName();
    _getUltimaLeccionCompletada();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _videos = args['videos'] as List<Video>;
    return Scaffold(
      backgroundColor: Color.fromARGB(119, 2, 80, 71),
      appBar: getAppBar(),
      body: getBody(_videos!),
    );
  }

  PreferredSizeWidget getAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Container(
        height: 35,
        width: double.infinity,
        margin: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.40),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Buscar",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.5),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView getBody(List<Video> videos) {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 35, left: 20, right: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Videos Disponibles",
              style: TextStyle(
                fontFamily: 'Quicksand',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Column(
              children: List.generate(videos.length, (index) {
                final video = videos[index];
                // Verifica si el video pertenece a la última lección completada
                if (video.videoId <= lastCompletedLesson) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: (size.width - 40) * 0.8,
                          height: 80,
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/mini_videos/${video.imgvideos}'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 120,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 15),
                              Container(
                                width: (size.width - 36) * 0.4,
                                child: Text(
                                  video.title,
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: (size.width - 36) * 0.2,
                          height: 80,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReproductorVideo(
                                      videoId: video.videoId,
                                      duracionId: video.duration,
                                      videoUrl: video.videoURL,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(width: 2, color: Colors.white),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return SizedBox(); // Si el video no corresponde a la última lección completada, no se muestra
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

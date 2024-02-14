import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/gradient.dart';
import 'package:flutter_login/pages/PerfilContinuacion/Progreso/Lecciones.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:flutter_login/pages/enlaces%20de%20videos/duracion_enlaces.dart';
import 'package:flutter_login/pages/enlaces%20de%20videos/enlaces.dart';
import 'package:flutter_login/pages/enlaces%20de%20videos/notifire.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> guardarInformacionVideo({
    required String usuario,
    required int videoId,
    required int pausas,
    required int adelantos,
    required int ultimaPosicion,
    required int duracion,
  }) async {
    try {
      final usuarioDocRef = await _getUsuarioDocumento(usuario);

      if (usuarioDocRef != null) {
        // Guardar información en la colección 'videos'
        // Check if the document for the video already exists
        final videoDocRef =
            usuarioDocRef.collection('videos').doc(videoId.toString());

        final videoDoc = await videoDocRef.get();

        if (videoDoc.exists) {
          // Update existing document
          await videoDocRef.update({
            'pausas': pausas,
            'adelantos': adelantos,
            'ultimaPosicion': ultimaPosicion,
            'duracion': duracion,
          });
        } else {
          // Create a new document
          await videoDocRef.set({
            'pausas': pausas,
            'adelantos': adelantos,
            'ultimaPosicion': ultimaPosicion,
            'duracion': duracion,
          });
        }

        // Guardar información en la colección 'adelantosvideo'
        await usuarioDocRef.collection('adelantosvideo').add({
          'videoId': videoId,
          'adelantos': adelantos,
          'milisegundoRetrocedido': ultimaPosicion,
        });

        print('Información del video guardada con éxito en Firestore');
      } else {
        print('No se encontró un usuario con el nombre: $usuario');
      }
    } catch (error) {
      print('Error al guardar información en Firestore: $error');
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

  Future<Map<String, dynamic>> obtenerInformacionVideo(
      String usuario, int videoId) async {
    try {
      final usuarioDocRef = await _getUsuarioDocumento(usuario);

      if (usuarioDocRef != null) {
        final videoDoc = await usuarioDocRef
            .collection('videos')
            .doc(videoId.toString())
            .get();

        if (videoDoc.exists) {
          return videoDoc.data() as Map<String, dynamic>;
        }
      } else {
        print('No se encontró un usuario con el nombre: $usuario');
      }
    } catch (error) {
      print('Error al obtener información del video en Firestore: $error');
    }

    return {};
  }

  // Future<void> actualizarContadorVisualizaciones(
  //     String usuario, int videoId) async {
  //   try {
  //     final usuarioDocRef = await _getUsuarioDocumento(usuario);

  //     if (usuarioDocRef != null) {
  //       final videoDocRef =
  //           usuarioDocRef.collection('videos').doc(videoId.toString());

  //       final videoDoc = await videoDocRef.get();

  //       if (videoDoc.exists) {
  //         final int contadorVisualizaciones =
  //             (videoDoc.data()?['contadorVisualizaciones'] ?? 0) + 1;

  //         await videoDocRef.update({
  //           'contadorVisualizaciones': contadorVisualizaciones,
  //         });
  //       }else {
  //       // El documento no existe, crearlo con contadorVisualizaciones en 1
  //       await videoDocRef.set({
  //         'contadorVisualizaciones': 1,
  //         // Puedes agregar otros campos aquí si es necesario
  //       });
  //     }
  //     } else {
  //       print('No se encontró un usuario con el nombre: $usuario');
  //     }
  //   } catch (error) {
  //     print('Error al actualizar contador de visualizaciones: $error');
  //   }
  // }

  Future<void> guardarInformacionProgresoLeccion({
    required String usuario,
    required int leccionId,
    required double progreso,
    required bool completada,
  }) async {
    try {
      final usuarioDocRef = await _getUsuarioDocumento(usuario);

      if (usuarioDocRef != null) {
        // Guardar información en la colección 'progresoLecciones'
        final leccionDocRef = usuarioDocRef
            .collection('progresoLecciones')
            .doc(leccionId.toString());

        await leccionDocRef.set({
          'progreso': progreso,
          'completada': completada,
        });

        print(
            'Información de progreso de lección guardada con éxito en Firestore');
      } else {
        print('No se encontró un usuario con el nombre: $usuario');
      }
    } catch (error) {
      print('Error al guardar información de progreso en Firestore: $error');
    }
  }

  Future<Map<String, dynamic>> obtenerInformacionProgresoLeccion(
      String usuario, int leccionId) async {
    try {
      final usuarioDocRef = await _getUsuarioDocumento(usuario);

      if (usuarioDocRef != null) {
        final leccionDoc = await usuarioDocRef
            .collection('progresoLecciones')
            .doc(leccionId.toString())
            .get();

        if (leccionDoc.exists) {
          return leccionDoc.data() as Map<String, dynamic>;
        }
      } else {
        print('No se encontró un usuario con el nombre: $usuario');
      }
    } catch (error) {
      print('Error al obtener información de progreso en Firestore: $error');
    }

    return {};
  }
}

class ReproductorVideo extends StatefulWidget {
  final int videoId;
  final int duracionId;

  ReproductorVideo({
    Key? key,
    required this.videoId,
    required this.duracionId,
  }) : super(key: ValueKey<int>(videoId));

  @override
  _ReproductorVideoState createState() => _ReproductorVideoState();
}

class _ReproductorVideoState extends State<ReproductorVideo> {
  late YoutubePlayerController _controller;
  bool initialized = false;
  bool isPaused = false;
  int pauseCount = 0; // Contador de pausas
  int forwardCount = 0; // Contador de avances
  Duration? lastPosition; // Última posición del video antes de pausar

  @override
  void initState() {
    super.initState();
    _initializeYoutubePlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeYoutubePlayer() async {
    print('Inicializando Youtube Player para video ID: ${widget.videoId}');
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
            VideoLinks.videoUrls[widget.videoId]!,
          ) ??
          '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        loop: false,
        mute: false,
        forceHD: false,
        controlsVisibleAtStart: true,
      ),
    );

    // Busca la última posición del video desde Firestore y ajusta la posición del video
    if (_controller.value.isReady) {
      _controller.seekTo(
        Duration(
          milliseconds: (await FirestoreService().obtenerInformacionVideo(
                UserDataStorage.getUserName(),
                widget.videoId,
              ))['ultimaPosicion'] ??
              0,
        ),
      );
    }

    // Agregar un listener para detectar el final del video
  }

  void _handleVideoPaused() {
    // Solo aumenta el contador si el video estaba reproduciéndose
    if (!isPaused) {
      pauseCount++;
      print('Número de veces que se ha realizado pausa: $pauseCount');
      guardarInformacionEnFirestore();
    }
    isPaused = true;
  }

  void _handleVideoPlay() {
    // Reinicia el estado de pausa cuando se reanuda la reproducción

    isPaused = false;
  }

  void _handleSeekTo(Duration duration) {
    if (duration > _controller.value.position) {
      forwardCount++;
      _handleSeekTo(_controller.value.position);
      print('Número de veces que se ha realizado avance: $forwardCount');
      guardarInformacionEnFirestore();
    }
  }

  Future<void> guardarInformacionEnFirestore() async {
    try {
      final userName = UserDataStorage.getUserName();
      final videoId = widget.videoId; // Asegúrate de tener acceso a esto
      final usuarioDocRef =
          await FirestoreService()._getUsuarioDocumento(userName);

      if (usuarioDocRef != null) {
        final videoDocRef =
            usuarioDocRef.collection('videos').doc(videoId.toString());

        final videoDoc = await videoDocRef.get();

        if (videoDoc.exists) {
          // El documento ya existe, actualizar el contador
          final int contadorVisualizaciones =
              (videoDoc.data()?['contadorVisualizaciones'] ?? 0) + 1;

          await videoDocRef.update({
            'contadorVisualizaciones': contadorVisualizaciones,
          });
        } else {
          // El documento no existe, crearlo con contadorVisualizaciones en 1
          await videoDocRef.set({
            'contadorVisualizaciones': 1,
            // Puedes agregar otros campos aquí si es necesario
          });
        }

        print('Guardando información en Firestore...');
        print(widget.duracionId);
        await FirestoreService().guardarInformacionVideo(
          usuario: userName,
          videoId: widget.videoId,
          pausas: pauseCount,
          adelantos: forwardCount,
          ultimaPosicion: _controller.value.position.inMilliseconds,
          duracion: VideoDuration.videoDuracion[widget.duracionId] ?? 0,
        );
      } else {
        print('No se encontró un usuario con el nombre: $userName');
      }
    } catch (error) {
      print('Error al actualizar contador de visualizaciones: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: Gradients.myGradient),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (_controller.value.isPlaying) {
                    setState(() {
                      pauseCount++;
                    });
                    print('PAUSAS POR PARTE DEL GESTURE: $pauseCount');
                    guardarInformacionEnFirestore();
                  }
                },
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  onEnded: (metaData) {
                    print("se mando el true\n id del video$widget");
                    guardarInformacionEnFirestore();
                    Navigator.pop(context, true);
                    //cambio de estado de la lista por ID
                    //LeccionesProvider().marcarVideoComoVisto(widget.videoId);
                    context
                        .read<LeccionesProvider>()
                        .marcarVideoComoVisto(widget.videoId);
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 - 25.0,
            left: MediaQuery.of(context).size.width * 0.5 - 25.0,
            child: InkWell(
              onTap: () {
                // Manejar la pausa y reproducción manualmente
                if (_controller.value.isPlaying) {
                  _controller.pause();
                  _handleVideoPaused();
                } else {
                  _controller.play();
                  _handleVideoPlay();
                }
              },
              child: Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors
                      .transparent, // Configura el fondo como transparente
                ),
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors
                      .transparent, // Configura el color del icono como transparente
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

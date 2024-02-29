// ignore_for_file: avoid_print, library_private_types_in_public_api, unused_element, unused_local_variable, use_build_context_synchronously
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/gradient.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:flutter_login/pages/proveedor_boleanos/notifire.dart';
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
    required int totalDuration,
    required double avance,
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
            'duracion': totalDuration,
            'avance': avance,
          });
        } else {
          // Create a new document
          await videoDocRef.set({
            'pausas': pausas,
            'adelantos': adelantos,
            'ultimaPosicion': ultimaPosicion,
            'duracion': totalDuration,
            'avance': avance,
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
}

class ReproductorVideo extends StatefulWidget {
  final String videoUrl;
  final int videoId;

  ReproductorVideo({
    Key? key,
    required this.videoUrl,
    required this.videoId,
  }) : super(key: ValueKey<String>(videoUrl));

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
  bool videoEnded = false;

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
            widget.videoUrl,
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

    _controller.addListener(() async {
      if (_controller.value.isReady) {
        Duration totalDuration = _controller.metadata.duration;
        print('Duración total del video: ${totalDuration.inSeconds}');
        if (isPaused) {
          await guardarInformacionEnFirestore();
        }
      }
    });
  }

  void _handleVideoPaused() {
    // Solo aumenta el contador si el video estaba reproduciéndose
    if (!isPaused) {
      pauseCount++;
      lastPosition = _controller.value.position;
      print('Numero de veces que se ha realizado pausa: $pauseCount');
    }
    isPaused = true;
  }

  void _handleVideoPlay() {
    isPaused = false;
  }

  void _onVideoEnded() async {
    print('Video terminado. Incrementando contador de visualizaciones...');
    final userName = UserDataStorage.getUserName();
    final videoId = widget.videoId;
    final usuarioDocRef =
        await FirestoreService()._getUsuarioDocumento(userName);

    if (usuarioDocRef != null) {
      final videoDocRef =
          usuarioDocRef.collection('videos').doc(videoId.toString());
      final videoDoc = await videoDocRef.get();

      if (videoDoc.exists) {
        final int contadorVisualizaciones =
            (videoDoc.data()?['contadorVisualizaciones'] ?? 0) + 1;
        await videoDocRef.update({
          'contadorVisualizaciones': contadorVisualizaciones,
          'completado': true,
        });
      } else {
        await videoDocRef.set({
          'contadorVisualizaciones': 1,
          'completado': true,
        });
      }
    } else {
      print('No se encontró un usuario con el nombre: $userName');
    }
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
    // Obtener la última posición del video y la duración total del video
    Duration? lastPosition = _controller.value.position;
    Duration totalDuration = _controller.metadata.duration;

    // Calcular el avance como un valor entre 0 y 1
    double progress = lastPosition.inSeconds / totalDuration.inSeconds;
    progress = progress.clamp(0.0, 1.0);

    try {
      final userName = UserDataStorage.getUserName();
      final videoId = widget.videoId;
      final usuarioDocRef =
          await FirestoreService()._getUsuarioDocumento(userName);

      if (usuarioDocRef != null) {
        final videoDocRef =
            usuarioDocRef.collection('videos').doc(videoId.toString());

        final videoDoc = await videoDocRef.get();
        print('Guardando información en Firestore...');
        await FirestoreService().guardarInformacionVideo(
          usuario: userName,
          videoId: widget.videoId,
          pausas: pauseCount,
          adelantos: forwardCount,
          ultimaPosicion: _controller.value.position.inSeconds,
          totalDuration: totalDuration.inSeconds,
          avance: progress,
        );
        context.read<Avancesprovider>().guardarProgresoPorId(videoId, progress);
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
                onTap: () {},
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  onEnded: (metaData) {
                    guardarInformacionEnFirestore();
                    _onVideoEnded();
                    Navigator.pop(context, true);
                    context
                        .read<LeccionesProvider>()
                        .marcarVideoComoVisto(widget.videoId);
                    context
                        .read<Avancesprovider>()
                        .actualizarAvancePorId(widget.videoId, 1);
                  },
                ),
              ),
            ),
          ),
          Center(
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
                width: 70.0,
                height: 70.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

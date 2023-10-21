import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/gradient.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:flutter_login/pages/enlaces%20de%20videos/enlaces.dart';
import 'package:video_player/video_player.dart';

class ReproductorVideo extends StatefulWidget {
  final int videoId;

  ReproductorVideo({
    required this.videoId,
  });

  @override
  _ReproductorVideoState createState() => _ReproductorVideoState();
}

class _ReproductorVideoState extends State<ReproductorVideo> {
  late VideoPlayerController _controller;

  int pauseCount = 0; // Contador de pausas
  int forwardCount = 0; // Contador de avances
  Duration? lastPosition; // Última posición del video antes de pausar

  @override
  void initState() {
    super.initState();
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(VideoLinks.videoUrls[widget.videoId]!),
      );
      // Initialize the controller and store the Future for later use.
      print(VideoLinks.videoUrls[widget.videoId]);
      // Use the controller to loop the video.
      _controller.setLooping(true);

      // Agrega un listener al controlador de video para rastrear pausas y avances
      _controller.addListener(() {
        if (_controller.value.isPlaying && lastPosition != null) {
          guardarInformacionEnFirestore();
        }
        lastPosition = _controller.value.position;
      });
    } catch (e) {
      print("Error al cargar el video: $e");
    }
  }

  @override
  void dispose() {
    // Asegúrate de disponer del VideoPlayerController para liberar recursos.
    _controller.dispose();

    super.dispose();
  }

  Future<void> guardarInformacionEnFirestore() async {
    final userName = UserDataStorage.getUserName();
    final usersQuery = await FirebaseFirestore.instance
        .collection('Users')
        .where('usuario', isEqualTo: userName)
        .limit(1)
        .get();

    try {
      if (usersQuery.docs.isNotEmpty) {
        // Si se encuentra un documento existente con el nombre de usuario,
        // actualiza ese documento en lugar de crear uno nuevo.
        final usuarioDocRef = usersQuery.docs[0].reference;

        await usuarioDocRef.update({
          'pausas': pauseCount,
          'adelantos': forwardCount,
          'ultimaPosicion': lastPosition?.inMilliseconds,
        });

        // Crea una subcolección 'datosvideos' dentro del documento del usuario
        final datosvideosRef = usuarioDocRef.collection('datosvideos');
        await datosvideosRef.add({
          'dato1': 'valor1',
          'dato2': 'valor2',
          // Agrega los datos que desees en la subcolección 'datosvideos'
        });

        print('Información actualizada con éxito en Firestore');
      } else {
        print(
            'No se encontró un documento con el nombre de usuario: $userName');
      }
    } catch (error) {
      print('Error al actualizar la información en Firestore: $error');
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

    final chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
      // Otras opciones de configuración de Chewie aquí
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: Gradients.myGradient),
          ),
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Chewie(controller: chewieController),
            ),
          ),
        ],
      ),
    );
  }
}

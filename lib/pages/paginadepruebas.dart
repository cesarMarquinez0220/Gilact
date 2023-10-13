import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/pages/enlaces%20de%20videos/enlaces.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_login/pages/PerfilContinuacion/user_data_storage.dart';
import 'package:flutter_login/gradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Prueba extends StatefulWidget {
final int videoId;

 Prueba({
    required this.videoId,
  });
  @override
  _PruebaState createState() => _PruebaState();
}

class _PruebaState extends State<Prueba> {
  late YoutubePlayerController _controller;

  int pauseCount = 0; // Contador de pausas
  int forwardCount = 0; // Contador de avances
  Duration? lastPosition; // Última posición del video antes de pausar

  @override
  void initState() {
    super.initState();

    _initializeYoutubePlayer();
  }

  void _initializeYoutubePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
        VideoLinks.videoUrls[widget.videoId]!,
      ) ?? '',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    // Agrega un listener al controlador de YouTube para rastrear pausas y avances
    _controller.addListener(() {
      if (_controller.value.isPlaying && lastPosition != null) {
        // El video se reanudó después de una pausa.
        Duration currentPosition = _controller.value.position;
        // Registra la información en Firestore
        guardarInformacionEnFirestore();
      }
      lastPosition = _controller.value.position;
    });
  }

  @override
  void dispose() {
    // Asegúrate de disponer del controlador de YouTube para liberar recursos.
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

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: Gradients.myGradient),
          ),
          Center(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Realiza un seguimiento de los avances.
          forwardCount++;
          // Salta adelante 10 segundos (puedes ajustar este valor según tus necesidades).
          _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds + 10));
        },
        child: Icon(Icons.forward),
      ),
    );
  }
}

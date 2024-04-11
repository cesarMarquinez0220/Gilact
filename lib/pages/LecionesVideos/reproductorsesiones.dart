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
  bool _canPop = true;
  bool _guardadoRealizado = false;
  bool _duracionImpresa = false;

  @override
  void initState() {
    super.initState();
    _initializeYoutubePlayer();
    _getLastPositionFromFirestore();
  }

  @override
  @protected
  @mustCallSuper
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeYoutubePlayer() async {
    if (mounted) {
      try {
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
            if (totalDuration.inSeconds > 0) {
              // Si la duración total del video es mayor que 0 y la duración no se ha impreso, entonces imprímela
              if (!_duracionImpresa) {
                print('Duración total del video: ${totalDuration.inSeconds}');
                _duracionImpresa = true; // Marca la duración como impresa
              }

              // Si la duración del video es mayor que 0 y el guardado no se ha realizado, entonces realiza el guardado
              if (!_guardadoRealizado) {
                await guardarInformacionEnFirestore();
                _guardadoRealizado = true;
              }
            } else {
              // Si la duración total del video es 0, reinicia la bandera de duración impresa
              _duracionImpresa = false;
              _guardadoRealizado = false; // Reinicia el estado del guardado
            }
          }
        });
      } catch (error) {
        print('error por parte del mounted $error');
      }
    }
  }

  Future<int> _getLastPositionFromFirestore() async {
    if (mounted) {
      final userName = UserDataStorage.getUserName();
      final usuarioDocRef =
          await FirestoreService()._getUsuarioDocumento(userName);
      if (usuarioDocRef != null) {
        final videoDoc = await usuarioDocRef
            .collection('videos')
            .doc(widget.videoId.toString())
            .get();
        if (videoDoc.exists) {
          final ultimaPosicion = videoDoc.data()?['ultimaPosicion'];
          if (ultimaPosicion != null) {
            // Establecer la posición del video al valor almacenado en la base de datos
            _controller.seekTo(Duration(seconds: ultimaPosicion));
            print('ultima posicion es de $ultimaPosicion');
          }
        }
        //     if (videoDoc.exists) {
        //       return videoDoc.data()?['ultimaPosicion'] ?? 0;

        //     }
      }
    }
    return 0; // Valor predeterminado en caso de que no se encuentre la última posición en Firestore
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
    if (mounted) {
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
  }

  Future<void> guardarInformacionEnFirestore() async {
    // Obtener la última posición del video y la duración total del video
    if (mounted) {
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
          context
              .read<Avancesprovider>()
              .guardarProgresoPorId(videoId, progress);
        } else {
          print('No se encontró un usuario con el nombre: $userName');
        }
      } catch (error) {
        print('Error al actualizar contador de visualizaciones: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return PopScope(
        canPop: _canPop,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Visibility(
              visible: orientation != Orientation.landscape,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Al presionar hacia atrás, restaurar la orientación vertical
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                  _canPop = true;
                  Navigator.pop(context);
                },
              ),
            ),
          ),
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
                      onReady: () {
                        _getLastPositionFromFirestore();
                      },
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
                      guardarInformacionEnFirestore();
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
                      color: Color.fromARGB(0, 188, 11, 11),
                    ),
                    child: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

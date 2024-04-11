// ignore_for_file: camel_case_types, use_key_in_widget_constructors, avoid_print, sized_box_for_whitespace, unused_local_variable
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/pages/LecionesVideos/reproductorsesiones.dart';
import 'package:flutter_login/pages/claseGlobal/firestoreService.dart';
import 'package:flutter_login/pages/proveedor_boleanos/notifire.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class lecciones extends StatefulWidget {
  const lecciones({Key? key, required List<Video> videos});

  @override
  State<lecciones> createState() => _leccionesState();
}

class _leccionesState extends State<lecciones> {
  Key leccionesKey = UniqueKey();
  int lastCompletedLesson = 0; // Número de la última lección completada
  final firestoreService = FirestoreServiceLecciones();
  List<Video>? _videos;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final videos = await firestoreService.getVideos();
      setState(() {
        _videos = videos;
      });
    } catch (error) {
      print('Error al cargar los videos: $error');
    }
  }

  Future<void> _navigateToReproductorVideoHelper(
      int videoId, int duracionId, String videoURL) async {
    print("ID del video enviado al reproductor es: $videoId");
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => ReproductorVideo(
          videoId: videoId,
          videoUrl: videoURL,
        ),
        transitionsBuilder: (context, animation1, animation2, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          var offsetAnimation = animation1.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );

    // Verifica si se completó una lección y actualiza lastCompletedLesson
    if (result != null && result is int) {
      setState(() {
        lastCompletedLesson = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _videos = args['videos'] as List<Video>;
    final avancesProvider =
        Provider.of<Avancesprovider>(context, listen: false);
    avancesProvider.imprimirAvancesMap(); // Llamada para imprimir el mapa
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.centerLeft,
                colors: [
                  Color(0xffD9ACF5),
                  Color.fromARGB(255, 122, 231, 211),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _buildAppBar(),
                    SingleChildScrollView(child: _buildLessons(_videos!)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      actions: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Sección de Lecciones de Videos"),
                  content: const Text(
                      "En esta sección se encuentran las lecciones a visualizar."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Cerrar"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            child: const Icon(
              Icons.help,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLessons(List<Video> videos) {
    int previousLessonId = -1; // Almacena el ID de la lección anterior
    int lastCompletedIndex = -1;

    // Encuentra el índice del último video completado
    for (int i = 0; i < videos.length; i++) {
      if (context
          .read<LeccionesProvider>()
          .isLeccionCompletada(videos[i].videoId)) {
        lastCompletedIndex = i;
      } else {
        break; // Detiene el bucle cuando encuentra el primer video no completado
      }
    }

    return Column(
      children: videos.asMap().entries.map((entry) {
        final index = entry.key;
        final video = entry.value;
        final isOdd = index.isOdd;
        final currentLessonId = video.leccionId;
        final isLastCompleted = index == lastCompletedIndex;

        // Verifica si es necesario mostrar el encabezado
        final showHeader = currentLessonId != previousLessonId;
        previousLessonId = currentLessonId;

        // Si es el primer video de la lección 1, habilitarlo

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              if (showHeader) // Muestra el encabezado solo si es necesario
                Column(
                  children: [
                    _Title('Lección ${video.leccionId}'),
                    _Subtitle(_getSubtitleForLesson(video.leccionId)),
                  ],
                ),
              Padding(
                padding: EdgeInsets.only(
                  top: isOdd ? 15.0 : 15.0,
                  bottom: isOdd ? 15.0 : 15.0,
                  left: isOdd ? MediaQuery.of(context).size.width * 0.5 : 0.0,
                  right: isOdd ? 0.0 : MediaQuery.of(context).size.width * 0.58,
                ),
                child: _PercentIndicator(
                  69.0,
                  video.imageName,
                  isLastCompleted ? Colors.blue : Colors.blue,
                  video.videoId,
                  video.leccionId,
                  leccionId: video.leccionId,
                  videoURL: video.videoURL,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getSubtitleForLesson(int lessonNumber) {
    // Aquí puedes definir los subtítulos según el número de lección
    switch (lessonNumber) {
      case 1:
        return 'Lactancia materna y sus beneficios';
      case 2:
        return 'Calostro, leche de transición y leche madura';
      case 3:
        return "Cosas en tomar en cuenta al momento de amamantar";
      case 4:
        return "Composición Nutricional de la Leche Materna";
      case 5:
        return '¿Cómo saber que el bebé se alimentó lo suficiente?';
      case 6:
        return "Hitos de peso a vigilar";
      case 7:
        return "Higiene de manos y técnicas de lactancia materna";
      case 8:
        return 'Medicamentos durante la lactancia materna';
      case 9:
        return 'Signos o Complicaciones en la Lactancia';
      case 10:
        return 'Masajes al seno antes de iniciar la lactancia';
      case 11:
        return 'Mi banco de leche en casa y su preservacion';
      case 12:
        return 'Leyes en Panamá que apoyan la lactancia materna';
      case 13:
        return 'Diferencias entre la leche materna y la leche de vaca';
      case 14:
        return 'Mitos de la lactancia materna';

      default:
        return '';
    }
  }

  // ignore: non_constant_identifier_names
  Widget _Title(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          title,
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Subtitle(String subtitle) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Text(
          subtitle,
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  //circulo indicador de la derecha
  // ignore: non_constant_identifier_names
  Widget _PercentIndicator(
    double radius,
    String imageName,
    Color color,
    int videoId,
    int duracionId, {
    required int leccionId,
    required String videoURL,
  }) {
    return Consumer2<LeccionesProvider, Avancesprovider>(
      builder: (context, leccionesProvider, avancesProvider, child) {
        final ultimoId = leccionesProvider.ultimoIdEnEstadoTrue(
          leccionesProvider.lecciones_list,
        );
        final esUltimoId = videoId == ultimoId;
        // Verificar si es el primer video de la primera lección
        final isFirstVideoOfFirstLesson = leccionId == 1 && videoId == 1;

        final double progreso =
            context.read<Avancesprovider>().obtenerAvancePorId(videoId);

        return GestureDetector(
          onTap: () {
            final isEnabled = context
                    .read<LeccionesProvider>()
                    .isLeccionCompletada(videoId) ||
                isFirstVideoOfFirstLesson;
            if (isEnabled) {
              print("Lección $videoId completada");
              _navigateToReproductorVideoHelper(videoId, duracionId, videoURL);
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Lección no disponible"),
                    content: const Text(
                      "Debes completar esta lección antes de acceder a la siguiente.",
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Cerrar"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: Align(
            alignment: Alignment.centerRight,
            child: esUltimoId
                ? Flash(
                    duration: const Duration(seconds: 2),
                    child: Container(
                      width: radius * 2,
                      height: radius * 2,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow,
                            spreadRadius: 5,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CircularPercentIndicator(
                        radius: radius,
                        lineWidth: 9.0,
                        percent: progreso,
                        center: _buildImageContainer(imageName),
                        circularStrokeCap: CircularStrokeCap.butt,
                        progressColor: color,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  )
                : Container(
                    width: radius * 2,
                    height: radius * 2,
                    child: CircularPercentIndicator(
                      radius: radius,
                      lineWidth: 9.0,
                      percent: progreso,
                      center: _buildImageContainer(imageName),
                      circularStrokeCap: CircularStrokeCap.butt,
                      progressColor: color,
                      backgroundColor: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildImageContainer(String imageName) {
    return Center(
      child: Container(
        width: 120.0,
        height: 120.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Center(
          child:
              Image.asset('assets/images/$imageName', height: 100, width: 100),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_login/pages/LecionesVideos/reproductorsesiones.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoData {
  final int id;
  final String imageAsset;
  final String timeWatched;


  VideoData({
    required this.id,
    required this.imageAsset,
    required this.timeWatched,

  });
}

class SeccionVideos extends StatefulWidget {
  const SeccionVideos({Key? key}) : super(key: key);

  @override
  _SeccionVideosState createState() => _SeccionVideosState();
}

class _SeccionVideosState extends State<SeccionVideos> {
  int _selectedIndex = 0;

  List<VideoData> videos = [
    VideoData(
      id: 1,
      imageAsset:
          'assets/miniaturas de videos/1.png', // Ruta de la imagen del video 1
      timeWatched: '1:18', // Tiempo
    ),
    VideoData(
      id: 2,
      imageAsset: 'assets/miniaturas de videos/2.1.png',
      timeWatched: '2:38',
    ),
    VideoData(
      id: 4,
      imageAsset: 'assets/miniaturas de videos/3.1.png',
      timeWatched: '4:52',
    ),
  ];

  List<VideoData> sugeridos = [
    VideoData(
      id: 6,
      imageAsset: 'assets/miniaturas de videos/3.3.png',
      timeWatched: '0:50',
    ),
    VideoData(
      id: 11,
      imageAsset: 'assets/miniaturas de videos/6.png',
      timeWatched: '1:13',
    ),
    VideoData(
      id: 13,
      imageAsset: 'assets/miniaturas de videos/8.1.png',
      timeWatched: '0:54',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              //color: Colors.white
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 7, 139, 221),
                  Color.fromARGB(255, 7, 139, 221),
                  Color.fromARGB(255, 82, 222, 187),
                  Color.fromARGB(255, 122, 231, 211),
                  Color(0xffF2F2F2),
                  Color(0xffF2F2F2),
                ],
              ),
            ),
          ),

          //columan de los videos
          Padding(
            padding: const EdgeInsets.only(top: 35.0, left: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Seccion de Videos',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                _buildVideoListView("Videos", videos),
                _buildVideoListView("Videos Relacionados", sugeridos),
              ],
            ),
          ),
          //posicionamiento de la barra de navegacion con sus builders
          Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: Container(
              height: 66,
              decoration: const BoxDecoration(
                color: Color(0xffF2F2F2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNotificationButton(Icons.home, _selectedIndex == 0, 0),
                  _buildNotificationButton(
                      Icons.bar_chart, _selectedIndex == 1, 1),
                  _buildNotificationButton(
                      Icons.settings, _selectedIndex == 2, 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //constructor de los videos list view
  Widget _buildVideoListView(String title, List<VideoData> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final videoData =
                  videos[index]; // Obtener la instancia de VideoData
              return Container(
                width: 200,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(videoData.imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    print("URL del video: ${videoData.id}");
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReproductorVideo(
                          videoId: videoData.id,
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${videoData.timeWatched}',
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            if (videoData.timeWatched.isNotEmpty)
                              SizedBox(height: 4),
                            if (videoData.timeWatched.isNotEmpty)
                              Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    color: Colors.grey,
                                  ),
                                  FractionallySizedBox(
                                    widthFactor:
                                        0.3, // Cambia este valor para indicar el progreso
                                    child: Container(
                                      height: 8,
                                      color: Color.fromARGB(255, 224, 28, 14),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationButton(IconData icon, bool isActive, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {});
      },
      child: Column(
        children: [
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive
                  ? Colors.blue
                  : const Color.fromARGB(255, 150, 148, 148),
              size: 30,
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

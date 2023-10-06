import 'package:flutter/material.dart';

class VideoData {
  final String title;
  final String imageAsset;
  final String timeWatched;

  VideoData({
    required this.title,
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
      title: 'Video 4',
      imageAsset:
          'assets/miniaturas de videos/1.png', // Ruta de la imagen del video 4
      timeWatched: '2:30', // Tiempo visto del video 4
    ),
    VideoData(
      title: 'Video 5',
      imageAsset:
          'assets/miniaturas de videos/2.1.png', // Ruta de la imagen del video 5
      timeWatched: '1:45', // Tiempo visto del video 5
    ),
    VideoData(
      title: 'Video 6',
      imageAsset:
          'assets/miniaturas de videos/3.1.png', // Ruta de la imagen del video 6
      timeWatched: '3:15', // Tiempo visto del video 6
    ),
  ];

  List<VideoData> sugeridos = [
    VideoData(
      title: 'Video 1',
      imageAsset:
          'assets/miniaturas de videos/4.1.png', // Ruta de la imagen del video 1
      timeWatched: '4:20', // Tiempo visto del video 1
    ),
    VideoData(
      title: 'Video 2',
      imageAsset:
          'assets/miniaturas de videos/10.png', // Ruta de la imagen del video 2
      timeWatched: '2:10', // Tiempo visto del video 2
    ),
    VideoData(
      title: 'Video 3',
      imageAsset:
          'assets/miniaturas de videos/11.1.png', // Ruta de la imagen del video 3
      timeWatched: '5:00', // Tiempo visto del video 3
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
                end: Alignment.centerRight,
                colors: [
                  Color.fromARGB(255, 7, 139, 221),
                  Color.fromARGB(255, 7, 139, 221),
                  Color.fromARGB(255, 122, 231, 211),
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
                const Text('Seccion de Videos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(videos[index].imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black.withOpacity(0.6),
                      child: Text(
                        videos[index].title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black.withOpacity(0.6),
                      child: Text(
                        'Tiempo Visto: ${videos[index].timeWatched}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                  ],
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

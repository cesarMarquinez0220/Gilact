import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserVideosPage extends StatefulWidget {
  const UserVideosPage({super.key});

  @override
  State<UserVideosPage> createState() => _UserVideosPageState();
}

class _UserVideosPageState extends State<UserVideosPage> {
  int lastCompletedLesson = 0;
  List<dynamic> _videos = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final maybeVideos = args['videos'];
      final maybeLast = args['lastCompletedLesson'];
      if (maybeVideos is List) {
        _videos = List<dynamic>.from(maybeVideos);
      }
      if (maybeLast is int) {
        lastCompletedLesson = maybeLast;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildTransparentAppBar(),
      body: Stack(
        children: [
          Positioned(
            top: -MediaQuery.of(context).size.height * .12,
            right: MediaQuery.of(context).size.width * .05,
            child: const _BezierDecoration(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 1,
            width: double.infinity,
            child: _buildBody(_videos),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * -0.2,
            left: 0,
            right: 0,
            child: const Align(
              alignment: Alignment.bottomCenter,
              child: _OvalDecoration(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTransparentAppBar() {
    return AppBar(backgroundColor: Colors.transparent, elevation: 0);
  }

  Widget _buildBody(List<dynamic> videos) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 80, left: 20, right: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              height: 35,
              width: MediaQuery.of(context).size.width * .88,
              margin: const EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Buscar',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Videos Disponibles',
              style: GoogleFonts.quicksand(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (videos.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  'No hay videos para mostrar',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              )
            else
              Column(
                children: List.generate(videos.length, (index) {
                  final video = videos[index];
                  final title = _extractTitle(video);
                  final videoId = _extractVideoId(video);
                  final videoUrl = _extractVideoUrl(video);
                  final imageName = _extractImageName(video);

                  if (videoId <= lastCompletedLesson) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 80,
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage(
                                              'assets/mini_videos/$imageName',
                                            ),
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
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(
                                          255,
                                          117,
                                          115,
                                          115,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Navegar a reproductor si existe en la nueva arquitectura
                                  // Navigator.push(context, MaterialPageRoute(builder: (_) => ReproductorVideo(videoId: videoId, videoUrl: videoUrl)));
                                },
                                child: Container(
                                  width: size.width * 0.5,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: const Color.fromARGB(
                                        255,
                                        117,
                                        115,
                                        115,
                                      ),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Color.fromARGB(255, 117, 115, 115),
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
                    return const SizedBox();
                  }
                }),
              ),
          ],
        ),
      ),
    );
  }

  String _extractTitle(dynamic video) {
    try {
      if (video is Map<String, dynamic>)
        return (video['title'] ?? '').toString();
      return video.title?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  int _extractVideoId(dynamic video) {
    try {
      if (video is Map<String, dynamic>)
        return (video['videoId'] as num?)?.toInt() ?? 0;
      return (video.videoId as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  String _extractVideoUrl(dynamic video) {
    try {
      if (video is Map<String, dynamic>)
        return (video['videoURL'] ?? '').toString();
      return video.videoURL?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _extractImageName(dynamic video) {
    try {
      if (video is Map<String, dynamic>)
        return (video['imgvideos'] ?? '1.png').toString();
      return video.imgvideos?.toString() ?? '1.png';
    } catch (_) {
      return '1.png';
    }
  }
}

class _BezierDecoration extends StatelessWidget {
  const _BezierDecoration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.06),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _OvalDecoration extends StatelessWidget {
  const _OvalDecoration();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0x1A000000), Color(0x33000000)],
        ),
      ),
    );
  }
}

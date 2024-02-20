import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServiceLecciones {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Video>> getVideos() async {
    final QuerySnapshot querySnapshot =
        await _firestore.collection('videos').orderBy('id').get();
    return querySnapshot.docs.map((doc) => Video.fromDocument(doc)).toList();
  }
}

class Video {
  final String videoURL;
  final int duration;
  final String imageName;
  final int leccionId;
  final int videoId;

  Video({
    required this.videoURL,
    required this.duration,
    required this.imageName,
    required this.leccionId,
    required this.videoId,
  });

  // Método para crear un objeto Video a partir de un documento de Firestore
  factory Video.fromDocument(QueryDocumentSnapshot doc) {
    return Video(
      videoURL: doc.get('url') as String,
      duration: doc.get('duracion') as int,
      imageName: doc.get('imagen') as String,
      leccionId: doc.get('numero_leccion') as int,
      videoId: doc.get('id') as int,
    );
  }
}

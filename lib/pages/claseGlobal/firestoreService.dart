// ignore_for_file: file_names, avoid_print, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart'
    show
        DocumentReference,
        FirebaseFirestore,
        QueryDocumentSnapshot,
        QuerySnapshot;
import '../PerfilContinuacion/user_data_storage.dart';

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
  final String imageName;
  final int leccionId;
  final int videoId;
  final String title;
  final String imgvideos;

  Video({
    required this.videoURL,
    required this.imageName,
    required this.leccionId,
    required this.videoId,
    required this.title,
    required this.imgvideos,
  });

  // Método para crear un objeto Video a partir de un documento de Firestore
  factory Video.fromDocument(QueryDocumentSnapshot doc) {
    return Video(
      imgvideos: doc.get('imgVideos') as String,
      title: doc.get('title') as String,
      videoURL: doc.get('url') as String,
      imageName: doc.get('imagen') as String,
      leccionId: doc.get('numero_leccion') as int,
      videoId: doc.get('id') as int,
    );
  }
}

class ObtenerInfoAvance {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userName = UserDataStorage.getUserName();

  Future<DocumentReference?> _getUsuarioDocumento(String usuario) async {
    final usersQuery = await _firestore
        .collection('Users')
        .where('usuario', isEqualTo: usuario)
        .limit(1)
        .get();

    return usersQuery.docs.isNotEmpty ? usersQuery.docs[0].reference : null;
  }

  Future<List<int>> obtenerIdsVideosCompletadosDesdeFirestore(
      String usuario) async {
    try {
      final usuarioDocRef = await _getUsuarioDocumento(usuario);
      final List<int> idsVideosCompletados = [];

      if (usuarioDocRef != null) {
        final videosQuerySnapshot = await usuarioDocRef
            .collection('videos')
            .where('completado', isEqualTo: true)
            .get();

        videosQuerySnapshot.docs.forEach((videoDocSnapshot) {
          idsVideosCompletados.add(int.parse(videoDocSnapshot.id));
        });

        return idsVideosCompletados;
      } else {
        print('No se encontró un usuario con el nombre: $usuario');
      }
    } catch (error) {
      print(
          'Error al obtener información de videos completados desde Firestore: $error');
    }

    // En caso de error, devuelve una lista vacía
    return [];
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user_profile_entities.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfile> getUserProfile(String username);
  Future<UserProfile> updateUserProfile(UserProfile userProfile);
  Future<BabyInfo?> getBabyInfo(String username);
  Future<BabyInfo> updateBabyInfo(String username, BabyInfo babyInfo);
  Future<List<LessonProgress>> getLessonProgress(String username);
  Future<LessonProgress> updateLessonProgress(
    String username,
    String lessonId,
    double progress,
  );
  Future<int> getLastCompletedLesson(String username);
  Future<Map<String, bool>> checkUserSituation(String username);
  Future<void> signOut();
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  UserProfileRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<UserProfile> getUserProfile(String username) async {
    try {
      final querySnapshot = await firestore
          .collection('Users')
          .where('usuario', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Usuario no encontrado');
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();

      return UserProfile(
        id: doc.id,
        username: data['usuario'] ?? '',
        email: data['email'] ?? '',
        motherName: data['nombre madre'] ?? '',
        birthDate: data['fechaNacimiento'] ?? '',
        age: data['edad'] ?? 0,
        cedula: data['cedula'] ?? '',
        location: data['ubicacion'] ?? '',
        phone: data['telefono'] ?? '',
        registrationDate:
            DateTime.tryParse(data['fechaRegistro'] ?? '') ?? DateTime.now(),
        isPrePartum: data['isPrePartum'] ?? false,
        isPostPartum: data['isPostPartum'] ?? false,
      );
    } catch (e) {
      throw Exception('Error al obtener perfil de usuario: $e');
    }
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile userProfile) async {
    try {
      final querySnapshot = await firestore
          .collection('Users')
          .where('usuario', isEqualTo: userProfile.username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Usuario no encontrado');
      }

      final docRef = querySnapshot.docs.first.reference;

      await docRef.update({
        'usuario': userProfile.username,
        'nombre madre': userProfile.motherName,
        'fechaNacimiento': userProfile.birthDate,
        'edad': userProfile.age,
        'cedula': userProfile.cedula,
        'ubicacion': userProfile.location,
        'telefono': userProfile.phone,
        'isPrePartum': userProfile.isPrePartum,
        'isPostPartum': userProfile.isPostPartum,
      });

      return userProfile;
    } catch (e) {
      throw Exception('Error al actualizar perfil de usuario: $e');
    }
  }

  @override
  Future<BabyInfo?> getBabyInfo(String username) async {
    try {
      final querySnapshot = await firestore
          .collection('Users')
          .where('usuario', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final userDocRef = querySnapshot.docs.first.reference;
      final situationDoc = await userDocRef
          .collection('situacion')
          .doc('Post-Parto')
          .get();

      if (!situationDoc.exists) {
        return null;
      }

      final data = situationDoc.data()!;

      return BabyInfo(
        name: data['nombre bebe'] ?? '',
        gestationalAge: data['edad gestacional'] ?? 0,
        birthDate: data['fecha nacimiento bebe'] ?? '',
        lactationStartDate: data['fecha lactancia'] ?? '',
        lactationTime: data['hora lactancia'] ?? '',
        birthTime: data['hora nacimiento'] ?? '',
        birthPlace: data['lugar nacimiento'] ?? '',
        weight: data['peso'] ?? '',
      );
    } catch (e) {
      throw Exception('Error al obtener información del bebé: $e');
    }
  }

  @override
  Future<BabyInfo> updateBabyInfo(String username, BabyInfo babyInfo) async {
    try {
      final querySnapshot = await firestore
          .collection('Users')
          .where('usuario', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Usuario no encontrado');
      }

      final userDocRef = querySnapshot.docs.first.reference;

      await userDocRef.collection('situacion').doc('Post-Parto').set({
        'nombre bebe': babyInfo.name,
        'edad gestacional': babyInfo.gestationalAge,
        'fecha nacimiento bebe': babyInfo.birthDate,
        'fecha lactancia': babyInfo.lactationStartDate,
        'hora lactancia': babyInfo.lactationTime,
        'hora nacimiento': babyInfo.birthTime,
        'lugar nacimiento': babyInfo.birthPlace,
        'peso': babyInfo.weight,
      });

      return babyInfo;
    } catch (e) {
      throw Exception('Error al actualizar información del bebé: $e');
    }
  }

  @override
  Future<List<LessonProgress>> getLessonProgress(String username) async {
    try {
      final querySnapshot = await firestore
          .collection('Users')
          .where('usuario', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final userDocRef = querySnapshot.docs.first.reference;
      final videosCollection = await userDocRef.collection('videos').get();

      List<LessonProgress> progressList = [];

      // Definir las lecciones estáticas
      final lessons = _getStaticLessons();

      for (var lesson in lessons) {
        final videoDoc = videosCollection.docs
            .where((doc) => doc.id == lesson.lessonId)
            .firstOrNull;

        if (videoDoc != null) {
          final data = videoDoc.data();
          final isCompleted = (data['contadorVisualizaciones'] ?? 0) > 0;

          progressList.add(
            lesson.copyWith(
              isCompleted: isCompleted,
              progressPercentage: isCompleted ? 100.0 : 0.0,
            ),
          );
        } else {
          progressList.add(lesson);
        }
      }

      return progressList;
    } catch (e) {
      throw Exception('Error al obtener progreso de lecciones: $e');
    }
  }

  @override
  Future<LessonProgress> updateLessonProgress(
    String username,
    String lessonId,
    double progress,
  ) async {
    try {
      final querySnapshot = await firestore
          .collection('Users')
          .where('usuario', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Usuario no encontrado');
      }

      final userDocRef = querySnapshot.docs.first.reference;

      await userDocRef.collection('videos').doc(lessonId).set({
        'contadorVisualizaciones': progress > 0 ? 1 : 0,
        'progressPercentage': progress,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Obtener la lección actualizada
      final lessons = _getStaticLessons();
      final lesson = lessons.firstWhere((l) => l.lessonId == lessonId);

      return lesson.copyWith(
        isCompleted: progress > 0,
        progressPercentage: progress,
      );
    } catch (e) {
      throw Exception('Error al actualizar progreso de lección: $e');
    }
  }

  @override
  Future<int> getLastCompletedLesson(String username) async {
    try {
      final querySnapshot = await firestore
          .collection('Users')
          .where('usuario', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 0;
      }

      final userDocRef = querySnapshot.docs.first.reference;
      final videosCollection = await userDocRef
          .collection('videos')
          .orderBy(FieldPath.documentId)
          .get();

      final completedVideos = videosCollection.docs
          .where((doc) => (doc.data()['contadorVisualizaciones'] ?? 0) > 0)
          .toList();

      if (completedVideos.isEmpty) {
        return 0;
      }

      completedVideos.sort(
        (a, b) => int.parse(a.id).compareTo(int.parse(b.id)),
      );
      return int.parse(completedVideos.last.id);
    } catch (e) {
      throw Exception('Error al obtener última lección completada: $e');
    }
  }

  @override
  Future<Map<String, bool>> checkUserSituation(String username) async {
    try {
      final querySnapshot = await firestore
          .collection('Users')
          .where('usuario', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {'pre': false, 'post': false};
      }

      final userDocRef = querySnapshot.docs.first.reference;

      final prePartumDoc = await userDocRef
          .collection('situacion')
          .doc('Pre-Parto')
          .get();

      final postPartumDoc = await userDocRef
          .collection('situacion')
          .doc('Post-Parto')
          .get();

      return {'pre': prePartumDoc.exists, 'post': postPartumDoc.exists};
    } catch (e) {
      throw Exception('Error al verificar situación del usuario: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  List<LessonProgress> _getStaticLessons() {
    return [
      const LessonProgress(
        lessonId: '1',
        title: 'Lección 1',
        subtitle: 'Lactancia materna y sus beneficios',
        imageName: 'Homevideo.png',
        videoId: 1,
        durationId: 1,
        isEnabled: true,
        progressColor: Colors.blue,
      ),
      const LessonProgress(
        lessonId: '2',
        title: 'Lección 1',
        subtitle: 'Lactancia materna y sus beneficios',
        imageName: 'Writingvideo.png',
        videoId: 2,
        durationId: 2,
        progressColor: Colors.blue,
      ),
      const LessonProgress(
        lessonId: '3',
        title: 'Lección 1',
        subtitle: 'Lactancia materna y sus beneficios',
        imageName: 'working.png',
        videoId: 3,
        durationId: 3,
        progressColor: Colors.blue,
      ),
      // Agregar más lecciones según sea necesario
    ];
  }
}

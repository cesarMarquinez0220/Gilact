import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/app_logger.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String birthDate,
    String? phone,
    String? location,
    String? idNumber,
    String? motherName,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<void> resetPassword({required String email});

  Future<void> sendEmailVerification();

  Future<UserModel> updateProfile({required String name, String? photoUrl});

  Future<void> deleteAccount();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._firestore, this._logger);

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Error al iniciar sesión');
      }

      return await _getUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String birthDate,
    String? phone,
    String? location,
    String? idNumber,
    String? motherName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Error al crear usuario');
      }

      // Actualizar el perfil del usuario
      await credential.user!.updateDisplayName(name);

      // Calcular edad automáticamente desde fecha de nacimiento
      int? calculatedAge;
      if (birthDate.isNotEmpty) {
        try {
          final birthDateTime = DateTime.parse(birthDate);
          final now = DateTime.now();
          calculatedAge = now.year - birthDateTime.year;
          if (now.month < birthDateTime.month ||
              (now.month == birthDateTime.month &&
                  now.day < birthDateTime.day)) {
            calculatedAge--;
          }
        } catch (e) {
          // Si hay error en el cálculo, dejar edad como null
          calculatedAge = null;
        }
      }

      // Crear documento completo en Firestore
      final userModel = UserModel.fromFirebaseUser(
        id: credential.user!.uid,
        email: email,
        name: name,
        photoUrl: credential.user!.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: credential.user!.emailVerified,
        birthDate: birthDate,
        phone: phone,
        location: location,
        age: calculatedAge,
        idNumber: idNumber,
        motherName: motherName,
      );

      await _firestore
          .collection('Users')
          .doc(credential.user!.uid)
          .set(userModel.toDocument());

      // Las subcolecciones se crearán cuando el usuario complete el onboarding
      _logger.success(
        'Usuario registrado exitosamente: ${credential.user!.uid}',
      );

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(message: 'Error al cerrar sesión: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return await _getUserFromFirestore(user.uid);
    } catch (e) {
      throw AuthException(
        message: 'Error al obtener usuario actual: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No hay usuario autenticado');
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No hay usuario autenticado');
      }

      // Actualizar en Firebase Auth
      await user.updateDisplayName(name);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Actualizar en Firestore
      final userModel = UserModel.fromFirebaseUser(
        id: user.uid,
        email: user.email ?? '',
        name: name,
        photoUrl: photoUrl ?? user.photoURL,
        createdAt: DateTime.now(), // Esto debería venir de la base de datos
        updatedAt: DateTime.now(),
        isEmailVerified: user.emailVerified,
      );

      await _firestore
          .collection('Users')
          .doc(user.uid)
          .update(userModel.toDocument());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No hay usuario autenticado');
      }

      // Eliminar de Firestore
      await _firestore.collection('Users').doc(user.uid).delete();

      // Eliminar cuenta de Firebase Auth
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    try {
      // Primero intentar buscar por UID
      DocumentSnapshot? doc = await _firestore
          .collection('Users')
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }

      // Si no existe por UID, buscar por email
      final querySnapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: _firebaseAuth.currentUser?.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromDocument(querySnapshot.docs.first);
      }

      throw const AuthException(message: 'Usuario no encontrado');
    } catch (e) {
      throw ServerException(
        message: 'Error al obtener datos del usuario: ${e.toString()}',
      );
    }
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No se encontró un usuario con este email';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      default:
        return 'Error de autenticación: $errorCode';
    }
  }
}

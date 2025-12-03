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

  Future<void> deleteAccount({String? password});
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
      _logger.d('AuthRemoteDataSource: Enviando email de restablecimiento a: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _logger.success('AuthRemoteDataSource: Email de restablecimiento enviado exitosamente');
    } on FirebaseAuthException catch (e) {
      _logger.e('AuthRemoteDataSource: Error de Firebase Auth al enviar email de restablecimiento', e);
      throw AuthException(message: _getAuthErrorMessage(e.code));
    } catch (e, stackTrace) {
      _logger.e('AuthRemoteDataSource: Error inesperado al enviar email de restablecimiento', e, stackTrace);
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
  Future<void> deleteAccount({String? password}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No hay usuario autenticado');
      }

      final userId = user.uid;
      final userEmail = user.email;
      _logger.d('AuthRemoteDataSource: Iniciando eliminación de cuenta para usuario: $userId');

      // IMPORTANTE: Primero eliminar de Firebase Auth, luego de Firestore
      // Si eliminamos primero de Firestore y falla Auth, quedamos en estado inconsistente
      
      // Intentar eliminar de Firebase Auth primero
      try {
        _logger.d('AuthRemoteDataSource: Eliminando cuenta de Firebase Auth...');
        await user.delete();
        _logger.success('AuthRemoteDataSource: Cuenta eliminada de Firebase Auth exitosamente');
      } on FirebaseAuthException catch (e) {
        _logger.e('AuthRemoteDataSource: Error al eliminar de Firebase Auth', e);
        
        // Si el error es que requiere login reciente, intentar reautenticarse si tenemos la contraseña
        if (e.code == 'requires-recent-login') {
          if (password != null && password.isNotEmpty && userEmail != null) {
            _logger.d('AuthRemoteDataSource: Intentando reautenticación con contraseña proporcionada...');
            try {
              // Reautenticar al usuario
              final credential = EmailAuthProvider.credential(
                email: userEmail,
                password: password,
              );
              await user.reauthenticateWithCredential(credential);
              _logger.success('AuthRemoteDataSource: Reautenticación exitosa, intentando eliminar nuevamente...');
              
              // Intentar eliminar nuevamente después de reautenticarse
              await user.delete();
              _logger.success('AuthRemoteDataSource: Cuenta eliminada de Firebase Auth exitosamente después de reautenticación');
            } catch (reauthError) {
              _logger.e('AuthRemoteDataSource: Error en reautenticación', reauthError);
              // Si la reautenticación falla, lanzar error específico
              if (reauthError is FirebaseAuthException) {
                throw AuthException(
                  message: 'Contraseña incorrecta. Por favor, verifica tu contraseña e intenta nuevamente.',
                );
              }
              throw AuthException(
                message: 'Error al reautenticarse. Por favor, cierra sesión e inicia sesión de nuevo.',
              );
            }
          } else {
            // No tenemos contraseña, lanzar error para que la UI la solicite
            _logger.w('AuthRemoteDataSource: Se requiere login reciente pero no se proporcionó contraseña');
            throw AuthException(
              message: 'REQUIRES_RECENT_LOGIN: Se requiere reautenticación para eliminar la cuenta. Por favor, ingresa tu contraseña.',
            );
          }
        } else {
          throw AuthException(message: _getAuthErrorMessage(e.code));
        }
      }

      // Si la eliminación de Auth fue exitosa, eliminar de Firestore
      try {
        _logger.d('AuthRemoteDataSource: Eliminando datos de Firestore...');
        
        // Buscar el documento del usuario (puede estar por UID o por email)
        String? userDocId;
        
        // Intentar buscar por UID primero
        final docByUid = await _firestore.collection('Users').doc(userId).get();
        if (docByUid.exists) {
          userDocId = userId;
        } else if (user.email != null) {
          // Si no existe por UID, buscar por email
          final querySnapshot = await _firestore
              .collection('Users')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get();
          
          if (querySnapshot.docs.isNotEmpty) {
            userDocId = querySnapshot.docs.first.id;
          }
        }

        if (userDocId != null) {
          await _firestore.collection('Users').doc(userDocId).delete();
          _logger.success('AuthRemoteDataSource: Datos eliminados de Firestore exitosamente');
        } else {
          _logger.w('AuthRemoteDataSource: No se encontró documento en Firestore para eliminar');
        }
      } catch (e, stackTrace) {
        // Si falla Firestore pero Auth ya se eliminó, solo loguear el error
        // La cuenta ya está eliminada de Auth, que es lo más importante
        _logger.e('AuthRemoteDataSource: Error al eliminar de Firestore (cuenta ya eliminada de Auth)', e, stackTrace);
        // No lanzar error aquí porque la cuenta ya se eliminó de Auth
      }

      _logger.success('AuthRemoteDataSource: Proceso de eliminación de cuenta completado');
    } on AuthException {
      // Re-lanzar AuthException sin modificar
      rethrow;
    } on FirebaseAuthException catch (e) {
      _logger.e('AuthRemoteDataSource: Error de Firebase Auth al eliminar cuenta', e);
      throw AuthException(message: _getAuthErrorMessage(e.code));
    } catch (e, stackTrace) {
      _logger.e('AuthRemoteDataSource: Error inesperado al eliminar cuenta', e, stackTrace);
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

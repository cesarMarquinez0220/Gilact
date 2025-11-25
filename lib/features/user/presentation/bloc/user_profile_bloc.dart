import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user_profile_entities.dart';
import '../../domain/usecases/user_profile_usecases.dart';
import '../../data/datasources/user_profile_offline_local_data_source.dart';
import '../../../../core/services/connectivity_service.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

@injectable
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final SignOutUseCase _signOutUseCase;
  final UserProfileOfflineLocalDataSource _offlineDataSource =
      UserProfileOfflineLocalDataSource();
  final ConnectivityService _connectivityService = ConnectivityService();

  UserProfileBloc({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required SignOutUseCase signOutUseCase,
  }) : _getUserProfileUseCase = getUserProfileUseCase,
       _updateUserProfileUseCase = updateUserProfileUseCase,
       _signOutUseCase = signOutUseCase,
       super(const UserProfileInitial()) {
    on<GetUserProfileRequested>(_onGetUserProfileRequested);
    on<UpdateUserProfileRequested>(_onUpdateUserProfileRequested);
    on<UpdateUserSituationRequested>(_onUpdateUserSituationRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ResetUserProfileRequested>(_onResetUserProfileRequested);
  }

  /// Obtiene el perfil de usuario (offline-first)
  /// Si hay conexión: obtiene de Firestore y actualiza cache
  /// Si no hay conexión: sirve desde cache
  Future<void> _onGetUserProfileRequested(
    GetUserProfileRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    try {
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        if (kDebugMode) {
          print(
            '🌐 UserProfileBloc: Con conexión, obteniendo perfil de Firestore...',
          );
        }

        // Si hay conexión, obtener de Firestore y actualizar cache
        final result = await _getUserProfileUseCase(event.userId);

        // Manejar Left (failure) o Right (success) por separado para poder usar await
        if (result.isLeft()) {
          if (kDebugMode) {
            print(
              '⚠️ UserProfileBloc: Error obteniendo de Firestore, intentando desde cache',
            );
          }
          // Si falla Firestore, intentar desde cache
          await _loadFromCache(event.userId, emit);
        } else {
          // Éxito: obtener el perfil del Right
          final profile = result.fold((failure) => null, (profile) => profile);
          if (profile != null) {
            if (kDebugMode) {
              print(
                '✅ UserProfileBloc: Perfil obtenido de Firestore, actualizando cache',
              );
            }
            // Cachear perfil actualizado
            try {
              await _offlineDataSource.cacheUserProfile(profile);
            } catch (e) {
              if (kDebugMode) {
                print('⚠️ UserProfileBloc: Error cacheando perfil: $e');
              }
              // Continuar aunque falle el cache
            }
            emit(UserProfileLoaded(profile));
          } else {
            if (kDebugMode) {
              print(
                '⚠️ UserProfileBloc: Perfil null de Firestore, intentando desde cache',
              );
            }
            // Fallback: intentar desde cache
            await _loadFromCache(event.userId, emit);
          }
        }
      } else {
        // Sin conexión: cargar desde cache
        if (kDebugMode) {
          print('📴 UserProfileBloc: Sin conexión, cargando desde cache');
        }
        await _loadFromCache(event.userId, emit);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ UserProfileBloc: Error obteniendo perfil: $e');
      }
      // Intentar desde cache como fallback
      await _loadFromCache(event.userId, emit);
    }
  }

  /// Carga el perfil desde cache
  Future<void> _loadFromCache(
    String userId,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      final cachedProfile = await _offlineDataSource.getCachedUserProfile(
        userId: userId,
      );

      if (cachedProfile != null) {
        if (kDebugMode) {
          print('✅ UserProfileBloc: Perfil cargado desde cache');
        }
        emit(UserProfileLoaded(cachedProfile));
      } else {
        if (kDebugMode) {
          print('⚠️ UserProfileBloc: No hay perfil en cache');
        }
        emit(
          const UserProfileFailure(
            'No hay conexión y no hay datos en cache. Por favor, conecta a internet para cargar tu perfil.',
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ UserProfileBloc: Error cargando desde cache: $e');
      }
      emit(UserProfileFailure('Error cargando perfil: $e'));
    }
  }

  Future<void> _onUpdateUserProfileRequested(
    UpdateUserProfileRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    // Crear un UserProfile con los datos del evento
    final userProfile = UserProfile(
      id: event.userId,
      username: event.name ?? '',
      email: '', // No se puede actualizar el email desde este evento
      motherName: '', // No se puede actualizar desde este evento
      birthDate: event.birthDate?.toIso8601String() ?? '',
      age: event.age ?? 0,
      cedula: event.idNumber ?? '',
      location: event.location ?? '',
      phone: event.phone ?? '',
      registrationDate: DateTime.now(),
    );

    final result = await _updateUserProfileUseCase(userProfile);

    result.fold((failure) => emit(UserProfileFailure(failure.message)), (
      profile,
    ) {
      // Cachear perfil actualizado
      _offlineDataSource.cacheUserProfile(profile);
      emit(UserProfileUpdated(profile));
    });
  }

  Future<void> _onUpdateUserSituationRequested(
    UpdateUserSituationRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      // Obtener el perfil actual del estado
      final currentState = state;
      UserProfile? currentProfile;

      if (currentState is UserProfileLoaded) {
        currentProfile = currentState.profile;
      } else if (currentState is UserProfileUpdated) {
        currentProfile = currentState.profile;
      } else if (currentState is UserProfileFailure) {
        // Si estamos en estado de falla, crear un perfil básico con la información de situación
        print(
          '⚠️ UserProfileBloc: Estado de falla detectado, creando perfil básico',
        );

        // Extraer información del bebé de los situationData
        BabyInfo? babyInfo;
        if (event.situationData != null && event.isPostPartum) {
          babyInfo = _extractBabyInfoFromSituationData(event.situationData!);
          print(
            '👶 UserProfileBloc: Información del bebé extraída: ${babyInfo?.name}',
          );
        }

        // Crear un perfil básico con la información de situación
        currentProfile = UserProfile(
          id: event.userId,
          username: 'Usuario', // Nombre temporal
          email: event.userId.contains('@') ? event.userId : '',
          motherName: '',
          birthDate: '',
          age: 0,
          cedula: '',
          location: '',
          phone: '',
          registrationDate: DateTime.now(),
          isPrePartum: event.isPrePartum,
          isPostPartum: event.isPostPartum,
          babyInfo: babyInfo,
          situationData: event.situationData,
        );
      }

      if (currentProfile != null) {
        // Extraer información del bebé si no existe y es postparto
        BabyInfo? babyInfo = currentProfile.babyInfo;
        if (babyInfo == null &&
            event.situationData != null &&
            event.isPostPartum) {
          babyInfo = _extractBabyInfoFromSituationData(event.situationData!);
          print(
            '👶 UserProfileBloc: Información del bebé extraída para perfil existente: ${babyInfo?.name}',
          );
        }

        // Crear un nuevo perfil con la información de situación actualizada
        final updatedProfile = UserProfile(
          id: currentProfile.id,
          username: currentProfile.username,
          email: currentProfile.email,
          motherName: currentProfile.motherName,
          birthDate: currentProfile.birthDate,
          age: currentProfile.age,
          cedula: currentProfile.cedula,
          location: currentProfile.location,
          phone: currentProfile.phone,
          registrationDate: currentProfile.registrationDate,
          isPrePartum: event.isPrePartum,
          isPostPartum: event.isPostPartum,
          babyInfo: babyInfo,
          situationData: event.situationData,
        );

        // Cachear perfil actualizado
        _offlineDataSource.cacheUserProfile(updatedProfile);

        emit(UserProfileUpdated(updatedProfile));
        print(
          '✅ UserProfileBloc: Situación actualizada - isPrePartum: ${event.isPrePartum}, isPostPartum: ${event.isPostPartum}',
        );
      } else {
        print(
          '⚠️ UserProfileBloc: No hay perfil cargado para actualizar situación',
        );
      }
    } catch (e) {
      print('❌ UserProfileBloc: Error actualizando situación: $e');
      emit(UserProfileFailure('Error actualizando situación: $e'));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    final result = await _signOutUseCase(const NoParams());

    result.fold(
      (failure) => emit(UserProfileFailure(failure.message)),
      (_) => emit(const UserProfileSignedOut()),
    );
  }

  Future<void> _onResetUserProfileRequested(
    ResetUserProfileRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    // Solo resetea el estado sin desconectar al usuario
    print('🔄 UserProfileBloc: Reseteando estado del perfil...');
    emit(const UserProfileInitial());
    print('✅ UserProfileBloc: Estado del perfil reseteado');
  }

  /// Extrae la información del bebé de los datos de situación
  BabyInfo? _extractBabyInfoFromSituationData(
    Map<String, dynamic> situationData,
  ) {
    try {
      // Verificar que tenemos los datos necesarios para crear BabyInfo
      if (situationData.containsKey('babyName') &&
          situationData.containsKey('birthDate') &&
          situationData.containsKey('birthWeight')) {
        return BabyInfo(
          name: situationData['babyName'] ?? '',
          gestationalAge: situationData['gestationalAge'] ?? 0,
          birthDate: situationData['birthDate'] ?? '',
          lactationStartDate:
              situationData['birthDate'] ??
              '', // Usar fecha de nacimiento como inicio de lactancia
          lactationTime: situationData['birthTime'] ?? '',
          birthTime: situationData['birthTime'] ?? '',
          birthPlace: situationData['birthPlace'] ?? '',
          weight: situationData['birthWeight']?.toString() ?? '0.0',
        );
      }

      print('⚠️ UserProfileBloc: Datos insuficientes para crear BabyInfo');
      return null;
    } catch (e) {
      print('❌ UserProfileBloc: Error extrayendo información del bebé: $e');
      return null;
    }
  }
}

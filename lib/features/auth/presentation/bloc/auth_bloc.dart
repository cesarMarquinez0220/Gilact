import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../data/services/offline_session_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/di/injection.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final OfflineSessionService _offlineSessionService;
  final ConnectivityService _connectivityService;
  final AppLogger _logger = getIt<AppLogger>();

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required SendEmailVerificationUseCase sendEmailVerificationUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required OfflineSessionService offlineSessionService,
    required ConnectivityService connectivityService,
  }) : _signInUseCase = signInUseCase,
       _signUpUseCase = signUpUseCase,
       _signOutUseCase = signOutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _sendEmailVerificationUseCase = sendEmailVerificationUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       _deleteAccountUseCase = deleteAccountUseCase,
       _offlineSessionService = offlineSessionService,
       _connectivityService = connectivityService,
       super(const AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<SendEmailVerificationRequested>(_onSendEmailVerificationRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<CheckOfflineSessionRequested>(_onCheckOfflineSessionRequested);
    on<SyncOfflineSessionRequested>(_onSyncOfflineSessionRequested);
    on<BiometricSignInRequested>(_onBiometricSignInRequested);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Verificar conectividad
    final isConnected = await _connectivityService.isConnected();

    if (!isConnected) {
      // Modo offline: validar credenciales localmente
      final isValid = await _offlineSessionService.validateCredentialsOffline(
        email: event.email,
        password: event.password,
      );

      if (isValid) {
        // Obtener usuario de sesión guardada
        final offlineUser = await _offlineSessionService.getOfflineUser();

        if (offlineUser != null) {
          emit(AuthAuthenticated(offlineUser));
        } else {
          emit(
            const AuthFailure(
              'Sesión no encontrada. Se requiere conexión para iniciar sesión por primera vez.',
            ),
          );
        }
      } else {
        emit(const AuthFailure('Credenciales incorrectas'));
      }
      return;
    }

    // Modo online: autenticar con Firebase
    final result = await _signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );

    await result.fold(
      (failure) async {
        emit(AuthFailure(failure.message));
      },
      (user) async {
        // Guardar sesión offline después de login exitoso
        final passwordHash = _offlineSessionService.hashPassword(
          event.password,
        );
        await _offlineSessionService.saveOfflineSession(
          user: user,
          email: event.email,
          passwordHash: passwordHash,
        );

        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Verificar conectividad (registro siempre requiere conexión)
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      emit(
        const AuthFailure(
          'Se requiere conexión a internet para crear una cuenta nueva.',
        ),
      );
      return;
    }

    final result = await _signUpUseCase(
      SignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
        birthDate: event.birthDate,
        phone: event.phone,
        location: event.location,
        idNumber: event.idNumber,
        motherName: event.motherName,
      ),
    );

    await result.fold(
      (failure) async {
        emit(AuthFailure(failure.message));
      },
      (user) async {
        // Guardar sesión offline después de registro exitoso
        final passwordHash = _offlineSessionService.hashPassword(
          event.password,
        );
        await _offlineSessionService.saveOfflineSession(
          user: user,
          email: event.email,
          passwordHash: passwordHash,
        );

        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Limpiar sesión offline
    await _offlineSessionService.clearSession();

    // Intentar cerrar sesión en Firebase (puede fallar si no hay conexión)
    final isConnected = await _connectivityService.isConnected();
    if (isConnected) {
      final result = await _signOutUseCase();
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(const AuthUnauthenticated()),
      );
    } else {
      // Sin conexión, solo limpiar sesión local
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onGetCurrentUserRequested(
    GetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _getCurrentUserUseCase();

    result.fold((failure) => emit(AuthFailure(failure.message)), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _resetPasswordUseCase(
      ResetPasswordParams(email: event.email),
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthPasswordResetSent()),
    );
  }

  Future<void> _onSendEmailVerificationRequested(
    SendEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _sendEmailVerificationUseCase();

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthEmailVerificationSent()),
    );
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _updateProfileUseCase(
      UpdateProfileParams(name: event.name, photoUrl: event.photoUrl),
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthProfileUpdated(user)),
    );
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _deleteAccountUseCase();

    result.fold((failure) => emit(AuthFailure(failure.message)), (_) async {
      // Limpiar sesión offline al eliminar cuenta
      await _offlineSessionService.clearSession();
      emit(const AuthUnauthenticated());
    });
  }

  /// Verificar sesión offline al iniciar app
  Future<void> _onCheckOfflineSessionRequested(
    CheckOfflineSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // 1. Verificar si hay sesión offline válida
      final hasSession = await _offlineSessionService.hasValidSession();

      if (hasSession) {
        // 2. Obtener usuario de sesión offline
        final offlineUser = await _offlineSessionService.getOfflineUser();

        if (offlineUser != null) {
          emit(AuthAuthenticated(offlineUser));
          return;
        }
      }

      // 3. Si no hay sesión offline, verificar Firebase (si hay conexión)
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        // Intentar obtener usuario de Firebase
        final result = await _getCurrentUserUseCase();
        result.fold((failure) => emit(const AuthUnauthenticated()), (user) {
          if (user != null) {
            emit(AuthAuthenticated(user));
          } else {
            emit(const AuthUnauthenticated());
          }
        });
      } else {
        // Sin conexión y sin sesión offline
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure('Error verificando sesión: $e'));
    }
  }

  /// Sincronizar sesión offline cuando vuelve la conexión
  Future<void> _onSyncOfflineSessionRequested(
    SyncOfflineSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        // No hay conexión, no se puede sincronizar
        return;
      }

      // Verificar si hay sesión offline
      final hasSession = await _offlineSessionService.hasValidSession();
      if (!hasSession) {
        return;
      }

      // Obtener usuario offline
      final offlineUser = await _offlineSessionService.getOfflineUser();
      if (offlineUser == null) {
        return;
      }

      // Intentar obtener usuario de Firebase para sincronizar
      final result = await _getCurrentUserUseCase();
      result.fold(
        (failure) {
          // Si falla, mantener sesión offline
          _logger.w('No se pudo sincronizar sesión: ${failure.message}');
        },
        (firebaseUser) {
          if (firebaseUser != null) {
            // Usuario encontrado en Firebase, extender sesión
            _offlineSessionService.extendSession();
            emit(AuthAuthenticated(firebaseUser));
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Error sincronizando sesión', e, stackTrace);
    }
  }

  /// Autenticar usando biométrica (huella dactilar/Face ID)
  Future<void> _onBiometricSignInRequested(
    BiometricSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Verificar que hay una sesión offline válida
      final hasSession = await _offlineSessionService.hasValidSession();
      if (!hasSession) {
        emit(
          const AuthFailure(
            'Sesión expirada. Por favor, inicia sesión con tu contraseña',
          ),
        );
        return;
      }

      // Obtener usuario de sesión offline
      final offlineUser = await _offlineSessionService.getOfflineUser();
      if (offlineUser == null) {
        emit(const AuthFailure('No se pudo obtener información del usuario'));
        return;
      }

      // Verificar que el email coincide
      if (offlineUser.email != event.email) {
        emit(const AuthFailure('El email no coincide con la sesión guardada'));
        return;
      }

      // Verificar conectividad
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        // Si hay conexión, intentar sincronizar con Firebase
        final result = await _getCurrentUserUseCase();
        result.fold(
          (failure) {
            // Si falla Firebase, usar sesión offline
            _logger.w(
              'No se pudo sincronizar con Firebase, usando sesión offline',
            );
            emit(AuthAuthenticated(offlineUser));
          },
          (firebaseUser) {
            if (firebaseUser != null) {
              // Usuario encontrado en Firebase, extender sesión
              _offlineSessionService.extendSession();
              emit(AuthAuthenticated(firebaseUser));
            } else {
              // Usuario no encontrado en Firebase, usar sesión offline
              emit(AuthAuthenticated(offlineUser));
            }
          },
        );
      } else {
        // Sin conexión, usar sesión offline
        emit(AuthAuthenticated(offlineUser));
      }
    } catch (e, stackTrace) {
      _logger.e('Error en autenticación biométrica', e, stackTrace);
      emit(AuthFailure('Error en autenticación biométrica: ${e.toString()}'));
    }
  }
}

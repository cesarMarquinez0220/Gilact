import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user_profile_entities.dart';
import '../../domain/usecases/user_profile_usecases.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

@injectable
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final SignOutUseCase _signOutUseCase;

  UserProfileBloc({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required SignOutUseCase signOutUseCase,
  }) : _getUserProfileUseCase = getUserProfileUseCase,
       _updateUserProfileUseCase = updateUserProfileUseCase,
       _signOutUseCase = signOutUseCase,
       super(UserProfileInitial()) {
    on<GetUserProfileRequested>(_onGetUserProfileRequested);
    on<UpdateUserProfileRequested>(_onUpdateUserProfileRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onGetUserProfileRequested(
    GetUserProfileRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    final result = await _getUserProfileUseCase(event.userId);

    result.fold(
      (failure) => emit(UserProfileFailure(failure.message)),
      (profile) => emit(UserProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateUserProfileRequested(
    UpdateUserProfileRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

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

    result.fold(
      (failure) => emit(UserProfileFailure(failure.message)),
      (profile) => emit(UserProfileUpdated(profile)),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    final result = await _signOutUseCase(NoParams());

    result.fold(
      (failure) => emit(UserProfileFailure(failure.message)),
      (_) => emit(UserProfileSignedOut()),
    );
  }
}

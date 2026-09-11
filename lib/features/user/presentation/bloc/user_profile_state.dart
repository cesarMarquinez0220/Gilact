part of 'user_profile_bloc.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileCreated extends UserProfileState {
  final UserProfile profile;

  const UserProfileCreated(this.profile);

  @override
  List<Object> get props => [profile];
}

class UserProfileLoaded extends UserProfileState {
  final UserProfile profile;

  const UserProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class UserProfileUpdated extends UserProfileState {
  final UserProfile profile;

  const UserProfileUpdated(this.profile);

  @override
  List<Object> get props => [profile];
}

class UserProfileDeleted extends UserProfileState {
  const UserProfileDeleted();
}

class UserProfileFailure extends UserProfileState {
  final String message;

  const UserProfileFailure(this.message);

  @override
  List<Object> get props => [message];
}

class UserProfileExistsChecked extends UserProfileState {
  final bool exists;

  const UserProfileExistsChecked(this.exists);

  @override
  List<Object> get props => [exists];
}

class UserProfileSignedOut extends UserProfileState {
  const UserProfileSignedOut();
}

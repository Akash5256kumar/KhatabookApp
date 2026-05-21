import 'package:apna_business_app/domain/entities/user_entity.dart';
import 'package:apna_business_app/domain/usecases/fetch_profile_usecase.dart';
import 'package:apna_business_app/domain/usecases/get_language_usecase.dart';
import 'package:apna_business_app/domain/usecases/update_language_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Loads and updates profile-level preferences.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  /// Creates the bloc.
  ProfileBloc({
    required FetchProfileUseCase fetchProfileUseCase,
    required GetLanguageUseCase getLanguageUseCase,
    required UpdateLanguageUseCase updateLanguageUseCase,
  })  : _fetchProfileUseCase = fetchProfileUseCase,
        _getLanguageUseCase = getLanguageUseCase,
        _updateLanguageUseCase = updateLanguageUseCase,
        super(const ProfileInitial()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileLanguageChanged>(_onLanguageChanged);
  }

  final FetchProfileUseCase _fetchProfileUseCase;
  final GetLanguageUseCase _getLanguageUseCase;
  final UpdateLanguageUseCase _updateLanguageUseCase;

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final profileResult = await _fetchProfileUseCase();
    final languageResult = await _getLanguageUseCase();
    profileResult.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (user) {
        languageResult.fold(
          (failure) => emit(ProfileFailure(failure.message)),
          (languageCode) => emit(
            ProfileSuccess(user: user, languageCode: languageCode),
          ),
        );
      },
    );
  }

  Future<void> _onLanguageChanged(
    ProfileLanguageChanged event,
    Emitter<ProfileState> emit,
  ) async {
    final ProfileState current = state;
    if (current is! ProfileSuccess) {
      return;
    }

    emit(const ProfileLoading());
    final result = await _updateLanguageUseCase(event.languageCode);
    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (languageCode) => emit(
        ProfileSuccess(user: current.user, languageCode: languageCode),
      ),
    );
  }
}

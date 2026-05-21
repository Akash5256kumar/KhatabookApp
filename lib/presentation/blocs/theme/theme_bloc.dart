import 'package:apna_business_app/domain/usecases/get_theme_mode_usecase.dart';
import 'package:apna_business_app/domain/usecases/update_theme_mode_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

/// Manages theme preference loading and persistence.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  /// Creates the bloc.
  ThemeBloc({
    required GetThemeModeUseCase getThemeModeUseCase,
    required UpdateThemeModeUseCase updateThemeModeUseCase,
  })  : _getThemeModeUseCase = getThemeModeUseCase,
        _updateThemeModeUseCase = updateThemeModeUseCase,
        super(const ThemeInitial()) {
    on<ThemeStarted>(_onStarted);
    on<ThemeToggled>(_onToggled);
  }

  final GetThemeModeUseCase _getThemeModeUseCase;
  final UpdateThemeModeUseCase _updateThemeModeUseCase;

  Future<void> _onStarted(
    ThemeStarted event,
    Emitter<ThemeState> emit,
  ) async {
    emit(ThemeLoading(themeMode: state.themeMode));
    final result = await _getThemeModeUseCase();
    result.fold(
      (failure) => emit(
        ThemeFailure(themeMode: state.themeMode, message: failure.message),
      ),
      (themeMode) => emit(ThemeSuccess(themeMode: themeMode)),
    );
  }

  Future<void> _onToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    final ThemeMode nextMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(ThemeLoading(themeMode: nextMode));
    final result = await _updateThemeModeUseCase(nextMode);
    result.fold(
      (failure) => emit(
        ThemeFailure(themeMode: state.themeMode, message: failure.message),
      ),
      (themeMode) => emit(ThemeSuccess(themeMode: themeMode)),
    );
  }
}

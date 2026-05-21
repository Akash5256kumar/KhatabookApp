import 'package:apna_business_app/domain/usecases/complete_onboarding_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// Handles onboarding pagination and completion.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  /// Creates the bloc.
  OnboardingBloc({
    required CompleteOnboardingUseCase completeOnboardingUseCase,
  })  : _completeOnboardingUseCase = completeOnboardingUseCase,
        super(const OnboardingInitial()) {
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingCompleted>(_onCompleted);
  }

  final CompleteOnboardingUseCase _completeOnboardingUseCase;

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingSuccess(pageIndex: event.pageIndex, isCompleted: false));
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading(pageIndex: state.pageIndex));
    final result = await _completeOnboardingUseCase();
    result.fold(
      (failure) => emit(
        OnboardingFailure(
          pageIndex: state.pageIndex,
          message: failure.message,
        ),
      ),
      (_) => emit(
        OnboardingSuccess(pageIndex: state.pageIndex, isCompleted: true),
      ),
    );
  }
}

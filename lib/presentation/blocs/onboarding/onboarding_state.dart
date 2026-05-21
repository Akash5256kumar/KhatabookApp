part of 'onboarding_bloc.dart';

/// Base state for [OnboardingBloc].
sealed class OnboardingState extends Equatable {
  /// Creates the state.
  const OnboardingState({required this.pageIndex});

  /// Current page index.
  final int pageIndex;

  @override
  List<Object?> get props => <Object?>[pageIndex];
}

/// Initial onboarding state.
final class OnboardingInitial extends OnboardingState {
  /// Creates the state.
  const OnboardingInitial() : super(pageIndex: 0);
}

/// Loading onboarding state.
final class OnboardingLoading extends OnboardingState {
  /// Creates the state.
  const OnboardingLoading({required super.pageIndex});
}

/// Success onboarding state.
final class OnboardingSuccess extends OnboardingState {
  /// Creates the state.
  const OnboardingSuccess({
    required super.pageIndex,
    required this.isCompleted,
  });

  /// Whether onboarding flow finished.
  final bool isCompleted;

  @override
  List<Object?> get props => <Object?>[pageIndex, isCompleted];
}

/// Failure onboarding state.
final class OnboardingFailure extends OnboardingState {
  /// Creates the state.
  const OnboardingFailure({
    required super.pageIndex,
    required this.message,
  });

  /// User-friendly error message.
  final String message;

  @override
  List<Object?> get props => <Object?>[pageIndex, message];
}

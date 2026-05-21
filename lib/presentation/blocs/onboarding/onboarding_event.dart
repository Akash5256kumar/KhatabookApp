part of 'onboarding_bloc.dart';

/// Base event for [OnboardingBloc].
sealed class OnboardingEvent extends Equatable {
  /// Creates an onboarding event.
  const OnboardingEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Updates the currently visible onboarding page.
final class OnboardingPageChanged extends OnboardingEvent {
  /// Creates the event.
  const OnboardingPageChanged(this.pageIndex);

  /// Current page index.
  final int pageIndex;

  @override
  List<Object?> get props => <Object?>[pageIndex];
}

/// Persists onboarding completion.
final class OnboardingCompleted extends OnboardingEvent {
  /// Creates the event.
  const OnboardingCompleted();
}

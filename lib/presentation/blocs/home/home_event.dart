part of 'home_bloc.dart';

/// Base event for [HomeBloc].
sealed class HomeEvent extends Equatable {
  /// Creates the event.
  const HomeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads the initial home content.
final class HomeStarted extends HomeEvent {
  /// Creates the event.
  const HomeStarted();
}

/// Refreshes the current home content.
final class HomeRefreshed extends HomeEvent {
  /// Creates the event.
  const HomeRefreshed();
}

/// Loads more content for the active tab.
final class HomeLoadMoreRequested extends HomeEvent {
  /// Creates the event.
  const HomeLoadMoreRequested();
}

/// Changes the selected bottom tab.
final class HomeTabChanged extends HomeEvent {
  /// Creates the event.
  const HomeTabChanged(this.tabIndex);

  /// New selected tab index.
  final int tabIndex;

  @override
  List<Object?> get props => <Object?>[tabIndex];
}

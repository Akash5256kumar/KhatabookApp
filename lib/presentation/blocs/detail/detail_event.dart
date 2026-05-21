part of 'detail_bloc.dart';

/// Base event for [DetailBloc].
sealed class DetailEvent extends Equatable {
  /// Creates the event.
  const DetailEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads detail data for an id.
final class DetailStarted extends DetailEvent {
  /// Creates the event.
  const DetailStarted({required this.id});

  /// Item id.
  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Retries the same detail request.
final class DetailRetried extends DetailEvent {
  /// Creates the event.
  const DetailRetried({required this.id});

  /// Item id.
  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

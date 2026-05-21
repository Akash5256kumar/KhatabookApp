part of 'detail_bloc.dart';

/// Base state for [DetailBloc].
sealed class DetailState extends Equatable {
  /// Creates the state.
  const DetailState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial detail state.
final class DetailInitial extends DetailState {
  /// Creates the state.
  const DetailInitial();
}

/// Loading detail state.
final class DetailLoading extends DetailState {
  /// Creates the state.
  const DetailLoading();
}

/// Success detail state.
final class DetailSuccess extends DetailState {
  /// Creates the state.
  const DetailSuccess(this.detail);

  /// Detail payload.
  final DetailEntity detail;

  @override
  List<Object?> get props => <Object?>[detail];
}

/// Empty detail state.
final class DetailEmpty extends DetailState {
  /// Creates the state.
  const DetailEmpty();
}

/// Failure detail state.
final class DetailFailure extends DetailState {
  /// Creates the state.
  const DetailFailure(this.message);

  /// Error message.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

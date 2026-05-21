import 'package:apna_business_app/domain/entities/detail_entity.dart';
import 'package:apna_business_app/domain/usecases/fetch_detail_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'detail_event.dart';
part 'detail_state.dart';

/// Loads detail data for the inner screen.
class DetailBloc extends Bloc<DetailEvent, DetailState> {
  /// Creates the bloc.
  DetailBloc({
    required FetchDetailUseCase fetchDetailUseCase,
  })  : _fetchDetailUseCase = fetchDetailUseCase,
        super(const DetailInitial()) {
    on<DetailStarted>(_onStarted);
    on<DetailRetried>(_onRetried);
  }

  final FetchDetailUseCase _fetchDetailUseCase;

  Future<void> _onStarted(
    DetailStarted event,
    Emitter<DetailState> emit,
  ) async {
    await _loadDetail(id: event.id, emit: emit);
  }

  Future<void> _onRetried(
    DetailRetried event,
    Emitter<DetailState> emit,
  ) async {
    await _loadDetail(id: event.id, emit: emit);
  }

  Future<void> _loadDetail({
    required String id,
    required Emitter<DetailState> emit,
  }) async {
    emit(const DetailLoading());
    final result = await _fetchDetailUseCase(id);
    result.fold(
      (failure) => emit(DetailFailure(failure.message)),
      (detail) => emit(DetailSuccess(detail)),
    );
  }
}

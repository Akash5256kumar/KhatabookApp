import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/data/datasources/remote/detail_remote_datasource.dart';
import 'package:apna_business_app/domain/entities/invoice_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'invoice_event.dart';
part 'invoice_state.dart';

/// Manages loading a single invoice from the real API.
class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  /// Creates the bloc.
  InvoiceBloc({required DetailRemoteDataSource detailDataSource})
      : _detailDataSource = detailDataSource,
        super(const InvoiceInitial()) {
    on<InvoiceStarted>(_onStarted);
    on<InvoiceRetried>(_onRetried);
  }

  final DetailRemoteDataSource _detailDataSource;

  Future<void> _onStarted(
    InvoiceStarted event,
    Emitter<InvoiceState> emit,
  ) async {
    await _load(event.id, emit);
  }

  Future<void> _onRetried(
    InvoiceRetried event,
    Emitter<InvoiceState> emit,
  ) async {
    await _load(event.id, emit);
  }

  Future<void> _load(String id, Emitter<InvoiceState> emit) async {
    emit(const InvoiceLoading());
    try {
      final InvoiceEntity invoice = await _detailDataSource.fetchInvoice(id);
      emit(InvoiceSuccess(invoice));
    } on NotFoundException {
      emit(const InvoiceEmpty());
    } on AppException catch (e) {
      emit(InvoiceFailure(e.message));
    } catch (_) {
      emit(const InvoiceFailure('Unable to load invoice. Please try again.'));
    }
  }
}

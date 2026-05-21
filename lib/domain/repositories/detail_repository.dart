import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/detail_entity.dart';
import 'package:dartz/dartz.dart';

/// Contract for the detail screen.
abstract interface class DetailRepository {
  /// Fetches a detail record by id.
  Future<Either<Failure, DetailEntity>> fetchDetail(String id);
}

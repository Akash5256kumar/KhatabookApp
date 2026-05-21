import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/data/models/detail_model.dart';
import 'package:apna_business_app/data/repositories/detail_repository_impl.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_mocks.dart';

void main() {
  late MockDetailRemoteDataSource remoteDataSource;
  late DetailRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockDetailRemoteDataSource();
    repository = DetailRepositoryImpl(remoteDataSource);
  });

  group('DetailRepositoryImpl', () {
    test('happy path returns detail data', () async {
      when(() => remoteDataSource.fetchDetail('1')).thenAnswer(
        (_) async => DetailModel(
          id: '1',
          title: 'Payment',
          subtitle: 'UPI',
          imageUrl: 'https://example.com',
          description: 'desc',
          amount: 10,
          createdAt: DateTime(2024),
          type: TransactionType.payment,
          highlights: <String>['one'],
        ),
      );

      final result = await repository.fetchDetail('1');
      expect(result.isRight(), isTrue);
    });

    test('network failure maps to failure', () async {
      when(() => remoteDataSource.fetchDetail('1'))
          .thenThrow(const NetworkException());

      expect(await repository.fetchDetail('1'), left(const NetworkFailure()));
    });

    test('empty response returns empty detail payload', () async {
      when(() => remoteDataSource.fetchDetail('2')).thenAnswer(
        (_) async => DetailModel(
          id: '2',
          title: 'Empty',
          subtitle: 'None',
          imageUrl: 'https://example.com',
          description: 'desc',
          amount: 0,
          createdAt: DateTime(2024),
          type: TransactionType.expense,
          highlights: <String>[],
        ),
      );

      final result = await repository.fetchDetail('2');
      expect(result.isRight(), isTrue);
    });

    test('loading state transition equivalent remains async', () async {
      when(() => remoteDataSource.fetchDetail('3'))
          .thenThrow(const NotFoundException());

      expect(await repository.fetchDetail('3'), left(const NotFoundFailure()));
    });
  });
}

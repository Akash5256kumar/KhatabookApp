import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/detail_entity.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:apna_business_app/domain/usecases/fetch_detail_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_mocks.dart';

void main() {
  late MockDetailRepository repository;

  setUp(() {
    repository = MockDetailRepository();
  });

  final DetailEntity detail = DetailEntity(
    id: '1',
    title: 'Payment',
    subtitle: 'UPI',
    imageUrl: 'https://example.com',
    description: 'desc',
    amount: 100,
    createdAt: DateTime(2024),
    type: TransactionType.payment,
    highlights: <String>['one'],
  );

  group('FetchDetailUseCase', () {
    test('happy path returns detail', () async {
      when(() => repository.fetchDetail('1'))
          .thenAnswer((_) async => Right(detail));

      expect(await FetchDetailUseCase(repository).call('1'), Right(detail));
    });

    test('network failure returns failure', () async {
      when(() => repository.fetchDetail('1'))
          .thenAnswer((_) async => const Left(NetworkFailure()));

      expect(
        await FetchDetailUseCase(repository).call('1'),
        const Left(NetworkFailure()),
      );
    });

    test('empty response returns empty highlights detail', () async {
      final DetailEntity emptyDetail = DetailEntity(
        id: '2',
        title: 'Empty',
        subtitle: 'none',
        imageUrl: 'https://example.com',
        description: 'desc',
        amount: 0,
        createdAt: DateTime(2024),
        type: TransactionType.expense,
        highlights: <String>[],
      );
      when(() => repository.fetchDetail('2'))
          .thenAnswer((_) async => Right(emptyDetail));

      expect(await FetchDetailUseCase(repository).call('2'), Right(emptyDetail));
    });

    test('loading transition equivalent remains awaitable', () async {
      when(() => repository.fetchDetail('1'))
          .thenAnswer((_) async => Right(detail));

      expect(await FetchDetailUseCase(repository).call('1'), Right(detail));
    });
  });
}

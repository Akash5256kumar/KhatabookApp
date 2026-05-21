import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/detail_entity.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:apna_business_app/presentation/blocs/detail/detail_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_mocks.dart';

void main() {
  late MockFetchDetailUseCase fetchDetailUseCase;

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

  setUp(() {
    fetchDetailUseCase = MockFetchDetailUseCase();
  });

  DetailBloc buildBloc() => DetailBloc(fetchDetailUseCase: fetchDetailUseCase);

  group('DetailBloc', () {
    blocTest<DetailBloc, DetailState>(
      'happy path emits success',
      build: () {
        when(() => fetchDetailUseCase('1'))
            .thenAnswer((_) async => Right(detail));
        return buildBloc();
      },
      act: (DetailBloc bloc) => bloc.add(const DetailStarted(id: '1')),
      expect: () => <DetailState>[
        const DetailLoading(),
        DetailSuccess(detail),
      ],
    );

    blocTest<DetailBloc, DetailState>(
      'network failure emits failure',
      build: () {
        when(() => fetchDetailUseCase('1'))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return buildBloc();
      },
      act: (DetailBloc bloc) => bloc.add(const DetailStarted(id: '1')),
      expect: () => <DetailState>[
        const DetailLoading(),
        const DetailFailure(
          'Internet connection unavailable. Please try again.',
        ),
      ],
    );

    blocTest<DetailBloc, DetailState>(
      'empty response emits empty state',
      build: () {
        when(() => fetchDetailUseCase('2')).thenAnswer(
          (_) async => Right(
            DetailEntity(
              id: '2',
              title: 'Empty',
              subtitle: 'UPI',
              imageUrl: 'https://example.com',
              description: 'desc',
              amount: 0,
              createdAt: DateTime(2024),
              type: TransactionType.expense,
              highlights: <String>[],
            ),
          ),
        );
        return buildBloc();
      },
      act: (DetailBloc bloc) => bloc.add(const DetailStarted(id: '2')),
      expect: () => <DetailState>[const DetailLoading(), const DetailEmpty()],
    );

    blocTest<DetailBloc, DetailState>(
      'loading state transition on retry emits loading then success',
      build: () {
        when(() => fetchDetailUseCase('1'))
            .thenAnswer((_) async => Right(detail));
        return buildBloc();
      },
      act: (DetailBloc bloc) => bloc.add(const DetailRetried(id: '1')),
      expect: () => <DetailState>[
        const DetailLoading(),
        DetailSuccess(detail),
      ],
    );
  });
}

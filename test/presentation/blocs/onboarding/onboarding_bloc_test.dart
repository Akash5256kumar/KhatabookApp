import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_mocks.dart';

void main() {
  late MockCompleteOnboardingUseCase useCase;

  setUp(() {
    useCase = MockCompleteOnboardingUseCase();
  });

  group('OnboardingBloc', () {
    blocTest<OnboardingBloc, OnboardingState>(
      'happy path updates page',
      build: () => OnboardingBloc(completeOnboardingUseCase: useCase),
      act: (OnboardingBloc bloc) => bloc.add(const OnboardingPageChanged(1)),
      expect: () => <OnboardingState>[
        const OnboardingSuccess(pageIndex: 1, isCompleted: false),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'network failure equivalent emits failure',
      build: () {
        when(() => useCase()).thenAnswer((_) async => const Left(CacheFailure()));
        return OnboardingBloc(completeOnboardingUseCase: useCase);
      },
      act: (OnboardingBloc bloc) => bloc.add(const OnboardingCompleted()),
      expect: () => <OnboardingState>[
        const OnboardingLoading(pageIndex: 0),
        const OnboardingFailure(
          pageIndex: 0,
          message: 'We could not load saved information right now.',
        ),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'empty response equivalent starts at first page',
      build: () => OnboardingBloc(completeOnboardingUseCase: useCase),
      expect: () => <OnboardingState>[],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'loading state transition emits completion success',
      build: () {
        when(() => useCase()).thenAnswer((_) async => right(unit));
        return OnboardingBloc(completeOnboardingUseCase: useCase);
      },
      act: (OnboardingBloc bloc) => bloc.add(const OnboardingCompleted()),
      expect: () => <OnboardingState>[
        const OnboardingLoading(pageIndex: 0),
        const OnboardingSuccess(pageIndex: 0, isCompleted: true),
      ],
    );
  });
}

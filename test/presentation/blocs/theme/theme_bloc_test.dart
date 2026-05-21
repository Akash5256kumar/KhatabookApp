import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/presentation/blocs/theme/theme_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_mocks.dart';

void main() {
  late MockGetThemeModeUseCase getThemeModeUseCase;
  late MockUpdateThemeModeUseCase updateThemeModeUseCase;

  setUp(() {
    getThemeModeUseCase = MockGetThemeModeUseCase();
    updateThemeModeUseCase = MockUpdateThemeModeUseCase();
  });

  ThemeBloc buildBloc() => ThemeBloc(
        getThemeModeUseCase: getThemeModeUseCase,
        updateThemeModeUseCase: updateThemeModeUseCase,
      );

  group('ThemeBloc', () {
    blocTest<ThemeBloc, ThemeState>(
      'happy path loads persisted theme',
      build: () {
        when(() => getThemeModeUseCase())
            .thenAnswer((_) async => const Right(ThemeMode.dark));
        return buildBloc();
      },
      act: (ThemeBloc bloc) => bloc.add(const ThemeStarted()),
      expect: () => <ThemeState>[
        const ThemeLoading(themeMode: ThemeMode.system),
        const ThemeSuccess(themeMode: ThemeMode.dark),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'network failure equivalent emits failure',
      build: () {
        when(() => getThemeModeUseCase())
            .thenAnswer((_) async => const Left(CacheFailure()));
        return buildBloc();
      },
      act: (ThemeBloc bloc) => bloc.add(const ThemeStarted()),
      expect: () => <ThemeState>[
        const ThemeLoading(themeMode: ThemeMode.system),
        const ThemeFailure(
          themeMode: ThemeMode.system,
          message: 'We could not load saved information right now.',
        ),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'empty response equivalent resolves to system theme',
      build: () {
        when(() => getThemeModeUseCase())
            .thenAnswer((_) async => const Right(ThemeMode.system));
        return buildBloc();
      },
      act: (ThemeBloc bloc) => bloc.add(const ThemeStarted()),
      expect: () => <ThemeState>[
        const ThemeLoading(themeMode: ThemeMode.system),
        const ThemeSuccess(themeMode: ThemeMode.system),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'loading state transition toggles theme',
      build: () {
        when(() => updateThemeModeUseCase(ThemeMode.dark))
            .thenAnswer((_) async => const Right(ThemeMode.dark));
        return buildBloc();
      },
      act: (ThemeBloc bloc) => bloc.add(const ThemeToggled()),
      expect: () => <ThemeState>[
        const ThemeLoading(themeMode: ThemeMode.dark),
        const ThemeSuccess(themeMode: ThemeMode.dark),
      ],
    );
  });
}

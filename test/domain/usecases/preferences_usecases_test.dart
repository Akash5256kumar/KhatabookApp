import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/usecases/complete_onboarding_usecase.dart';
import 'package:apna_business_app/domain/usecases/get_language_usecase.dart';
import 'package:apna_business_app/domain/usecases/get_theme_mode_usecase.dart';
import 'package:apna_business_app/domain/usecases/update_language_usecase.dart';
import 'package:apna_business_app/domain/usecases/update_theme_mode_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_mocks.dart';

void main() {
  late MockPreferencesRepository repository;

  setUp(() {
    repository = MockPreferencesRepository();
  });

  group('Preferences use cases', () {
    test('happy path returns persisted values', () async {
      when(() => repository.setOnboardingSeen())
          .thenAnswer((_) async => right(unit));
      when(() => repository.getThemeMode())
          .thenAnswer((_) async => const Right(ThemeMode.dark));
      when(() => repository.updateThemeMode(ThemeMode.light))
          .thenAnswer((_) async => const Right(ThemeMode.light));
      when(() => repository.getLanguage())
          .thenAnswer((_) async => const Right('hi'));
      when(() => repository.updateLanguage('en'))
          .thenAnswer((_) async => const Right('en'));

      expect(await CompleteOnboardingUseCase(repository).call(), right(unit));
      expect(await GetThemeModeUseCase(repository).call(), const Right(ThemeMode.dark));
      expect(
        await UpdateThemeModeUseCase(repository).call(ThemeMode.light),
        const Right(ThemeMode.light),
      );
      expect(await GetLanguageUseCase(repository).call(), const Right('hi'));
      expect(await UpdateLanguageUseCase(repository).call('en'), const Right('en'));
    });

    test('network failure equivalent returns cached failure', () async {
      when(() => repository.getThemeMode())
          .thenAnswer((_) async => const Left(CacheFailure()));

      expect(
        await GetThemeModeUseCase(repository).call(),
        const Left(CacheFailure()),
      );
    });

    test('empty response returns fallback-like empty language', () async {
      when(() => repository.getLanguage())
          .thenAnswer((_) async => const Right(''));

      expect(await GetLanguageUseCase(repository).call(), const Right(''));
    });

    test('loading transition equivalent remains awaitable', () async {
      when(() => repository.updateThemeMode(ThemeMode.dark))
          .thenAnswer((_) async => const Right(ThemeMode.dark));

      expect(
        await UpdateThemeModeUseCase(repository).call(ThemeMode.dark),
        const Right(ThemeMode.dark),
      );
    });
  });
}

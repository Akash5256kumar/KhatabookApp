import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/data/repositories/preferences_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_mocks.dart';

void main() {
  late MockAppLocalDataSource localDataSource;
  late PreferencesRepositoryImpl repository;

  setUp(() {
    localDataSource = MockAppLocalDataSource();
    repository = PreferencesRepositoryImpl(localDataSource);
  });

  group('PreferencesRepositoryImpl', () {
    test('happy path returns persisted values', () async {
      when(() => localDataSource.isOnboardingSeen()).thenReturn(true);
      when(() => localDataSource.getThemeMode()).thenReturn('dark');
      when(() => localDataSource.getLanguage()).thenReturn('hi');
      when(() => localDataSource.saveThemeMode('light')).thenAnswer((_) async {});
      when(() => localDataSource.saveLanguage('en')).thenAnswer((_) async {});
      when(() => localDataSource.setOnboardingSeen()).thenAnswer((_) async {});

      expect(await repository.isOnboardingSeen(), const Right(true));
      expect(await repository.getThemeMode(), const Right(ThemeMode.dark));
      expect(await repository.getLanguage(), const Right('hi'));
      expect(await repository.updateThemeMode(ThemeMode.light), const Right(ThemeMode.light));
      expect(await repository.updateLanguage('en'), const Right('en'));
      expect(await repository.setOnboardingSeen(), right(unit));
    });

    test('network failure equivalent maps cache exception', () async {
      when(() => localDataSource.getThemeMode()).thenThrow(const CacheException());

      expect(await repository.getThemeMode(), const Left(CacheFailure()));
    });

    test('empty response preserves blank language', () async {
      when(() => localDataSource.getLanguage()).thenReturn('');

      expect(await repository.getLanguage(), const Right(''));
    });

    test('loading state transition equivalent updates theme asynchronously', () async {
      when(() => localDataSource.saveThemeMode('dark')).thenAnswer((_) async {});

      expect(await repository.updateThemeMode(ThemeMode.dark), const Right(ThemeMode.dark));
    });
  });
}

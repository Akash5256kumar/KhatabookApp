import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/user_entity.dart';
import 'package:apna_business_app/presentation/blocs/profile/profile_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_mocks.dart';

void main() {
  late MockFetchProfileUseCase fetchProfileUseCase;
  late MockGetLanguageUseCase getLanguageUseCase;
  late MockUpdateLanguageUseCase updateLanguageUseCase;

  const UserEntity user = UserEntity(id: '1', name: 'User', email: 'a@b.com');

  setUp(() {
    fetchProfileUseCase = MockFetchProfileUseCase();
    getLanguageUseCase = MockGetLanguageUseCase();
    updateLanguageUseCase = MockUpdateLanguageUseCase();
  });

  ProfileBloc buildBloc() => ProfileBloc(
        fetchProfileUseCase: fetchProfileUseCase,
        getLanguageUseCase: getLanguageUseCase,
        updateLanguageUseCase: updateLanguageUseCase,
      );

  group('ProfileBloc', () {
    blocTest<ProfileBloc, ProfileState>(
      'happy path loads profile data',
      build: () {
        when(() => fetchProfileUseCase())
            .thenAnswer((_) async => const Right(user));
        when(() => getLanguageUseCase())
            .thenAnswer((_) async => const Right('hi'));
        return buildBloc();
      },
      act: (ProfileBloc bloc) => bloc.add(const ProfileStarted()),
      expect: () => <ProfileState>[
        const ProfileLoading(),
        const ProfileSuccess(user: user, languageCode: 'hi'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'network failure emits failure',
      build: () {
        when(() => fetchProfileUseCase())
            .thenAnswer((_) async => const Left(NetworkFailure()));
        when(() => getLanguageUseCase())
            .thenAnswer((_) async => const Right('hi'));
        return buildBloc();
      },
      act: (ProfileBloc bloc) => bloc.add(const ProfileStarted()),
      expect: () => <ProfileState>[
        const ProfileLoading(),
        const ProfileFailure(
          'Internet connection unavailable. Please try again.',
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'empty response equivalent keeps blank language',
      build: () {
        when(() => fetchProfileUseCase())
            .thenAnswer((_) async => const Right(user));
        when(() => getLanguageUseCase())
            .thenAnswer((_) async => const Right(''));
        return buildBloc();
      },
      act: (ProfileBloc bloc) => bloc.add(const ProfileStarted()),
      expect: () => <ProfileState>[
        const ProfileLoading(),
        const ProfileSuccess(user: user, languageCode: ''),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'loading state transition updates language',
      build: () {
        when(() => updateLanguageUseCase('en'))
            .thenAnswer((_) async => const Right('en'));
        return buildBloc();
      },
      seed: () => const ProfileSuccess(user: user, languageCode: 'hi'),
      act: (ProfileBloc bloc) => bloc.add(const ProfileLanguageChanged('en')),
      expect: () => <ProfileState>[
        const ProfileLoading(),
        const ProfileSuccess(user: user, languageCode: 'en'),
      ],
    );
  });
}

import 'package:apna_business_app/app/routes/route_names.dart';
import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:apna_business_app/core/utils/extensions/string_extension.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:apna_business_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:apna_business_app/presentation/blocs/profile/profile_bloc.dart';
import 'package:apna_business_app/presentation/blocs/theme/theme_bloc.dart';
import 'package:apna_business_app/presentation/screens/profile/widgets/profile_loading_view.dart';
import 'package:apna_business_app/presentation/widgets/error_views/branded_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Full profile and settings screen.
class ProfileScreen extends StatefulWidget {
  /// Creates the profile screen.
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ValueNotifier<bool> _notificationsEnabled = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _notificationsEnabled.dispose();
    super.dispose();
  }

  Future<void> _selectLanguage() async {
    final String? selectedLanguage = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Hindi'),
                onTap: () => Navigator.pop(context, AppConstants.langHindi),
              ),
              ListTile(
                title: const Text('English'),
                onTap: () => Navigator.pop(context, AppConstants.langEnglish),
              ),
            ],
          ),
        );
      },
    );

    if (selectedLanguage != null && mounted) {
      context.read<ProfileBloc>().add(ProfileLanguageChanged(selectedLanguage));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<ProfileBloc, ProfileState>(
          listener: (BuildContext context, ProfileState state) {
            if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (BuildContext context, AuthState state) {
            if (state is AuthSuccess &&
                state.session.status == AuthStatus.unauthenticated) {
              context.go(RouteNames.login);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile & Settings')),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (BuildContext context, ProfileState state) {
            return switch (state) {
              ProfileLoading() => const ProfileLoadingView(),
              ProfileFailure() => BrandedErrorView(
                  message: state.message,
                  onRetry: () =>
                      context.read<ProfileBloc>().add(const ProfileStarted()),
                ),
              ProfileSuccess() => _ProfileContent(
                  state: state,
                  notificationsEnabled: _notificationsEnabled,
                  onLanguageTap: _selectLanguage,
                ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.state,
    required this.notificationsEnabled,
    required this.onLanguageTap,
  });

  final ProfileSuccess state;
  final ValueNotifier<bool> notificationsEnabled;
  final VoidCallback onLanguageTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceLG),
              child: Row(
                children: <Widget>[
                  Container(
                    width: AppDimensions.avatarLG,
                    height: AppDimensions.avatarLG,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        state.user.name.initials,
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceLG),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(state.user.name, style: AppTextStyles.headline),
                        const SizedBox(height: AppDimensions.spaceXS),
                        Text(state.user.email, style: AppTextStyles.bodyMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (index == 1) {
          return Card(
            margin: const EdgeInsets.only(top: AppDimensions.spaceMD),
            child: ValueListenableBuilder<bool>(
              valueListenable: notificationsEnabled,
              builder: (BuildContext context, bool enabled, _) {
                return SwitchListTile(
                  value: enabled,
                  title: const Text('Notifications'),
                  subtitle: const Text('Reminder and payment alerts'),
                  onChanged: (bool value) => notificationsEnabled.value = value,
                );
              },
            ),
          );
        }

        if (index == 2) {
          return Card(
            margin: const EdgeInsets.only(top: AppDimensions.spaceMD),
            child: BlocBuilder<ThemeBloc, ThemeState>(
              buildWhen: (ThemeState previous, ThemeState current) =>
                  previous.themeMode != current.themeMode,
              builder: (BuildContext context, ThemeState themeState) {
                return SwitchListTile(
                  value: themeState.themeMode == ThemeMode.dark,
                  title: const Text('Dark Theme'),
                  subtitle: const Text('Persist across restarts'),
                  onChanged: (_) {
                    context.read<ThemeBloc>().add(const ThemeToggled());
                  },
                );
              },
            ),
          );
        }

        if (index == 3) {
          return Card(
            margin: const EdgeInsets.only(top: AppDimensions.spaceMD),
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('Language'),
              subtitle: Text(
                state.languageCode == AppConstants.langHindi ? 'Hindi' : 'English',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: onLanguageTap,
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.only(top: AppDimensions.spaceMD),
          child: ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
        );
      },
    );
  }
}

import 'package:apna_business_app/app/routes/route_names.dart';
import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:apna_business_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:apna_business_app/presentation/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Phone-number entry screen — first step of the OTP auth flow.
class LoginScreen extends StatefulWidget {
  /// Creates the login screen.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final ValueNotifier<String?> _fieldError = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthFlowResetRequested());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _fieldError.dispose();
    super.dispose();
  }

  void _submit() {
    final String phone = _phoneController.text.trim();
    final String digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      _fieldError.value = 'Enter a valid 10-digit mobile number';
      return;
    }
    _fieldError.value = null;
    context.read<AuthBloc>().add(AuthSendOtpRequested(phone: digits));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthOtpSent) {
          context.push(RouteNames.otpVerify, extra: state.phone);
        }
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is AuthValidationError) {
          _fieldError.value = state.message;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePadding,
              vertical: AppDimensions.space3XL,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _AppBrand(),
                  const SizedBox(height: AppDimensions.space3XL),
                  const Text('Login karein', style: AppTextStyles.display),
                  const SizedBox(height: AppDimensions.spaceSM),
                  const Text(
                    'Hamara AI automatically samajh leta hai',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppDimensions.spaceXXL),
                  _PhoneField(
                    controller: _phoneController,
                    errorNotifier: _fieldError,
                  ),
                  const SizedBox(height: AppDimensions.spaceXXL),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (AuthState p, AuthState c) =>
                        (p is AuthLoading) != (c is AuthLoading),
                    builder: (BuildContext context, AuthState state) {
                      return PrimaryButton(
                        label: 'Send OTP',
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceXL),
                  Center(
                    child: Text(
                      'Demo: OTP is 123456',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          child: const Icon(Icons.store_outlined, color: Colors.white, size: 28),
        ),
        const SizedBox(width: AppDimensions.spaceMD),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(AppConstants.appName, style: AppTextStyles.title),
            Text(
              'Business Khata',
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.errorNotifier,
  });

  final TextEditingController controller;
  final ValueNotifier<String?> errorNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: errorNotifier,
      builder: (BuildContext context, String? error, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Mobile Number', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.spaceSM),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              textInputAction: TextInputAction.done,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (_) => errorNotifier.value = null,
              decoration: InputDecoration(
                counterText: '',
                hintText: '98765 43210',
                errorText: error,
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceMD,
                    vertical: AppDimensions.spaceLG,
                  ),
                  child: Text(
                    AppConstants.defaultCountryCode,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

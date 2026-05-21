import 'dart:async';

import 'package:apna_business_app/app/routes/route_names.dart';
import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:apna_business_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:apna_business_app/presentation/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Six-digit OTP entry screen.
class OtpVerifyScreen extends StatefulWidget {
  /// Creates the OTP screen.
  const OtpVerifyScreen({required this.phone, super.key});

  /// Phone the OTP was dispatched to.
  final String phone;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final List<TextEditingController> _controllers = List.generate(
    AppConstants.otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    AppConstants.otpLength,
    (_) => FocusNode(),
  );

  late final ValueNotifier<int> _cooldown;
  Timer? _timer;
  final ValueNotifier<String?> _fieldError = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _cooldown = ValueNotifier<int>(AppConstants.otpResendCooldownSecs);
    _startCountdown();
    context.read<AuthBloc>().add(const AuthFlowResetRequested());
    // Auto-focus first box
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNodes.first.requestFocus(),
    );
  }

  void _startCountdown() {
    _timer?.cancel();
    _cooldown.value = AppConstants.otpResendCooldownSecs;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_cooldown.value <= 1) {
        t.cancel();
        _cooldown.value = 0;
      } else {
        _cooldown.value--;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final FocusNode n in _focusNodes) {
      n.dispose();
    }
    _cooldown.dispose();
    _fieldError.dispose();
    super.dispose();
  }

  String get _otpValue =>
      _controllers.map((TextEditingController c) => c.text).join();

  void _submit() {
    final String otp = _otpValue;
    if (otp.length != AppConstants.otpLength) {
      _fieldError.value = 'Please enter the complete ${AppConstants.otpLength}-digit OTP';
      return;
    }
    _fieldError.value = null;
    context.read<AuthBloc>().add(
          AuthVerifyOtpRequested(phone: widget.phone, otp: otp),
        );
  }

  void _resendOtp() {
    for (final TextEditingController c in _controllers) {
      c.clear();
    }
    _fieldError.value = null;
    context.read<AuthBloc>().add(AuthSendOtpRequested(phone: widget.phone));
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthNeedsBusinessSetup) {
          context.pushReplacement(
            RouteNames.businessSetup,
            extra: state.phone,
          );
        }
        if (state is AuthSuccess &&
            state.session.status == AuthStatus.authenticated) {
          context.go(RouteNames.home);
        }
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is AuthValidationError) {
          _fieldError.value = state.message;
        }
        // Re-sent OTP successfully
        if (state is AuthOtpSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePadding,
              vertical: AppDimensions.spaceLG,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('OTP Verify karein', style: AppTextStyles.display),
                  const SizedBox(height: AppDimensions.spaceSM),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMuted,
                      children: <TextSpan>[
                        const TextSpan(text: '6 digit ka code daalen — '),
                        TextSpan(
                          text: '+91 ${_formatPhone(widget.phone)}',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space3XL),
                  _OtpBoxRow(
                    controllers: _controllers,
                    focusNodes: _focusNodes,
                    onCompleted: _submit,
                    errorNotifier: _fieldError,
                  ),
                  const SizedBox(height: AppDimensions.spaceXXL),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (AuthState p, AuthState c) =>
                        (p is AuthLoading) != (c is AuthLoading),
                    builder: (BuildContext context, AuthState state) {
                      return PrimaryButton(
                        label: 'Verify OTP',
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceXL),
                  Center(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _cooldown,
                      builder: (BuildContext context, int seconds, _) {
                        if (seconds > 0) {
                          return Text(
                            'Resend in ${seconds}s',
                            style: AppTextStyles.label,
                          );
                        }
                        return TextButton(
                          onPressed: _resendOtp,
                          child: const Text('Resend OTP'),
                        );
                      },
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

  String _formatPhone(String phone) {
    if (phone.length < 10) return phone;
    return '${phone.substring(0, 5)} ${phone.substring(5)}';
  }
}

class _OtpBoxRow extends StatelessWidget {
  const _OtpBoxRow({
    required this.controllers,
    required this.focusNodes,
    required this.onCompleted,
    required this.errorNotifier,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onCompleted;
  final ValueNotifier<String?> errorNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: errorNotifier,
      builder: (BuildContext context, String? error, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                AppConstants.otpLength,
                (int index) => _OtpBox(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  hasError: error != null,
                  onChanged: (String val) {
                    errorNotifier.value = null;
                    if (val.isNotEmpty && index < AppConstants.otpLength - 1) {
                      focusNodes[index + 1].requestFocus();
                    }
                    if (val.isNotEmpty && index == AppConstants.otpLength - 1) {
                      onCompleted();
                    }
                  },
                  onBackspace: () {
                    if (controllers[index].text.isEmpty && index > 0) {
                      focusNodes[index - 1].requestFocus();
                      controllers[index - 1].clear();
                    }
                  },
                ),
              ),
            ),
            if (error != null) ...<Widget>[
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                error,
                style: AppTextStyles.label.copyWith(color: AppColors.error),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          style: AppTextStyles.headline,
        ),
      ),
    );
  }
}

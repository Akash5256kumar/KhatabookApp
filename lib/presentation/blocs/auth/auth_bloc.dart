import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:apna_business_app/domain/usecases/check_auth_status_usecase.dart';
import 'package:apna_business_app/domain/usecases/logout_usecase.dart';
import 'package:apna_business_app/domain/usecases/send_otp_usecase.dart';
import 'package:apna_business_app/domain/usecases/setup_business_usecase.dart';
import 'package:apna_business_app/domain/usecases/verify_otp_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Manages the complete authentication lifecycle:
/// bootstrap → phone login → OTP → business setup → home.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates the bloc.
  AuthBloc({
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required SendOtpUseCase sendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required SetupBusinessUseCase setupBusinessUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _sendOtpUseCase = sendOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _setupBusinessUseCase = setupBusinessUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial()) {
    on<AuthBootstrapRequested>(_onBootstrap);
    on<AuthFlowResetRequested>(_onFlowReset);
    on<AuthSendOtpRequested>(_onSendOtp);
    on<AuthVerifyOtpRequested>(_onVerifyOtp);
    on<AuthSetupBusinessRequested>(_onSetupBusiness);
    on<AuthLogoutRequested>(_onLogout);
  }

  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final SetupBusinessUseCase _setupBusinessUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> _onBootstrap(
    AuthBootstrapRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _checkAuthStatusUseCase();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (session) => emit(AuthSuccess(session)),
    );
  }

  void _onFlowReset(
    AuthFlowResetRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthInitial());
  }

  Future<void> _onSendOtp(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    final String digits = event.phone.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      emit(const AuthValidationError('Enter a valid 10-digit mobile number'));
      return;
    }
    emit(const AuthLoading());
    final result = await _sendOtpUseCase(phone: digits);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthOtpSent(phone: digits)),
    );
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.otp.trim().length != 6 ||
        !RegExp(r'^\d{6}$').hasMatch(event.otp.trim())) {
      emit(const AuthValidationError('Enter the 6-digit OTP'));
      return;
    }
    emit(const AuthLoading());
    final result = await _verifyOtpUseCase(
      phone: event.phone,
      otp: event.otp.trim(),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (session) {
        if (session.status == AuthStatus.needsBusinessSetup) {
          emit(AuthNeedsBusinessSetup(phone: event.phone));
        } else {
          emit(AuthSuccess(session));
        }
      },
    );
  }

  Future<void> _onSetupBusiness(
    AuthSetupBusinessRequested event,
    Emitter<AuthState> emit,
  ) async {
    final String fullName = event.fullName.trim();
    final String businessName = event.businessName.trim();
    final String? location = event.location?.trim();

    if (fullName.length < 2) {
      emit(
          const AuthValidationError('Full name must be at least 2 characters'));
      return;
    }
    if (businessName.length < 2) {
      emit(const AuthValidationError(
          'Business name must be at least 2 characters'));
      return;
    }
    if (location != null && location.isNotEmpty && location.length < 2) {
      emit(const AuthValidationError('Location must be at least 2 characters'));
      return;
    }

    emit(const AuthLoading());
    final result = await _setupBusinessUseCase(
      fullName: fullName,
      businessName: businessName,
      location: location != null && location.isNotEmpty ? location : null,
      shopType: event.shopType,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (session) => emit(AuthSuccess(session)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _logoutUseCase();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(
        const AuthSuccess(
            AuthSessionEntity(status: AuthStatus.unauthenticated)),
      ),
    );
  }
}

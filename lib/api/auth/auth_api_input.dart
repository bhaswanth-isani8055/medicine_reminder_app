import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_api_input.freezed.dart';
part 'auth_api_input.g.dart';

/// Input body type for /auth/create-account in AuthApiClient.
@freezed
class CreateAccountInput with _$CreateAccountInput {
  const factory CreateAccountInput({
    required String username,
    required String email,
    required String password,
  }) = _CreateAccountInput;

  factory CreateAccountInput.fromJson(Map<String, dynamic> json) =>
      _$CreateAccountInputFromJson(json);
}

/// Input body type for /auth/login in AuthApiClient.
@freezed
class LoginInput with _$LoginInput {
  const factory LoginInput({required String email, required String password}) =
      _LoginInput;

  factory LoginInput.fromJson(Map<String, dynamic> json) =>
      _$LoginInputFromJson(json);
}

/// Input body type for /auth/send-otp in AuthApiClient
@freezed
class SendOTPInput with _$SendOTPInput {
  const factory SendOTPInput({
    required String email,
    required bool isRegister,
  }) = _SendOTPInput;

  factory SendOTPInput.fromJson(Map<String, dynamic> json) =>
      _$SendOTPInputFromJson(json);
}

/// Input body type for /auth/forgot-password in AuthApiClient
@freezed
class ForgotPasswordInput with _$ForgotPasswordInput {
  const factory ForgotPasswordInput({
    required String email,
    required String newPassword,
    required String otp,
  }) = _ForgotPasswordInput;

  factory ForgotPasswordInput.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordInputFromJson(json);
}
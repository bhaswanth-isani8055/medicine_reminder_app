import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:medicine_reminder_app/api/api.dart';
import 'package:medicine_reminder_app/auth/domain/domain.dart';
import 'package:medicine_reminder_app/core/core.dart';

abstract class BaseAuthServerRepository {
  /// Returns UserApiResponse if the response status code from the server is 200
  /// else returns InfrastructureFailure such as
  /// - invalidData
  /// - userAlreadyExists
  /// - serverError
  Future<Either<InfrastructureFailure, UserApiResponse>>
      createAccountUsingEmailAndPassword({
    required Username username,
    required EmailAddress email,
    required Password password,
  });

  /// Returns UserApiResponse if the response status code from the server is 200
  /// else returns InfrastructureFailure such as
  /// - invalidData
  /// - invalidCredentials
  /// - serverError
  Future<Either<InfrastructureFailure, UserApiResponse>>
      loginUsingEmailAndPassword({
    required EmailAddress email,
    required Password password,
  });

  /// Returns SendOTPResponse if the response status code from the server is 200
  /// else returns InfrastructureFailure such as
  /// - invalidData
  /// - userAlreadyExists
  /// - invalidCredentials
  Future<Either<InfrastructureFailure, SendOTPResponse>> sendOTP({
    required EmailAddress email,
    required bool isRegister,
  });

  /// Returns ForgotPasswordResponse if the response status code from the server
  /// is 200 else returns InfrastructureFailure such as
  /// - invalidData
  /// - invalidCredentials
  Future<Either<InfrastructureFailure, ForgotPasswordResponse>> forgotPassword({
    required EmailAddress email,
    required Password newPassword,
    required OTP otp,
  });
}

final authServerRepositoryProvider = Provider<AuthServerRepository>(
  (ref) {
    final dio = ref.watch(dioClientProvider);
    final authApiClient = AuthApiClient(dio, baseUrl: dotenv.env['PROD_URL']!);

    return AuthServerRepository(authApiClient);
  },
);

class AuthServerRepository implements BaseAuthServerRepository {
  AuthServerRepository(this.authApiClient);

  final AuthApiClient authApiClient;

  @override
  Future<Either<InfrastructureFailure, UserApiResponse>>
      createAccountUsingEmailAndPassword({
    required Username username,
    required EmailAddress email,
    required Password password,
  }) async {
    final emailStr = email.value;
    final usernameStr = username.value;
    final passwordStr = password.value;

    // Checks if all the fields are valid or not. If any one field is invalid
    // then it returns an InfrastructureFailure.
    if (!username.isValid() || !email.isValid() || !password.isValid()) {
      return left(const CoreInfrastructureFailure.invalidData());
    } else {
      final createAccountInput = CreateAccountInput(
        username: usernameStr,
        email: emailStr,
        password: passwordStr,
      );

      try {
        // Sends a request to the server for creating a new user.
        final createAccountResponse =
            await authApiClient.createAccount(createAccountInput);

        // If the response status code is 200 then it returns the
        // AuthResponseApi.
        return right(createAccountResponse);
      } on DioError catch (error) {
        // If there is any error the it returns an InfrastructureFailure.
        final response = error.response;

        if (response != null) {
          try {
            final userApiResponse =
                UserApiResponse.fromJson(response.data as Map<String, dynamic>);

            switch (userApiResponse.error) {
              case ServerFailures.invalidData:
                return left(const CoreInfrastructureFailure.invalidData());
              case ServerFailures.userAlreadyExists:
                return left(
                  const AuthInfrastructureFailure.userAlreadyExists(),
                );
            }
          } catch (_) {}
        }

        return left(const CoreInfrastructureFailure.serverError());
      }
    }
  }

  @override
  Future<Either<InfrastructureFailure, UserApiResponse>>
      loginUsingEmailAndPassword({
    required EmailAddress email,
    required Password password,
  }) async {
    final emailStr = email.value;
    final passwordStr = password.value;

    // Checks if all the fields are valid or not. If any one field is invalid
    // then it returns an InfrastructureFailure.
    if (!email.isValid() || !password.isValid()) {
      return left(const CoreInfrastructureFailure.invalidData());
    } else {
      final loginInput = LoginInput(
        email: emailStr,
        password: passwordStr,
      );

      try {
        // Sends a request to the server for logging in the user.
        final loginUserResponse = await authApiClient.loginUser(loginInput);

        // If the response status code is 200 then it returns the
        // AuthResponseApi.
        return right(loginUserResponse);
      } on DioError catch (error) {
        // If there is any error the it returns an InfrastructureFailure.
        final response = error.response;

        if (response != null) {
          try {
            final userApiResponse =
                UserApiResponse.fromJson(response.data as Map<String, dynamic>);

            switch (userApiResponse.error) {
              case ServerFailures.invalidData:
                return left(const CoreInfrastructureFailure.invalidData());
              case ServerFailures.invalidCredentials:
                return left(
                  const AuthInfrastructureFailure.invalidCredentials(),
                );
            }
          } catch (_) {}
        }

        return left(const CoreInfrastructureFailure.serverError());
      }
    }
  }

  @override
  Future<Either<InfrastructureFailure, ForgotPasswordResponse>> forgotPassword({
    required EmailAddress email,
    required Password newPassword,
    required OTP otp,
  }) async {
    final emailStr = email.value;
    final newPasswordStr = newPassword.value;
    final otpStr = otp.value;

    // Checks if all the fields are valid or not. If any one field is invalid
    // then it returns an InfrastructureFailure.
    if (!email.isValid() || !newPassword.isValid() || !otp.isValid()) {
      return left(const CoreInfrastructureFailure.invalidData());
    } else {
      final forgotPasswordInput = ForgotPasswordInput(
        email: emailStr,
        newPassword: newPasswordStr,
        otp: otpStr,
      );

      try {
        // Sends a request to the server to reset the password
        final forgotPasswordResponse =
            await authApiClient.forgotPassword(forgotPasswordInput);

        // If the response status code is 200 then it returns the
        // AuthResponseApi.
        return right(forgotPasswordResponse);
      } on DioError catch (error) {
        // If there is any error the it returns an InfrastructureFailure.
        final response = error.response;

        if (response != null) {
          try {
            final userApiResponse =
                UserApiResponse.fromJson(response.data as Map<String, dynamic>);

            switch (userApiResponse.error) {
              case ServerFailures.invalidData:
                return left(const CoreInfrastructureFailure.invalidData());
              case ServerFailures.invalidCredentials:
                return left(
                  const AuthInfrastructureFailure.invalidCredentials(),
                );
            }
          } catch (_) {}
        }

        return left(const CoreInfrastructureFailure.serverError());
      }
    }
  }

  @override
  Future<Either<InfrastructureFailure, SendOTPResponse>> sendOTP({
    required EmailAddress email,
    required bool isRegister,
  }) async {
    final emailStr = email.value;

    // Checks if all the fields are valid or not. If any one field is invalid
    // then it returns an InfrastructureFailure.
    if (!email.isValid()) {
      return left(const CoreInfrastructureFailure.invalidData());
    } else {
      final sendOTPInput = SendOTPInput(
        email: emailStr,
        isRegister: isRegister,
      );

      try {
        // Sends a request to the server for sending OTP to the user's email
        final sendOTPResponse =
            await authApiClient.sendOTPToEmail(sendOTPInput);

        // If the response status code is 200 then it returns the
        // AuthResponseApi.
        return right(sendOTPResponse);
      } on DioError catch (error) {
        // If there is any error the it returns an InfrastructureFailure.
        final response = error.response;

        if (response != null) {
          try {
            final userApiResponse =
                UserApiResponse.fromJson(response.data as Map<String, dynamic>);

            switch (userApiResponse.error) {
              case ServerFailures.invalidData:
                return left(const CoreInfrastructureFailure.invalidData());
              case ServerFailures.invalidCredentials:
                return left(
                  const AuthInfrastructureFailure.invalidCredentials(),
                );
              case ServerFailures.userAlreadyExists:
                return left(
                  const AuthInfrastructureFailure.userAlreadyExists(),
                );
            }
          } catch (_) {}
        }

        return left(const CoreInfrastructureFailure.serverError());
      }
    }
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medicine_reminder_app/core/domain/user/user_object_converters.dart';
import 'package:medicine_reminder_app/core/domain/user/user_objects.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed

/// User class is a freezed and JSON serializable class which consists of
///   - EmailAddress email
///   - Password password
///   - Username username
///
/// Remember that calling toJson with invalid inputs will result in an app
/// crash.
class User with _$User {
  const factory User({
    @EmailAddressConverter() required EmailAddress email,
    @UsernameConverter() required Username name,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

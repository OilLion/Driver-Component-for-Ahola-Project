//
//  Generated code. Do not modify.
//  source: user_manager.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class RegistrationResult extends $pb.ProtobufEnum {
  static const RegistrationResult RegistrationSuccess = RegistrationResult._(0, _omitEnumNames ? '' : 'RegistrationSuccess');
  static const RegistrationResult UserAlreadyExists = RegistrationResult._(1, _omitEnumNames ? '' : 'UserAlreadyExists');
  static const RegistrationResult RegistrationUnknownError = RegistrationResult._(-1, _omitEnumNames ? '' : 'RegistrationUnknownError');

  static const $core.List<RegistrationResult> values = <RegistrationResult> [
    RegistrationSuccess,
    UserAlreadyExists,
    RegistrationUnknownError,
  ];

  static final $core.Map<$core.int, RegistrationResult> _byValue = $pb.ProtobufEnum.initByValue(values);
  static RegistrationResult? valueOf($core.int value) => _byValue[value];

  const RegistrationResult._($core.int v, $core.String n) : super(v, n);
}

class LoginResult extends $pb.ProtobufEnum {
  static const LoginResult LoginSuccess = LoginResult._(0, _omitEnumNames ? '' : 'LoginSuccess');
  static const LoginResult InvalidPassword = LoginResult._(1, _omitEnumNames ? '' : 'InvalidPassword');
  static const LoginResult DoesNotExist = LoginResult._(2, _omitEnumNames ? '' : 'DoesNotExist');
  static const LoginResult LoginUnknownError = LoginResult._(-1, _omitEnumNames ? '' : 'LoginUnknownError');

  static const $core.List<LoginResult> values = <LoginResult> [
    LoginSuccess,
    InvalidPassword,
    DoesNotExist,
    LoginUnknownError,
  ];

  static final $core.Map<$core.int, LoginResult> _byValue = $pb.ProtobufEnum.initByValue(values);
  static LoginResult? valueOf($core.int value) => _byValue[value];

  const LoginResult._($core.int v, $core.String n) : super(v, n);
}

class RouteResult extends $pb.ProtobufEnum {
  static const RouteResult Success = RouteResult._(0, _omitEnumNames ? '' : 'Success');
  static const RouteResult UnknownError = RouteResult._(-1, _omitEnumNames ? '' : 'UnknownError');

  static const $core.List<RouteResult> values = <RouteResult> [
    Success,
    UnknownError,
  ];

  static final $core.Map<$core.int, RouteResult> _byValue = $pb.ProtobufEnum.initByValue(values);
  static RouteResult? valueOf($core.int value) => _byValue[value];

  const RouteResult._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');

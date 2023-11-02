//
//  Generated code. Do not modify.
//  source: user_manager.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use registrationResultDescriptor instead')
const RegistrationResult$json = {
  '1': 'RegistrationResult',
  '2': [
    {'1': 'RegistrationSuccess', '2': 0},
    {'1': 'UserAlreadyExists', '2': 1},
    {'1': 'RegistrationUnknownError', '2': -1},
  ],
};

/// Descriptor for `RegistrationResult`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List registrationResultDescriptor = $convert.base64Decode(
    'ChJSZWdpc3RyYXRpb25SZXN1bHQSFwoTUmVnaXN0cmF0aW9uU3VjY2VzcxAAEhUKEVVzZXJBbH'
    'JlYWR5RXhpc3RzEAESJQoYUmVnaXN0cmF0aW9uVW5rbm93bkVycm9yEP///////////wE=');

@$core.Deprecated('Use loginResultDescriptor instead')
const LoginResult$json = {
  '1': 'LoginResult',
  '2': [
    {'1': 'LoginSuccess', '2': 0},
    {'1': 'InalidPassword', '2': 1},
    {'1': 'DoesNotExist', '2': 2},
    {'1': 'LoginUnknownError', '2': -1},
  ],
};

/// Descriptor for `LoginResult`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List loginResultDescriptor = $convert.base64Decode(
    'CgtMb2dpblJlc3VsdBIQCgxMb2dpblN1Y2Nlc3MQABISCg5JbmFsaWRQYXNzd29yZBABEhAKDE'
    'RvZXNOb3RFeGlzdBACEh4KEUxvZ2luVW5rbm93bkVycm9yEP///////////wE=');

@$core.Deprecated('Use registrationDescriptor instead')
const Registration$json = {
  '1': 'Registration',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `Registration`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registrationDescriptor = $convert.base64Decode(
    'CgxSZWdpc3RyYXRpb24SGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1lEhoKCHBhc3N3b3JkGA'
    'IgASgJUghwYXNzd29yZA==');

@$core.Deprecated('Use registrationResponseDescriptor instead')
const RegistrationResponse$json = {
  '1': 'RegistrationResponse',
  '2': [
    {'1': 'result', '3': 1, '4': 1, '5': 14, '6': '.user_manager.RegistrationResult', '10': 'result'},
  ],
};

/// Descriptor for `RegistrationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registrationResponseDescriptor = $convert.base64Decode(
    'ChRSZWdpc3RyYXRpb25SZXNwb25zZRI4CgZyZXN1bHQYASABKA4yIC51c2VyX21hbmFnZXIuUm'
    'VnaXN0cmF0aW9uUmVzdWx0UgZyZXN1bHQ=');

@$core.Deprecated('Use loginDescriptor instead')
const Login$json = {
  '1': 'Login',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `Login`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginDescriptor = $convert.base64Decode(
    'CgVMb2dpbhIaCgh1c2VybmFtZRgBIAEoCVIIdXNlcm5hbWUSGgoIcGFzc3dvcmQYAiABKAlSCH'
    'Bhc3N3b3Jk');

@$core.Deprecated('Use loginResponseDescriptor instead')
const LoginResponse$json = {
  '1': 'LoginResponse',
  '2': [
    {'1': 'result', '3': 1, '4': 1, '5': 14, '6': '.user_manager.LoginResult', '10': 'result'},
    {'1': 'uuid', '3': 2, '4': 1, '5': 12, '10': 'uuid'},
    {'1': 'duration', '3': 3, '4': 1, '5': 4, '10': 'duration'},
  ],
};

/// Descriptor for `LoginResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginResponseDescriptor = $convert.base64Decode(
    'Cg1Mb2dpblJlc3BvbnNlEjEKBnJlc3VsdBgBIAEoDjIZLnVzZXJfbWFuYWdlci5Mb2dpblJlc3'
    'VsdFIGcmVzdWx0EhIKBHV1aWQYAiABKAxSBHV1aWQSGgoIZHVyYXRpb24YAyABKARSCGR1cmF0'
    'aW9u');


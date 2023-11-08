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
    {'1': 'InvalidPassword', '2': 1},
    {'1': 'DoesNotExist', '2': 2},
    {'1': 'LoginUnknownError', '2': -1},
  ],
};

/// Descriptor for `LoginResult`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List loginResultDescriptor = $convert.base64Decode(
    'CgtMb2dpblJlc3VsdBIQCgxMb2dpblN1Y2Nlc3MQABITCg9JbnZhbGlkUGFzc3dvcmQQARIQCg'
    'xEb2VzTm90RXhpc3QQAhIeChFMb2dpblVua25vd25FcnJvchD///////////8B');

@$core.Deprecated('Use routeResultDescriptor instead')
const RouteResult$json = {
  '1': 'RouteResult',
  '2': [
    {'1': 'Success', '2': 0},
    {'1': 'UnknownError', '2': -1},
  ],
};

/// Descriptor for `RouteResult`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List routeResultDescriptor = $convert.base64Decode(
    'CgtSb3V0ZVJlc3VsdBILCgdTdWNjZXNzEAASGQoMVW5rbm93bkVycm9yEP///////////wE=');

@$core.Deprecated('Use registrationDescriptor instead')
const Registration$json = {
  '1': 'Registration',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'vehicle', '3': 3, '4': 1, '5': 9, '10': 'vehicle'},
  ],
};

/// Descriptor for `Registration`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registrationDescriptor = $convert.base64Decode(
    'CgxSZWdpc3RyYXRpb24SGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1lEhoKCHBhc3N3b3JkGA'
    'IgASgJUghwYXNzd29yZBIYCgd2ZWhpY2xlGAMgASgJUgd2ZWhpY2xl');

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

@$core.Deprecated('Use routeDescriptor instead')
const Route$json = {
  '1': 'Route',
  '2': [
    {'1': 'events', '3': 1, '4': 3, '5': 11, '6': '.user_manager.Event', '10': 'events'},
  ],
};

/// Descriptor for `Route`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routeDescriptor = $convert.base64Decode(
    'CgVSb3V0ZRIrCgZldmVudHMYASADKAsyEy51c2VyX21hbmFnZXIuRXZlbnRSBmV2ZW50cw==');

@$core.Deprecated('Use routesDescriptor instead')
const Routes$json = {
  '1': 'Routes',
  '2': [
    {'1': 'route', '3': 1, '4': 3, '5': 11, '6': '.user_manager.Route', '10': 'route'},
  ],
};

/// Descriptor for `Routes`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routesDescriptor = $convert.base64Decode(
    'CgZSb3V0ZXMSKQoFcm91dGUYASADKAsyEy51c2VyX21hbmFnZXIuUm91dGVSBXJvdXRl');

@$core.Deprecated('Use eventDescriptor instead')
const Event$json = {
  '1': 'Event',
  '2': [
    {'1': 'location', '3': 1, '4': 1, '5': 9, '10': 'location'},
  ],
};

/// Descriptor for `Event`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventDescriptor = $convert.base64Decode(
    'CgVFdmVudBIaCghsb2NhdGlvbhgBIAEoCVIIbG9jYXRpb24=');

@$core.Deprecated('Use routeResponseDescriptor instead')
const RouteResponse$json = {
  '1': 'RouteResponse',
  '2': [
    {'1': 'result', '3': 1, '4': 1, '5': 14, '6': '.user_manager.RouteResult', '10': 'result'},
  ],
};

/// Descriptor for `RouteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routeResponseDescriptor = $convert.base64Decode(
    'Cg1Sb3V0ZVJlc3BvbnNlEjEKBnJlc3VsdBgBIAEoDjIZLnVzZXJfbWFuYWdlci5Sb3V0ZVJlc3'
    'VsdFIGcmVzdWx0');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor = $convert.base64Decode(
    'CgVFbXB0eQ==');


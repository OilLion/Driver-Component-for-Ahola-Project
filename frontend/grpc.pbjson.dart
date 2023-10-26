//
//  Generated code. Do not modify.
//  source: grpc.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use loginDataRequestDescriptor instead')
const LoginDataRequest$json = {
  '1': 'LoginDataRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `LoginDataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginDataRequestDescriptor = $convert.base64Decode(
    'ChBMb2dpbkRhdGFSZXF1ZXN0EhoKCHVzZXJuYW1lGAEgASgJUgh1c2VybmFtZRIaCghwYXNzd2'
    '9yZBgCIAEoCVIIcGFzc3dvcmQ=');

@$core.Deprecated('Use loginDataResponseDescriptor instead')
const LoginDataResponse$json = {
  '1': 'LoginDataResponse',
  '2': [
    {'1': 'loggedIn', '3': 1, '4': 1, '5': 8, '10': 'loggedIn'},
  ],
};

/// Descriptor for `LoginDataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginDataResponseDescriptor = $convert.base64Decode(
    'ChFMb2dpbkRhdGFSZXNwb25zZRIaCghsb2dnZWRJbhgBIAEoCFIIbG9nZ2VkSW4=');


//
//  Generated code. Do not modify.
//  source: route_manager.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use resultDescriptor instead')
const Result$json = {
  '1': 'Result',
  '2': [
    {'1': 'Success', '2': 0},
    {'1': 'InvalidRoute', '2': 1},
    {'1': 'UnknownVehicle', '2': 2},
    {'1': 'UnknownRoute', '2': 3},
    {'1': 'RouteAlreadyAssigned', '2': 4},
    {'1': 'DriverAlreadyAssigned', '2': 5},
    {'1': 'UnauthenticatedUser', '2': 6},
    {'1': 'IncompatibleVehicle', '2': 7},
    {'1': 'MalformedLoginToken', '2': 8},
    {'1': 'UnknownError', '2': -1},
  ],
};

/// Descriptor for `Result`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List resultDescriptor = $convert.base64Decode(
    'CgZSZXN1bHQSCwoHU3VjY2VzcxAAEhAKDEludmFsaWRSb3V0ZRABEhIKDlVua25vd25WZWhpY2'
    'xlEAISEAoMVW5rbm93blJvdXRlEAMSGAoUUm91dGVBbHJlYWR5QXNzaWduZWQQBBIZChVEcml2'
    'ZXJBbHJlYWR5QXNzaWduZWQQBRIXChNVbmF1dGhlbnRpY2F0ZWRVc2VyEAYSFwoTSW5jb21wYX'
    'RpYmxlVmVoaWNsZRAHEhcKE01hbGZvcm1lZExvZ2luVG9rZW4QCBIZCgxVbmtub3duRXJyb3IQ'
    '////////////AQ==');

@$core.Deprecated('Use routeDescriptor instead')
const Route$json = {
  '1': 'Route',
  '2': [
    {'1': 'events', '3': 1, '4': 3, '5': 11, '6': '.route_manager.Event', '10': 'events'},
    {'1': 'vehicle', '3': 2, '4': 1, '5': 9, '10': 'vehicle'},
  ],
};

/// Descriptor for `Route`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routeDescriptor = $convert.base64Decode(
    'CgVSb3V0ZRIsCgZldmVudHMYASADKAsyFC5yb3V0ZV9tYW5hZ2VyLkV2ZW50UgZldmVudHMSGA'
    'oHdmVoaWNsZRgCIAEoCVIHdmVoaWNsZQ==');

@$core.Deprecated('Use routeReplyDescriptor instead')
const RouteReply$json = {
  '1': 'RouteReply',
  '2': [
    {'1': 'events', '3': 1, '4': 3, '5': 11, '6': '.route_manager.Event', '10': 'events'},
    {'1': 'route_id', '3': 2, '4': 1, '5': 5, '10': 'routeId'},
  ],
};

/// Descriptor for `RouteReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routeReplyDescriptor = $convert.base64Decode(
    'CgpSb3V0ZVJlcGx5EiwKBmV2ZW50cxgBIAMoCzIULnJvdXRlX21hbmFnZXIuRXZlbnRSBmV2ZW'
    '50cxIZCghyb3V0ZV9pZBgCIAEoBVIHcm91dGVJZA==');

@$core.Deprecated('Use routesReplyDescriptor instead')
const RoutesReply$json = {
  '1': 'RoutesReply',
  '2': [
    {'1': 'result', '3': 1, '4': 1, '5': 14, '6': '.route_manager.Result', '10': 'result'},
    {'1': 'routes', '3': 2, '4': 3, '5': 11, '6': '.route_manager.RouteReply', '10': 'routes'},
  ],
};

/// Descriptor for `RoutesReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routesReplyDescriptor = $convert.base64Decode(
    'CgtSb3V0ZXNSZXBseRItCgZyZXN1bHQYASABKA4yFS5yb3V0ZV9tYW5hZ2VyLlJlc3VsdFIGcm'
    'VzdWx0EjEKBnJvdXRlcxgCIAMoCzIZLnJvdXRlX21hbmFnZXIuUm91dGVSZXBseVIGcm91dGVz');

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

@$core.Deprecated('Use addRouteResponseDescriptor instead')
const AddRouteResponse$json = {
  '1': 'AddRouteResponse',
  '2': [
    {'1': 'result', '3': 1, '4': 1, '5': 14, '6': '.route_manager.Result', '10': 'result'},
    {'1': 'route_id', '3': 2, '4': 1, '5': 5, '10': 'routeId'},
  ],
};

/// Descriptor for `AddRouteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addRouteResponseDescriptor = $convert.base64Decode(
    'ChBBZGRSb3V0ZVJlc3BvbnNlEi0KBnJlc3VsdBgBIAEoDjIVLnJvdXRlX21hbmFnZXIuUmVzdW'
    'x0UgZyZXN1bHQSGQoIcm91dGVfaWQYAiABKAVSB3JvdXRlSWQ=');

@$core.Deprecated('Use getRoutesRequestDescriptor instead')
const GetRoutesRequest$json = {
  '1': 'GetRoutesRequest',
  '2': [
    {'1': 'uuid', '3': 1, '4': 1, '5': 12, '10': 'uuid'},
  ],
};

/// Descriptor for `GetRoutesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRoutesRequestDescriptor = $convert.base64Decode(
    'ChBHZXRSb3V0ZXNSZXF1ZXN0EhIKBHV1aWQYASABKAxSBHV1aWQ=');

@$core.Deprecated('Use selectRouteRequestDescriptor instead')
const SelectRouteRequest$json = {
  '1': 'SelectRouteRequest',
  '2': [
    {'1': 'route_id', '3': 1, '4': 1, '5': 5, '10': 'routeId'},
    {'1': 'uuid', '3': 2, '4': 1, '5': 12, '10': 'uuid'},
  ],
};

/// Descriptor for `SelectRouteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List selectRouteRequestDescriptor = $convert.base64Decode(
    'ChJTZWxlY3RSb3V0ZVJlcXVlc3QSGQoIcm91dGVfaWQYASABKAVSB3JvdXRlSWQSEgoEdXVpZB'
    'gCIAEoDFIEdXVpZA==');

@$core.Deprecated('Use selectRouteResponseDescriptor instead')
const SelectRouteResponse$json = {
  '1': 'SelectRouteResponse',
  '2': [
    {'1': 'result', '3': 1, '4': 1, '5': 14, '6': '.route_manager.Result', '10': 'result'},
  ],
};

/// Descriptor for `SelectRouteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List selectRouteResponseDescriptor = $convert.base64Decode(
    'ChNTZWxlY3RSb3V0ZVJlc3BvbnNlEi0KBnJlc3VsdBgBIAEoDjIVLnJvdXRlX21hbmFnZXIuUm'
    'VzdWx0UgZyZXN1bHQ=');


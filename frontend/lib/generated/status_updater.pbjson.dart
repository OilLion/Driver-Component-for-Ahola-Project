//
//  Generated code. Do not modify.
//  source: status_updater.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use statusUpdateRequestDescriptor instead')
const StatusUpdateRequest$json = {
  '1': 'StatusUpdateRequest',
  '2': [
    {'1': 'uuid', '3': 1, '4': 1, '5': 12, '10': 'uuid'},
    {'1': 'step', '3': 2, '4': 1, '5': 5, '10': 'step'},
  ],
};

/// Descriptor for `StatusUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusUpdateRequestDescriptor = $convert.base64Decode(
    'ChNTdGF0dXNVcGRhdGVSZXF1ZXN0EhIKBHV1aWQYASABKAxSBHV1aWQSEgoEc3RlcBgCIAEoBV'
    'IEc3RlcA==');

@$core.Deprecated('Use statusUpdateResponseDescriptor instead')
const StatusUpdateResponse$json = {
  '1': 'StatusUpdateResponse',
  '2': [
    {'1': 'done', '3': 1, '4': 1, '5': 8, '10': 'done'},
  ],
};

/// Descriptor for `StatusUpdateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusUpdateResponseDescriptor = $convert.base64Decode(
    'ChRTdGF0dXNVcGRhdGVSZXNwb25zZRISCgRkb25lGAEgASgIUgRkb25l');

@$core.Deprecated('Use planningUpdateDescriptor instead')
const PlanningUpdate$json = {
  '1': 'PlanningUpdate',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'step', '3': 2, '4': 1, '5': 5, '10': 'step'},
  ],
};

/// Descriptor for `PlanningUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List planningUpdateDescriptor = $convert.base64Decode(
    'Cg5QbGFubmluZ1VwZGF0ZRIOCgJpZBgBIAEoBVICaWQSEgoEc3RlcBgCIAEoBVIEc3RlcA==');

@$core.Deprecated('Use planningResponseDescriptor instead')
const PlanningResponse$json = {
  '1': 'PlanningResponse',
};

/// Descriptor for `PlanningResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List planningResponseDescriptor = $convert.base64Decode(
    'ChBQbGFubmluZ1Jlc3BvbnNl');


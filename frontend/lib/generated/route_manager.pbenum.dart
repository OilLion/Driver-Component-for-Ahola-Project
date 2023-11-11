//
//  Generated code. Do not modify.
//  source: route_manager.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class AddRouteResult extends $pb.ProtobufEnum {
  static const AddRouteResult AddSuccess = AddRouteResult._(0, _omitEnumNames ? '' : 'AddSuccess');
  static const AddRouteResult InvalidRoute = AddRouteResult._(1, _omitEnumNames ? '' : 'InvalidRoute');
  static const AddRouteResult UnknownVehicle = AddRouteResult._(2, _omitEnumNames ? '' : 'UnknownVehicle');
  static const AddRouteResult AddUnknownError = AddRouteResult._(-1, _omitEnumNames ? '' : 'AddUnknownError');

  static const $core.List<AddRouteResult> values = <AddRouteResult> [
    AddSuccess,
    InvalidRoute,
    UnknownVehicle,
    AddUnknownError,
  ];

  static final $core.Map<$core.int, AddRouteResult> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AddRouteResult? valueOf($core.int value) => _byValue[value];

  const AddRouteResult._($core.int v, $core.String n) : super(v, n);
}

class GetRouteResult extends $pb.ProtobufEnum {
  static const GetRouteResult GetSuccss = GetRouteResult._(0, _omitEnumNames ? '' : 'GetSuccss');
  static const GetRouteResult UnauthenticatedUser = GetRouteResult._(1, _omitEnumNames ? '' : 'UnauthenticatedUser');
  static const GetRouteResult MalformedLoginToken = GetRouteResult._(2, _omitEnumNames ? '' : 'MalformedLoginToken');
  static const GetRouteResult GetUnknownError = GetRouteResult._(-1, _omitEnumNames ? '' : 'GetUnknownError');

  static const $core.List<GetRouteResult> values = <GetRouteResult> [
    GetSuccss,
    UnauthenticatedUser,
    MalformedLoginToken,
    GetUnknownError,
  ];

  static final $core.Map<$core.int, GetRouteResult> _byValue = $pb.ProtobufEnum.initByValue(values);
  static GetRouteResult? valueOf($core.int value) => _byValue[value];

  const GetRouteResult._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');

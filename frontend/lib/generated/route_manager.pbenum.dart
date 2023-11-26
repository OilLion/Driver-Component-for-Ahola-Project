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

class Result extends $pb.ProtobufEnum {
  static const Result Success = Result._(0, _omitEnumNames ? '' : 'Success');
  static const Result InvalidRoute = Result._(1, _omitEnumNames ? '' : 'InvalidRoute');
  static const Result UnknownVehicle = Result._(2, _omitEnumNames ? '' : 'UnknownVehicle');
  static const Result UnknownRoute = Result._(3, _omitEnumNames ? '' : 'UnknownRoute');
  static const Result RouteAlreadyAssigned = Result._(4, _omitEnumNames ? '' : 'RouteAlreadyAssigned');
  static const Result DriverAlreadyAssigned = Result._(5, _omitEnumNames ? '' : 'DriverAlreadyAssigned');
  static const Result UnauthenticatedUser = Result._(6, _omitEnumNames ? '' : 'UnauthenticatedUser');
  static const Result IncompatibleVehicle = Result._(7, _omitEnumNames ? '' : 'IncompatibleVehicle');
  static const Result MalformedLoginToken = Result._(8, _omitEnumNames ? '' : 'MalformedLoginToken');
  static const Result UnknownError = Result._(-1, _omitEnumNames ? '' : 'UnknownError');

  static const $core.List<Result> values = <Result> [
    Success,
    InvalidRoute,
    UnknownVehicle,
    UnknownRoute,
    RouteAlreadyAssigned,
    DriverAlreadyAssigned,
    UnauthenticatedUser,
    IncompatibleVehicle,
    MalformedLoginToken,
    UnknownError,
  ];

  static final $core.Map<$core.int, Result> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Result? valueOf($core.int value) => _byValue[value];

  const Result._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');

//
//  Generated code. Do not modify.
//  source: grpc.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class LoginDataRequest extends $pb.GeneratedMessage {
  factory LoginDataRequest({
    $core.String? username,
    $core.String? password,
  }) {
    final $result = create();
    if (username != null) {
      $result.username = username;
    }
    if (password != null) {
      $result.password = password;
    }
    return $result;
  }
  LoginDataRequest._() : super();
  factory LoginDataRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoginDataRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginDataRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'my_grpc_service'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoginDataRequest clone() => LoginDataRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoginDataRequest copyWith(void Function(LoginDataRequest) updates) => super.copyWith((message) => updates(message as LoginDataRequest)) as LoginDataRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginDataRequest create() => LoginDataRequest._();
  LoginDataRequest createEmptyInstance() => create();
  static $pb.PbList<LoginDataRequest> createRepeated() => $pb.PbList<LoginDataRequest>();
  @$core.pragma('dart2js:noInline')
  static LoginDataRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginDataRequest>(create);
  static LoginDataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => clearField(2);
}

class LoginDataResponse extends $pb.GeneratedMessage {
  factory LoginDataResponse({
    $core.bool? loggedIn,
  }) {
    final $result = create();
    if (loggedIn != null) {
      $result.loggedIn = loggedIn;
    }
    return $result;
  }
  LoginDataResponse._() : super();
  factory LoginDataResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoginDataResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoginDataResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'my_grpc_service'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'loggedIn', protoName: 'loggedIn')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoginDataResponse clone() => LoginDataResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoginDataResponse copyWith(void Function(LoginDataResponse) updates) => super.copyWith((message) => updates(message as LoginDataResponse)) as LoginDataResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginDataResponse create() => LoginDataResponse._();
  LoginDataResponse createEmptyInstance() => create();
  static $pb.PbList<LoginDataResponse> createRepeated() => $pb.PbList<LoginDataResponse>();
  @$core.pragma('dart2js:noInline')
  static LoginDataResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginDataResponse>(create);
  static LoginDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get loggedIn => $_getBF(0);
  @$pb.TagNumber(1)
  set loggedIn($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLoggedIn() => $_has(0);
  @$pb.TagNumber(1)
  void clearLoggedIn() => clearField(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');

//
//  Generated code. Do not modify.
//  source: user_manager.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'user_manager.pb.dart' as $0;

export 'user_manager.pb.dart';

@$pb.GrpcServiceName('user_manager.UserManager')
class UserManagerClient extends $grpc.Client {
  static final _$registerUser = $grpc.ClientMethod<$0.Registration, $0.RegistrationResponse>(
      '/user_manager.UserManager/RegisterUser',
      ($0.Registration value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.RegistrationResponse.fromBuffer(value));
  static final _$loginUser = $grpc.ClientMethod<$0.Login, $0.LoginResponse>(
      '/user_manager.UserManager/LoginUser',
      ($0.Login value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.LoginResponse.fromBuffer(value));

  UserManagerClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.RegistrationResponse> registerUser($0.Registration request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$registerUser, request, options: options);
  }

  $grpc.ResponseFuture<$0.LoginResponse> loginUser($0.Login request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$loginUser, request, options: options);
  }
}

@$pb.GrpcServiceName('user_manager.UserManager')
abstract class UserManagerServiceBase extends $grpc.Service {
  $core.String get $name => 'user_manager.UserManager';

  UserManagerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Registration, $0.RegistrationResponse>(
        'RegisterUser',
        registerUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Registration.fromBuffer(value),
        ($0.RegistrationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Login, $0.LoginResponse>(
        'LoginUser',
        loginUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Login.fromBuffer(value),
        ($0.LoginResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.RegistrationResponse> registerUser_Pre($grpc.ServiceCall call, $async.Future<$0.Registration> request) async {
    return registerUser(call, await request);
  }

  $async.Future<$0.LoginResponse> loginUser_Pre($grpc.ServiceCall call, $async.Future<$0.Login> request) async {
    return loginUser(call, await request);
  }

  $async.Future<$0.RegistrationResponse> registerUser($grpc.ServiceCall call, $0.Registration request);
  $async.Future<$0.LoginResponse> loginUser($grpc.ServiceCall call, $0.Login request);
}

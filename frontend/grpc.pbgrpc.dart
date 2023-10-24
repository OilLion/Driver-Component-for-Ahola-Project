//
//  Generated code. Do not modify.
//  source: grpc.proto
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

import 'grpc.pb.dart' as $0;

export 'grpc.pb.dart';

@$pb.GrpcServiceName('my_grpc_service.MyGrpcService')
class MyGrpcServiceClient extends $grpc.Client {
  static final _$sendLoginData = $grpc.ClientMethod<$0.LoginDataRequest, $0.LoginDataResponse>(
      '/my_grpc_service.MyGrpcService/SendLoginData',
      ($0.LoginDataRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.LoginDataResponse.fromBuffer(value));

  MyGrpcServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.LoginDataResponse> sendLoginData($0.LoginDataRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendLoginData, request, options: options);
  }
}

@$pb.GrpcServiceName('my_grpc_service.MyGrpcService')
abstract class MyGrpcServiceBase extends $grpc.Service {
  $core.String get $name => 'my_grpc_service.MyGrpcService';

  MyGrpcServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.LoginDataRequest, $0.LoginDataResponse>(
        'SendLoginData',
        sendLoginData_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LoginDataRequest.fromBuffer(value),
        ($0.LoginDataResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.LoginDataResponse> sendLoginData_Pre($grpc.ServiceCall call, $async.Future<$0.LoginDataRequest> request) async {
    return sendLoginData(call, await request);
  }

  $async.Future<$0.LoginDataResponse> sendLoginData($grpc.ServiceCall call, $0.LoginDataRequest request);
}

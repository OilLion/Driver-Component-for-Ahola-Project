//
//  Generated code. Do not modify.
//  source: status_updater.proto
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

import 'status_updater.pb.dart' as $0;

export 'status_updater.pb.dart';

@$pb.GrpcServiceName('status_updater.DriverUpdater')
class DriverUpdaterClient extends $grpc.Client {
  static final _$updateStatus = $grpc.ClientMethod<$0.StatusUpdateRequest, $0.StatusUpdateResponse>(
      '/status_updater.DriverUpdater/UpdateStatus',
      ($0.StatusUpdateRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.StatusUpdateResponse.fromBuffer(value));

  DriverUpdaterClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.StatusUpdateResponse> updateStatus($0.StatusUpdateRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateStatus, request, options: options);
  }
}

@$pb.GrpcServiceName('status_updater.DriverUpdater')
abstract class DriverUpdaterServiceBase extends $grpc.Service {
  $core.String get $name => 'status_updater.DriverUpdater';

  DriverUpdaterServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.StatusUpdateRequest, $0.StatusUpdateResponse>(
        'UpdateStatus',
        updateStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StatusUpdateRequest.fromBuffer(value),
        ($0.StatusUpdateResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.StatusUpdateResponse> updateStatus_Pre($grpc.ServiceCall call, $async.Future<$0.StatusUpdateRequest> request) async {
    return updateStatus(call, await request);
  }

  $async.Future<$0.StatusUpdateResponse> updateStatus($grpc.ServiceCall call, $0.StatusUpdateRequest request);
}
@$pb.GrpcServiceName('status_updater.PlanningUpdater')
class PlanningUpdaterClient extends $grpc.Client {
  static final _$statusUpdate = $grpc.ClientMethod<$0.PlanningUpdate, $0.PlanningResponse>(
      '/status_updater.PlanningUpdater/StatusUpdate',
      ($0.PlanningUpdate value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.PlanningResponse.fromBuffer(value));

  PlanningUpdaterClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.PlanningResponse> statusUpdate($0.PlanningUpdate request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$statusUpdate, request, options: options);
  }
}

@$pb.GrpcServiceName('status_updater.PlanningUpdater')
abstract class PlanningUpdaterServiceBase extends $grpc.Service {
  $core.String get $name => 'status_updater.PlanningUpdater';

  PlanningUpdaterServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PlanningUpdate, $0.PlanningResponse>(
        'StatusUpdate',
        statusUpdate_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PlanningUpdate.fromBuffer(value),
        ($0.PlanningResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.PlanningResponse> statusUpdate_Pre($grpc.ServiceCall call, $async.Future<$0.PlanningUpdate> request) async {
    return statusUpdate(call, await request);
  }

  $async.Future<$0.PlanningResponse> statusUpdate($grpc.ServiceCall call, $0.PlanningUpdate request);
}

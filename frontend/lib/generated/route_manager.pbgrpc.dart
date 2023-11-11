//
//  Generated code. Do not modify.
//  source: route_manager.proto
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

import 'route_manager.pb.dart' as $0;

export 'route_manager.pb.dart';

@$pb.GrpcServiceName('route_manager.RouteManager')
class RouteManagerClient extends $grpc.Client {
  static final _$addRoute = $grpc.ClientMethod<$0.Route, $0.AddRouteResponse>(
      '/route_manager.RouteManager/AddRoute',
      ($0.Route value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AddRouteResponse.fromBuffer(value));
  static final _$getRoutes = $grpc.ClientMethod<$0.GetRoutesRequest, $0.RoutesReply>(
      '/route_manager.RouteManager/GetRoutes',
      ($0.GetRoutesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.RoutesReply.fromBuffer(value));

  RouteManagerClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.AddRouteResponse> addRoute($0.Route request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$addRoute, request, options: options);
  }

  $grpc.ResponseFuture<$0.RoutesReply> getRoutes($0.GetRoutesRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getRoutes, request, options: options);
  }
}

@$pb.GrpcServiceName('route_manager.RouteManager')
abstract class RouteManagerServiceBase extends $grpc.Service {
  $core.String get $name => 'route_manager.RouteManager';

  RouteManagerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Route, $0.AddRouteResponse>(
        'AddRoute',
        addRoute_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Route.fromBuffer(value),
        ($0.AddRouteResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetRoutesRequest, $0.RoutesReply>(
        'GetRoutes',
        getRoutes_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetRoutesRequest.fromBuffer(value),
        ($0.RoutesReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.AddRouteResponse> addRoute_Pre($grpc.ServiceCall call, $async.Future<$0.Route> request) async {
    return addRoute(call, await request);
  }

  $async.Future<$0.RoutesReply> getRoutes_Pre($grpc.ServiceCall call, $async.Future<$0.GetRoutesRequest> request) async {
    return getRoutes(call, await request);
  }

  $async.Future<$0.AddRouteResponse> addRoute($grpc.ServiceCall call, $0.Route request);
  $async.Future<$0.RoutesReply> getRoutes($grpc.ServiceCall call, $0.GetRoutesRequest request);
}

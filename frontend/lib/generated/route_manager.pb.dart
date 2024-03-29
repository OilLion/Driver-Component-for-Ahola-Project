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

import 'route_manager.pbenum.dart';

export 'route_manager.pbenum.dart';

class Route extends $pb.GeneratedMessage {
  factory Route({
    $core.Iterable<Event>? events,
    $core.String? vehicle,
  }) {
    final $result = create();
    if (events != null) {
      $result.events.addAll(events);
    }
    if (vehicle != null) {
      $result.vehicle = vehicle;
    }
    return $result;
  }
  Route._() : super();
  factory Route.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Route.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Route', package: const $pb.PackageName(_omitMessageNames ? '' : 'route_manager'), createEmptyInstance: create)
    ..pc<Event>(1, _omitFieldNames ? '' : 'events', $pb.PbFieldType.PM, subBuilder: Event.create)
    ..aOS(2, _omitFieldNames ? '' : 'vehicle')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Route clone() => Route()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Route copyWith(void Function(Route) updates) => super.copyWith((message) => updates(message as Route)) as Route;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Route create() => Route._();
  Route createEmptyInstance() => create();
  static $pb.PbList<Route> createRepeated() => $pb.PbList<Route>();
  @$core.pragma('dart2js:noInline')
  static Route getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Route>(create);
  static Route? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Event> get events => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get vehicle => $_getSZ(1);
  @$pb.TagNumber(2)
  set vehicle($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVehicle() => $_has(1);
  @$pb.TagNumber(2)
  void clearVehicle() => clearField(2);
}

class RouteReply extends $pb.GeneratedMessage {
  factory RouteReply({
    $core.Iterable<Event>? events,
    $core.int? routeId,
  }) {
    final $result = create();
    if (events != null) {
      $result.events.addAll(events);
    }
    if (routeId != null) {
      $result.routeId = routeId;
    }
    return $result;
  }
  RouteReply._() : super();
  factory RouteReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RouteReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RouteReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'route_manager'), createEmptyInstance: create)
    ..pc<Event>(1, _omitFieldNames ? '' : 'events', $pb.PbFieldType.PM, subBuilder: Event.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'routeId', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RouteReply clone() => RouteReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RouteReply copyWith(void Function(RouteReply) updates) => super.copyWith((message) => updates(message as RouteReply)) as RouteReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RouteReply create() => RouteReply._();
  RouteReply createEmptyInstance() => create();
  static $pb.PbList<RouteReply> createRepeated() => $pb.PbList<RouteReply>();
  @$core.pragma('dart2js:noInline')
  static RouteReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RouteReply>(create);
  static RouteReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Event> get events => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get routeId => $_getIZ(1);
  @$pb.TagNumber(2)
  set routeId($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRouteId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRouteId() => clearField(2);
}

class RoutesReply extends $pb.GeneratedMessage {
  factory RoutesReply({
    Result? result,
    $core.Iterable<RouteReply>? routes,
  }) {
    final $result = create();
    if (result != null) {
      $result.result = result;
    }
    if (routes != null) {
      $result.routes.addAll(routes);
    }
    return $result;
  }
  RoutesReply._() : super();
  factory RoutesReply.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RoutesReply.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RoutesReply', package: const $pb.PackageName(_omitMessageNames ? '' : 'route_manager'), createEmptyInstance: create)
    ..e<Result>(1, _omitFieldNames ? '' : 'result', $pb.PbFieldType.OE, defaultOrMaker: Result.Success, valueOf: Result.valueOf, enumValues: Result.values)
    ..pc<RouteReply>(2, _omitFieldNames ? '' : 'routes', $pb.PbFieldType.PM, subBuilder: RouteReply.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RoutesReply clone() => RoutesReply()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RoutesReply copyWith(void Function(RoutesReply) updates) => super.copyWith((message) => updates(message as RoutesReply)) as RoutesReply;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RoutesReply create() => RoutesReply._();
  RoutesReply createEmptyInstance() => create();
  static $pb.PbList<RoutesReply> createRepeated() => $pb.PbList<RoutesReply>();
  @$core.pragma('dart2js:noInline')
  static RoutesReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RoutesReply>(create);
  static RoutesReply? _defaultInstance;

  @$pb.TagNumber(1)
  Result get result => $_getN(0);
  @$pb.TagNumber(1)
  set result(Result v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearResult() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<RouteReply> get routes => $_getList(1);
}

class Event extends $pb.GeneratedMessage {
  factory Event({
    $core.String? location,
  }) {
    final $result = create();
    if (location != null) {
      $result.location = location;
    }
    return $result;
  }
  Event._() : super();
  factory Event.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Event.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Event', package: const $pb.PackageName(_omitMessageNames ? '' : 'route_manager'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'location')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Event clone() => Event()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Event copyWith(void Function(Event) updates) => super.copyWith((message) => updates(message as Event)) as Event;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event create() => Event._();
  Event createEmptyInstance() => create();
  static $pb.PbList<Event> createRepeated() => $pb.PbList<Event>();
  @$core.pragma('dart2js:noInline')
  static Event getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Event>(create);
  static Event? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get location => $_getSZ(0);
  @$pb.TagNumber(1)
  set location($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLocation() => $_has(0);
  @$pb.TagNumber(1)
  void clearLocation() => clearField(1);
}

class AddRouteResponse extends $pb.GeneratedMessage {
  factory AddRouteResponse({
    Result? result,
    $core.int? routeId,
  }) {
    final $result = create();
    if (result != null) {
      $result.result = result;
    }
    if (routeId != null) {
      $result.routeId = routeId;
    }
    return $result;
  }
  AddRouteResponse._() : super();
  factory AddRouteResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddRouteResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddRouteResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'route_manager'), createEmptyInstance: create)
    ..e<Result>(1, _omitFieldNames ? '' : 'result', $pb.PbFieldType.OE, defaultOrMaker: Result.Success, valueOf: Result.valueOf, enumValues: Result.values)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'routeId', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddRouteResponse clone() => AddRouteResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddRouteResponse copyWith(void Function(AddRouteResponse) updates) => super.copyWith((message) => updates(message as AddRouteResponse)) as AddRouteResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddRouteResponse create() => AddRouteResponse._();
  AddRouteResponse createEmptyInstance() => create();
  static $pb.PbList<AddRouteResponse> createRepeated() => $pb.PbList<AddRouteResponse>();
  @$core.pragma('dart2js:noInline')
  static AddRouteResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddRouteResponse>(create);
  static AddRouteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Result get result => $_getN(0);
  @$pb.TagNumber(1)
  set result(Result v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearResult() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get routeId => $_getIZ(1);
  @$pb.TagNumber(2)
  set routeId($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRouteId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRouteId() => clearField(2);
}

class GetRoutesRequest extends $pb.GeneratedMessage {
  factory GetRoutesRequest({
    $core.List<$core.int>? uuid,
  }) {
    final $result = create();
    if (uuid != null) {
      $result.uuid = uuid;
    }
    return $result;
  }
  GetRoutesRequest._() : super();
  factory GetRoutesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetRoutesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRoutesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'route_manager'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'uuid', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetRoutesRequest clone() => GetRoutesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetRoutesRequest copyWith(void Function(GetRoutesRequest) updates) => super.copyWith((message) => updates(message as GetRoutesRequest)) as GetRoutesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRoutesRequest create() => GetRoutesRequest._();
  GetRoutesRequest createEmptyInstance() => create();
  static $pb.PbList<GetRoutesRequest> createRepeated() => $pb.PbList<GetRoutesRequest>();
  @$core.pragma('dart2js:noInline')
  static GetRoutesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRoutesRequest>(create);
  static GetRoutesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get uuid => $_getN(0);
  @$pb.TagNumber(1)
  set uuid($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUuid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUuid() => clearField(1);
}

class GetAssignedRouteRequest extends $pb.GeneratedMessage {
  factory GetAssignedRouteRequest({
    $core.List<$core.int>? uuid,
  }) {
    final $result = create();
    if (uuid != null) {
      $result.uuid = uuid;
    }
    return $result;
  }
  GetAssignedRouteRequest._() : super();
  factory GetAssignedRouteRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAssignedRouteRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAssignedRouteRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'route_manager'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'uuid', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAssignedRouteRequest clone() => GetAssignedRouteRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAssignedRouteRequest copyWith(void Function(GetAssignedRouteRequest) updates) => super.copyWith((message) => updates(message as GetAssignedRouteRequest)) as GetAssignedRouteRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAssignedRouteRequest create() => GetAssignedRouteRequest._();
  GetAssignedRouteRequest createEmptyInstance() => create();
  static $pb.PbList<GetAssignedRouteRequest> createRepeated() => $pb.PbList<GetAssignedRouteRequest>();
  @$core.pragma('dart2js:noInline')
  static GetAssignedRouteRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAssignedRouteRequest>(create);
  static GetAssignedRouteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get uuid => $_getN(0);
  @$pb.TagNumber(1)
  set uuid($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUuid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUuid() => clearField(1);
}

class AssignedRoute extends $pb.GeneratedMessage {
  factory AssignedRoute({
    RouteReply? route,
    $core.int? currentStep,
  }) {
    final $result = create();
    if (route != null) {
      $result.route = route;
    }
    if (currentStep != null) {
      $result.currentStep = currentStep;
    }
    return $result;
  }
  AssignedRoute._() : super();
  factory AssignedRoute.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AssignedRoute.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AssignedRoute', package: const $pb.PackageName(_omitMessageNames ? '' : 'route_manager'), createEmptyInstance: create)
    ..aOM<RouteReply>(1, _omitFieldNames ? '' : 'route', subBuilder: RouteReply.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'currentStep', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AssignedRoute clone() => AssignedRoute()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AssignedRoute copyWith(void Function(AssignedRoute) updates) => super.copyWith((message) => updates(message as AssignedRoute)) as AssignedRoute;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AssignedRoute create() => AssignedRoute._();
  AssignedRoute createEmptyInstance() => create();
  static $pb.PbList<AssignedRoute> createRepeated() => $pb.PbList<AssignedRoute>();
  @$core.pragma('dart2js:noInline')
  static AssignedRoute getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AssignedRoute>(create);
  static AssignedRoute? _defaultInstance;

  @$pb.TagNumber(1)
  RouteReply get route => $_getN(0);
  @$pb.TagNumber(1)
  set route(RouteReply v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasRoute() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoute() => clearField(1);
  @$pb.TagNumber(1)
  RouteReply ensureRoute() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get currentStep => $_getIZ(1);
  @$pb.TagNumber(2)
  set currentStep($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCurrentStep() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrentStep() => clearField(2);
}

class SelectRouteRequest extends $pb.GeneratedMessage {
  factory SelectRouteRequest({
    $core.int? routeId,
    $core.List<$core.int>? uuid,
  }) {
    final $result = create();
    if (routeId != null) {
      $result.routeId = routeId;
    }
    if (uuid != null) {
      $result.uuid = uuid;
    }
    return $result;
  }
  SelectRouteRequest._() : super();
  factory SelectRouteRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SelectRouteRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SelectRouteRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'route_manager'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'routeId', $pb.PbFieldType.O3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'uuid', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SelectRouteRequest clone() => SelectRouteRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SelectRouteRequest copyWith(void Function(SelectRouteRequest) updates) => super.copyWith((message) => updates(message as SelectRouteRequest)) as SelectRouteRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SelectRouteRequest create() => SelectRouteRequest._();
  SelectRouteRequest createEmptyInstance() => create();
  static $pb.PbList<SelectRouteRequest> createRepeated() => $pb.PbList<SelectRouteRequest>();
  @$core.pragma('dart2js:noInline')
  static SelectRouteRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SelectRouteRequest>(create);
  static SelectRouteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get routeId => $_getIZ(0);
  @$pb.TagNumber(1)
  set routeId($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRouteId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRouteId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get uuid => $_getN(1);
  @$pb.TagNumber(2)
  set uuid($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUuid() => $_has(1);
  @$pb.TagNumber(2)
  void clearUuid() => clearField(2);
}

class SelectRouteResponse extends $pb.GeneratedMessage {
  factory SelectRouteResponse({
    Result? result,
  }) {
    final $result = create();
    if (result != null) {
      $result.result = result;
    }
    return $result;
  }
  SelectRouteResponse._() : super();
  factory SelectRouteResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SelectRouteResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SelectRouteResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'route_manager'), createEmptyInstance: create)
    ..e<Result>(1, _omitFieldNames ? '' : 'result', $pb.PbFieldType.OE, defaultOrMaker: Result.Success, valueOf: Result.valueOf, enumValues: Result.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SelectRouteResponse clone() => SelectRouteResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SelectRouteResponse copyWith(void Function(SelectRouteResponse) updates) => super.copyWith((message) => updates(message as SelectRouteResponse)) as SelectRouteResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SelectRouteResponse create() => SelectRouteResponse._();
  SelectRouteResponse createEmptyInstance() => create();
  static $pb.PbList<SelectRouteResponse> createRepeated() => $pb.PbList<SelectRouteResponse>();
  @$core.pragma('dart2js:noInline')
  static SelectRouteResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SelectRouteResponse>(create);
  static SelectRouteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Result get result => $_getN(0);
  @$pb.TagNumber(1)
  set result(Result v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearResult() => clearField(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');

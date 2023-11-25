//
//  Generated code. Do not modify.
//  source: status_updater.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class StatusUpdateRequest extends $pb.GeneratedMessage {
  factory StatusUpdateRequest({
    $core.List<$core.int>? uuid,
    $core.int? step,
  }) {
    final $result = create();
    if (uuid != null) {
      $result.uuid = uuid;
    }
    if (step != null) {
      $result.step = step;
    }
    return $result;
  }
  StatusUpdateRequest._() : super();
  factory StatusUpdateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StatusUpdateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StatusUpdateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'status_updater'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'uuid', $pb.PbFieldType.OY)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'step', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StatusUpdateRequest clone() => StatusUpdateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StatusUpdateRequest copyWith(void Function(StatusUpdateRequest) updates) => super.copyWith((message) => updates(message as StatusUpdateRequest)) as StatusUpdateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatusUpdateRequest create() => StatusUpdateRequest._();
  StatusUpdateRequest createEmptyInstance() => create();
  static $pb.PbList<StatusUpdateRequest> createRepeated() => $pb.PbList<StatusUpdateRequest>();
  @$core.pragma('dart2js:noInline')
  static StatusUpdateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StatusUpdateRequest>(create);
  static StatusUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get uuid => $_getN(0);
  @$pb.TagNumber(1)
  set uuid($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUuid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUuid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get step => $_getIZ(1);
  @$pb.TagNumber(2)
  set step($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStep() => $_has(1);
  @$pb.TagNumber(2)
  void clearStep() => clearField(2);
}

class StatusUpdateResponse extends $pb.GeneratedMessage {
  factory StatusUpdateResponse({
    $core.bool? done,
  }) {
    final $result = create();
    if (done != null) {
      $result.done = done;
    }
    return $result;
  }
  StatusUpdateResponse._() : super();
  factory StatusUpdateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StatusUpdateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StatusUpdateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'status_updater'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'done')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StatusUpdateResponse clone() => StatusUpdateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StatusUpdateResponse copyWith(void Function(StatusUpdateResponse) updates) => super.copyWith((message) => updates(message as StatusUpdateResponse)) as StatusUpdateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatusUpdateResponse create() => StatusUpdateResponse._();
  StatusUpdateResponse createEmptyInstance() => create();
  static $pb.PbList<StatusUpdateResponse> createRepeated() => $pb.PbList<StatusUpdateResponse>();
  @$core.pragma('dart2js:noInline')
  static StatusUpdateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StatusUpdateResponse>(create);
  static StatusUpdateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get done => $_getBF(0);
  @$pb.TagNumber(1)
  set done($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDone() => $_has(0);
  @$pb.TagNumber(1)
  void clearDone() => clearField(1);
}

class PlanningUpdate extends $pb.GeneratedMessage {
  factory PlanningUpdate({
    $core.int? id,
    $core.int? step,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (step != null) {
      $result.step = step;
    }
    return $result;
  }
  PlanningUpdate._() : super();
  factory PlanningUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PlanningUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PlanningUpdate', package: const $pb.PackageName(_omitMessageNames ? '' : 'status_updater'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'step', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PlanningUpdate clone() => PlanningUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PlanningUpdate copyWith(void Function(PlanningUpdate) updates) => super.copyWith((message) => updates(message as PlanningUpdate)) as PlanningUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlanningUpdate create() => PlanningUpdate._();
  PlanningUpdate createEmptyInstance() => create();
  static $pb.PbList<PlanningUpdate> createRepeated() => $pb.PbList<PlanningUpdate>();
  @$core.pragma('dart2js:noInline')
  static PlanningUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlanningUpdate>(create);
  static PlanningUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get step => $_getIZ(1);
  @$pb.TagNumber(2)
  set step($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStep() => $_has(1);
  @$pb.TagNumber(2)
  void clearStep() => clearField(2);
}

class PlanningResponse extends $pb.GeneratedMessage {
  factory PlanningResponse() => create();
  PlanningResponse._() : super();
  factory PlanningResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PlanningResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PlanningResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'status_updater'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PlanningResponse clone() => PlanningResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PlanningResponse copyWith(void Function(PlanningResponse) updates) => super.copyWith((message) => updates(message as PlanningResponse)) as PlanningResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlanningResponse create() => PlanningResponse._();
  PlanningResponse createEmptyInstance() => create();
  static $pb.PbList<PlanningResponse> createRepeated() => $pb.PbList<PlanningResponse>();
  @$core.pragma('dart2js:noInline')
  static PlanningResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlanningResponse>(create);
  static PlanningResponse? _defaultInstance;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');

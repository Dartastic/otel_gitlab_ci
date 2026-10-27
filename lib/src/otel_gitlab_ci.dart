// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_gitlab_ci_suppression.dart';

class GitlabCIResult {
  /// Creates a result.
  const GitlabCIResult({
    this.instance,
    this.projectId,
    this.projectPath,
    this.pipelineId,
    this.pipelineSource,
    this.pipelineStatus,
    this.jobId,
    this.jobName,
    this.jobStage,
    this.jobStatus,
    this.runnerId,
    this.runnerDescription,
    this.branch,
    this.commit,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? instance;
  final String? projectId;
  final String? projectPath;
  final String? pipelineId;
  final String? pipelineSource;
  final String? pipelineStatus;
  final String? jobId;
  final String? jobName;
  final String? jobStage;
  final String? jobStatus;
  final String? runnerId;
  final String? runnerDescription;
  final String? branch;
  final String? commit;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class GitlabCICallResult<T> {
  /// Creates a call result.
  const GitlabCICallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final GitlabCIResult? result;
}

Future<T> tracedGitlabCI<T>({
  required String operation,
  required Future<GitlabCICallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (gitlabCIInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_gitlab_ci');
  final span = t.startSpan('gitlabci $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'gitlab')]));
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('cicd.platform', 'gitlab')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.instance != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('gitlab.instance', res.instance!)]));
      }
      if (res.projectId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('gitlab.project.id', res.projectId!)]));
      }
      if (res.projectPath != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('gitlab.project.path', res.projectPath!)
        ]));
      }
      if (res.pipelineId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('cicd.pipeline.run.id', res.pipelineId!)
        ]));
      }
      if (res.pipelineSource != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'cicd.pipeline.run.cause', res.pipelineSource!)
        ]));
      }
      if (res.pipelineStatus != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'cicd.pipeline.run.state', res.pipelineStatus!)
        ]));
      }
      if (res.jobId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cicd.task.run.id', res.jobId!)]));
      }
      if (res.jobName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cicd.task.name', res.jobName!)]));
      }
      if (res.jobStage != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cicd.task.group', res.jobStage!)]));
      }
      if (res.jobStatus != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cicd.task.run.state', res.jobStatus!)]));
      }
      if (res.runnerId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cicd.worker.id', res.runnerId!)]));
      }
      if (res.runnerDescription != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('cicd.worker.name', res.runnerDescription!)
        ]));
      }
      if (res.branch != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('vcs.ref.head.name', res.branch!)]));
      }
      if (res.commit != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('vcs.ref.head.revision', res.commit!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('gitlabci.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              ErrorAttributes.errorType.key, res.errorCode ?? 'gitlabci.error')
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

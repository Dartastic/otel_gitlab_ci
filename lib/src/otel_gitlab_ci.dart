// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_gitlab_ci_suppression.dart';

class GitlabCIResult {
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

class GitlabCICallResult<T> {
  const GitlabCICallResult({required this.value, this.result});
  final T value;
  final GitlabCIResult? result;
}

Future<T> tracedGitlabCI<T>({
  required String operation,
  required Future<GitlabCICallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (gitlabCIInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_gitlab_ci');
  final span = t.startSpan('gitlabci $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'gitlab');
    span.setStringAttribute('cicd.platform', 'gitlab');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.instance != null) {
        span.setStringAttribute('gitlab.instance', res.instance!);
      }
      if (res.projectId != null) {
        span.setStringAttribute('gitlab.project.id', res.projectId!);
      }
      if (res.projectPath != null) {
        span.setStringAttribute('gitlab.project.path', res.projectPath!);
      }
      if (res.pipelineId != null) {
        span.setStringAttribute('cicd.pipeline.run.id', res.pipelineId!);
      }
      if (res.pipelineSource != null) {
        span.setStringAttribute('cicd.pipeline.run.cause', res.pipelineSource!);
      }
      if (res.pipelineStatus != null) {
        span.setStringAttribute('cicd.pipeline.run.state', res.pipelineStatus!);
      }
      if (res.jobId != null) {
        span.setStringAttribute('cicd.task.run.id', res.jobId!);
      }
      if (res.jobName != null) {
        span.setStringAttribute('cicd.task.name', res.jobName!);
      }
      if (res.jobStage != null) {
        span.setStringAttribute('cicd.task.group', res.jobStage!);
      }
      if (res.jobStatus != null) {
        span.setStringAttribute('cicd.task.run.state', res.jobStatus!);
      }
      if (res.runnerId != null) {
        span.setStringAttribute('cicd.worker.id', res.runnerId!);
      }
      if (res.runnerDescription != null) {
        span.setStringAttribute('cicd.worker.name', res.runnerDescription!);
      }
      if (res.branch != null) {
        span.setStringAttribute('vcs.ref.head.name', res.branch!);
      }
      if (res.commit != null) {
        span.setStringAttribute('vcs.ref.head.revision', res.commit!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('gitlabci.error.code', res.errorCode!);
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
            ErrorResource.errorType.key, res.errorCode ?? 'gitlabci.error');
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

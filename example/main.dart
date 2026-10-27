// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_gitlab_ci/otel_gitlab_ci.dart';

/// Traces Gitlab Ci calls with OpenTelemetry.
///
/// `otel_gitlab_ci` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Gitlab Ci call in
/// [tracedGitlabCI]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'gitlab-ci-example');

  // Traces a Gitlab Ci call.
  final gitlabCIId = await tracedGitlabCI<String>(
    operation: 'create',
    invoke: () async {
      // Make the Gitlab Ci call here, then report what it returned.
      const id = 'gitlab_ci_8f3a2c';
      return const GitlabCICallResult(
          value: id,
          result: GitlabCIResult(
              instance: 'example',
              projectId: 'project_8f3a2c',
              projectPath: '/v1/orders',
              pipelineId: 'pipeline_8f3a2c',
              pipelineSource: 'example',
              pipelineStatus: 'succeeded',
              jobId: 'job_8f3a2c',
              jobName: 'example',
              jobStage: 'example',
              jobStatus: 'succeeded',
              runnerId: 'runner_8f3a2c',
              runnerDescription: 'example',
              branch: 'example',
              commit: 'example',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedGitlabCI create returned $gitlabCIId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutGitlabCIInstrumentationAsync.
  await runWithoutGitlabCIInstrumentationAsync(
    () => tracedGitlabCI<String>(
      operation: 'create',
      invoke: () async {
        const id = 'gitlab_ci_8f3a2c';
        return const GitlabCICallResult(
            value: id,
            result: GitlabCIResult(
                instance: 'example',
                projectId: 'project_8f3a2c',
                projectPath: '/v1/orders',
                pipelineId: 'pipeline_8f3a2c',
                pipelineSource: 'example',
                pipelineStatus: 'succeeded',
                jobId: 'job_8f3a2c',
                jobName: 'example',
                jobStage: 'example',
                jobStatus: 'succeeded',
                runnerId: 'runner_8f3a2c',
                runnerDescription: 'example',
                branch: 'example',
                commit: 'example',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}

# otel_gitlab_ci

Dartastic OpenTelemetry bridge for GitLab CI/CD (pipelines + jobs + runners).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_gitlab_ci/otel_gitlab_ci.dart';

await tracedGitlabCI<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return GitlabCICallResult(value: r, result: GitlabCIResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutGitlabCIInstrumentationAsync(() async {
  await client.someInternalSync();
});
```

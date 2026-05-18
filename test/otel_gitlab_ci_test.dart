// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_gitlab_ci/otel_gitlab_ci.dart';
import 'package:test/test.dart';

void main() {
  group('otel_gitlab_ci', () {
    test('suppression toggles in zone', () async {
      expect(gitlabCIInstrumentationSuppressed(), isFalse);
      await runWithoutGitlabCIInstrumentationAsync(() async {
        expect(gitlabCIInstrumentationSuppressed(), isTrue);
      });
      expect(gitlabCIInstrumentationSuppressed(), isFalse);
    });

    test('GitlabCIResult fields default null', () {
      const r = GitlabCIResult();
      expect(r.statusCode, isNull);
    });
  });
}

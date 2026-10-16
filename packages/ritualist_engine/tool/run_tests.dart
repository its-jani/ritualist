// Zero-dependency test runner for the engine package.
//
//   dart run tool/run_tests.dart      (from packages/ritualist_engine)
//
// Exits non-zero when any test fails.
// ignore_for_file: avoid_print

import 'dart:io';

import '../test/mini_test.dart' as harness;
import '../test/models_test.dart' as models;
import '../test/progress_test.dart' as progress;
import '../test/review_test.dart' as review;
import '../test/runner_test.dart' as runner;
import '../test/srs_test.dart' as srs;
import '../test/validators_test.dart' as validators;

void main() {
  print('ritualist_engine test suite');
  print('===========================');

  models.main();
  srs.main();
  runner.main();
  progress.main();
  review.main();
  validators.main();

  exit(harness.report());
}

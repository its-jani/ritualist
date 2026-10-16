// A tiny zero-dependency test harness.
//
// The engine package deliberately has NO pub.dev dependencies (not even
// `package:test`), so tests run fully offline via:
//
//   dart run tool/run_tests.dart
//
// API is intentionally `package:test`-shaped (group/test/expect*) so files
// read the same way they would with the standard runner.
// ignore_for_file: avoid_print

import 'dart:convert';

final List<String> _failures = <String>[];
final List<String> _groupStack = <String>[];
int _passed = 0;
int _total = 0;

void group(String name, void Function() body) {
  _groupStack.add(name);
  try {
    body();
  } finally {
    _groupStack.removeLast();
  }
}

void test(String name, void Function() body) {
  _total++;
  final fullName = [..._groupStack, name].join(' > ');
  try {
    body();
    _passed++;
  } catch (e, st) {
    final first = e.toString().split('\n').first;
    _failures.add('$fullName\n      $first');
    print('FAIL  $fullName');
    print('      $first');
    if (!(e is StateError)) {
      print(st.toString().split('\n').take(4).map((l) => '      $l').join('\n'));
    }
  }
}

void expectTrue(bool value, {String? reason}) {
  if (!value) {
    throw StateError('Expected true${reason == null ? '' : ' ($reason)'}');
  }
}

void expectFalse(bool value, {String? reason}) => expectTrue(!value, reason: reason);

void expectEq(Object? actual, Object? expected, {String? reason}) {
  if (!_deepEquals(actual, expected)) {
    throw StateError(
        'Expected ${_repr(expected)} but got ${_repr(actual)}'
        '${reason == null ? '' : ' ($reason)'}');
  }
}

void expectClose(double actual, double expected, {double epsilon = 1e-9}) {
  if ((actual - expected).abs() > epsilon) {
    throw StateError('Expected ~$expected but got $actual');
  }
}

void expectThrows(void Function() body) {
  try {
    body();
  } catch (_) {
    return;
  }
  throw StateError('Expected an exception, but none was thrown');
}

bool _deepEquals(Object? a, Object? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a is num && b is num) {
    return a == b;
  }
  if (a is List && b is List) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) {
      return false;
    }
    for (final key in a.keys) {
      if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) {
        return false;
      }
    }
    return true;
  }
  if (a is Set && b is Set) {
    return a.length == b.length && a.containsAll(b);
  }
  return a == b;
}

String _repr(Object? v) {
  if (v is String) {
    return "'$v'";
  }
  if (v is Map || v is List) {
    try {
      return jsonEncode(v);
    } catch (_) {
      return v.toString();
    }
  }
  return v.toString();
}

/// Prints the summary; returns a process exit code.
int report() {
  print('');
  if (_failures.isEmpty) {
    print('ALL GREEN - $_passed/$_total tests passed.');
    return 0;
  }
  print('$_passed/$_total passed, ${_failures.length} FAILED:');
  for (final f in _failures) {
    print('  - $f');
  }
  return 1;
}

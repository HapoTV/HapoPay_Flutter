#!/usr/bin/env dart

// Bump pubspec.yaml version: name version: X.Y.Z+BUILD
// Usage:
//   dart run tool/bump_version.dart build   # 1.0.0+1 -> 1.0.0+2
//   dart run tool/bump_version.dart patch   # 1.0.0+1 -> 1.0.1+2
//   dart run tool/bump_version.dart minor   # 1.0.0+1 -> 1.1.0+2
//   dart run tool/bump_version.dart major   # 1.0.0+1 -> 2.0.0+2

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty ||
      !const {'build', 'patch', 'minor', 'major'}.contains(args.first)) {
    stderr.writeln(
      'Usage: dart run tool/bump_version.dart <build|patch|minor|major>',
    );
    exit(64);
  }

  final mode = args.first;
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('Run from repo root (pubspec.yaml not found).');
    exit(1);
  }

  final text = pubspec.readAsStringSync();
  final match = RegExp(
    r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$',
    multiLine: true,
  ).firstMatch(text);
  if (match == null) {
    stderr.writeln(
      'Could not parse version: expected "version: X.Y.Z+BUILD" in pubspec.yaml',
    );
    exit(1);
  }

  var major = int.parse(match.group(1)!);
  var minor = int.parse(match.group(2)!);
  var patch = int.parse(match.group(3)!);
  var build = int.parse(match.group(4)!);

  switch (mode) {
    case 'build':
      build += 1;
    case 'patch':
      patch += 1;
      build += 1;
    case 'minor':
      minor += 1;
      patch = 0;
      build += 1;
    case 'major':
      major += 1;
      minor = 0;
      patch = 0;
      build += 1;
  }

  final next = '$major.$minor.$patch+$build';
  final updated = text.replaceFirst(match.group(0)!, 'version: $next');
  pubspec.writeAsStringSync(updated);
  stdout.writeln('version: ${match.group(0)!.split(':').last.trim()} → $next');
}

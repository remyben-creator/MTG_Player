#!/usr/bin/env dart

import 'dart:io';

void main() async {
  final pubspecFile = File('pubspec.yaml');
  final content = await pubspecFile.readAsString();

  // Find the assets section
  final assetsSectionStart = content.indexOf('  assets:');
  if (assetsSectionStart == -1) {
    print('Error: Could not find assets section in pubspec.yaml');
    exit(1);
  }

  // Find the end of assets section (next line that doesn't start with spaces or is a comment)
  final linesAfterAssets = content.substring(assetsSectionStart).split('\n');
  int assetsSectionEnd = 1;
  for (int i = 1; i < linesAfterAssets.length; i++) {
    final line = linesAfterAssets[i];
    if (!line.startsWith('    -') && !line.trim().isEmpty) {
      assetsSectionEnd = i;
      break;
    }
  }

  // Get all subdirectories in assets/card_art
  final cardArtDir = Directory('assets/card_art');
  final subdirs = await cardArtDir
      .list()
      .where((entity) => entity is Directory)
      .map((entity) => entity.path.replaceAll('\\', '/'))
      .toList();

  print('Found ${subdirs.length} card set directories');

  // Generate new assets section
  final assetsLines = <String>['  assets:'];
  for (final dir in subdirs) {
    assetsLines.add('    - $dir/');
  }

  // Rebuild pubspec.yaml
  final beforeAssets = content.substring(0, assetsSectionStart);
  final afterAssetsStart = assetsSectionStart + linesAfterAssets.take(assetsSectionEnd).join('\n').length;
  final afterAssets = content.substring(afterAssetsStart);

  final newContent = beforeAssets + assetsLines.join('\n') + afterAssets;

  await pubspecFile.writeAsString(newContent);

  print('Updated pubspec.yaml with ${subdirs.length} asset directories');
  print('Run "flutter pub get" to apply changes');
}

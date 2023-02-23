import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:png_chunks_extract/png_chunks_extract.dart' as pngExtract;

void main() {
  test('png_chunks_extract', () {
    var dir = Directory.current.path;
    if (dir.endsWith('/test')) {
      dir = dir.replaceAll('/test', '');
    }
    File file = File('$dir/test/test.png');
    final data = file.readAsBytesSync();

    final trunk = pngExtract.extractChunks(data);
    final names = trunk.map((e) => e['name']).toList(growable: false);
    final lengths = trunk.map((e) => (e['data'] as List).length).toList(growable: false);

    expect(names, [
      'IHDR',
      'iCCP',
      'pHYs',
      'iTXt',
      'IDAT',
      'IDAT',
      'IDAT',
      'IDAT',
      'IEND'
    ], reason: 'extracted chunk names are as expected');

    expect(lengths, [ 13, 3094, 9, 413, 16384, 16384, 16384, 7168, 0 ], reason: 'extracted chunk lengths are as expected');
  });
}
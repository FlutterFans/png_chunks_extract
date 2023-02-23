import 'dart:io';
import 'package:png_chunks_extract/png_chunks_extract.dart' as pngExtract;

void main() {
  var dir = Directory.current.path;
  if (dir.endsWith('/test')) {
    dir = dir.replaceAll('/test', '');
  }
  File file = File('$dir/test/test.png');
  final data = file.readAsBytesSync();

  final trunk = pngExtract.extractChunks(data);
  final names = trunk.map((e) => e['name']).toList(growable: false);
  final lengths =
  trunk.map((e) => (e['data'] as List).length).toList();

  print('name:$names, $lengths');
}
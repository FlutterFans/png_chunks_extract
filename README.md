# png_chunks_extract

[![pub package](https://img.shields.io/pub/v/png_chunks_extract.svg)](https://pub.dev/packages/png_chunks_extract)

Dart port of [png-chunks-extract](https://github.com/hughsk/png-chunks-extract).

Extract the data chunks from a PNG file.

## Features

Useful for reading the metadata of a PNG image, or as the base of a more complete PNG parser.

## Getting started

In the pubspec.yaml of your flutter project, add the following dependency:

```yaml
dependencies:
...
png_chunks_extract: ^1.0.0
```

Import it:

```dart
import 'package:png_chunks_extract/png_chunks_extract.dart' as pngExtract;
```

## Usage

```dart
import 'package:png_chunks_extract/png_chunks_extract.dart' as pngExtract;

final chunks = pngExtract.extract(data);
```

Takes the raw image file data as a Uint8List, and returns an array of chunks.
Each chunk has a name and data buffer:
```
[
  { name: 'IHDR', data: Uint8List([...]) },
  { name: 'IDAT', data: Uint8List([...]) },
  { name: 'IDAT', data: Uint8List([...]) },
  { name: 'IDAT', data: Uint8List([...]) },
  { name: 'IDAT', data: Uint8List([...]) },
  { name: 'IEND', data: Uint8List([]) }
]
```

## Example: 

`test/png_chunks_extract_test.dart`
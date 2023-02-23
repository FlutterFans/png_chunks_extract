import 'dart:typed_data';

import 'etc32.dart';

var uint8 = Uint8List(4);
var int32 = Int32List.view(uint8.buffer);
var uint32 = Uint32List.view(uint8.buffer);

List<Map<String, dynamic>> extractChunks(Uint8List data) {
  if (data[0] != 0x89) throw ArgumentError('Invalid .png file header');
  if (data[1] != 0x50) throw ArgumentError('Invalid .png file header');
  if (data[2] != 0x4E) throw ArgumentError('Invalid .png file header');
  if (data[3] != 0x47) throw ArgumentError('Invalid .png file header');
  if (data[4] != 0x0D) {
    throw ArgumentError('Invalid .png file header: possibly caused by DOS-Unix line ending conversion?');
  }
  if (data[5] != 0x0A) {
    throw ArgumentError('Invalid .png file header: possibly caused by DOS-Unix line ending conversion?');
  }
  if (data[6] != 0x1A) throw ArgumentError('Invalid .png file header');
  if (data[7] != 0x0A) {
    throw ArgumentError('Invalid .png file header: possibly caused by DOS-Unix line ending conversion?');
  }

  var ended = false;
  var chunks = <Map<String, dynamic>> [];
  var idx = 8;

  while (idx < data.length) {
    // Read the length of the current chunk,
    // which is stored as a Uint32.
    uint8[3] = data[idx++];
    uint8[2] = data[idx++];
    uint8[1] = data[idx++];
    uint8[0] = data[idx++];

    // Chunk includes name/type for CRC check (see below).
    var length = uint32[0] + 4;
    var chunk = Uint8List(length);
    chunk[0] = data[idx++];
    chunk[1] = data[idx++];
    chunk[2] = data[idx++];
    chunk[3] = data[idx++];

    // Get the name in ASCII for identification.
    var name = (String.fromCharCode(chunk[0]) +
        String.fromCharCode(chunk[1]) +
        String.fromCharCode(chunk[2]) +
        String.fromCharCode(chunk[3]));

    // The IHDR header MUST come first.
    if (chunks.isEmpty && name != 'IHDR') {
      throw UnsupportedError('IHDR header missing');
    }

    // The IEND header marks the end of the file,
    // so on discovering it break out of the loop.
    if (name == 'IEND') {
      ended = true;
      chunks.add({
        'name': name,
        'data': Uint8List(0),
      });

      break;
    }

    // Read the contents of the chunk out of the main buffer.
    for (var i = 4; i < length; i++) {
      chunk[i] = data[idx++];
    }

    // Read out the CRC value for comparison.
    // It's stored as an Int32.
    uint8[3] = data[idx++];
    uint8[2] = data[idx++];
    uint8[1] = data[idx++];
    uint8[0] = data[idx++];

    var crcActual = int32[0];
    var crcExpect = Crc32.getCrc32(chunk);
    if (crcExpect != crcActual) {
      throw UnsupportedError('CRC values for $name header do not match, PNG file is likely corrupted');
    }

    // The chunk data is now copied to remove the 4 preceding
    // bytes used for the chunk name/type.

    var chunkData = Uint8List.fromList(chunk.sublist(4));

    chunks.add({'name': name, 'data': chunkData});
  }

  if (!ended) {
    throw UnsupportedError('.png file ended prematurely: no IEND header was found');
  }

  return chunks;
}

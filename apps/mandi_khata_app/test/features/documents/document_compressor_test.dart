import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mandi_khata_app/features/documents/data/document_compressor.dart';

void main() {
  test('a big photo is scaled to 1600 px with a small thumbnail', () async {
    final big = img.Image(width: 3200, height: 2400);
    final bytes = Uint8List.fromList(img.encodePng(big));
    final out = await DocumentCompressor.compress('scan.png', bytes);
    expect(out, isNotNull);
    expect(out!.contentType, 'image/jpeg');
    expect(out.fileName, 'scan.jpg');
    final full = img.decodeJpg(out.bytes)!;
    expect(full.width, 1600);
    expect(full.height, 1200);
    expect(img.decodeJpg(out.thumb!)!.width, 240);
  });

  test('a PDF passes through; an unknown type is refused', () async {
    final pdf = Uint8List.fromList([1, 2, 3]);
    final out = await DocumentCompressor.compress('a.pdf', pdf);
    expect(out!.bytes, pdf);
    expect(out.thumb, isNull);
    expect(await DocumentCompressor.compress('a.exe', pdf), isNull);
  });

  test('an undecodable picture is kept as is when small', () async {
    final junk = Uint8List.fromList([1, 2, 3]);
    final out = await DocumentCompressor.compress('a.heic', junk);
    expect(out!.bytes, junk);
    expect(out.contentType, 'image/heic');
  });
}

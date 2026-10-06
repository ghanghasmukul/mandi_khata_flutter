import 'package:file_picker/file_picker.dart';
import 'package:mandi_khata_app/features/expenses/domain/expense.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bill_picker.g.dart';

/// Opens the system picker for a bill photo (or PDF); null when cancelled.
typedef BillPickerFn = Future<BillPhoto?> Function();

@Riverpod(keepAlive: true)
BillPickerFn billPicker(Ref ref) => () async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'heic', 'pdf'],
  );
  if (file == null) return null;
  return BillPhoto(
    file.name,
    await file.readAsBytes(),
    contentTypeOf(file.name),
  );
};

/// The MIME type of a bill file from its name.
String contentTypeOf(String name) {
  final ext = name.split('.').last.toLowerCase();
  return switch (ext) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'heic' => 'image/heic',
    'pdf' => 'application/pdf',
    _ => 'image/jpeg',
  };
}

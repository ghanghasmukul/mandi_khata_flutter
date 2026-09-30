import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Ctrl+[key] on Windows / Android keyboards and ⌘+[key] on macOS, as a
/// [CallbackShortcuts] map entry pair.
Map<ShortcutActivator, VoidCallback> primaryShortcut(
  LogicalKeyboardKey key,
  VoidCallback onPressed,
) => {
  SingleActivator(key, control: true): onPressed,
  SingleActivator(key, meta: true): onPressed,
};

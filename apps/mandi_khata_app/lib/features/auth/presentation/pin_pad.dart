import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Dots + a 3×4 keypad for entering a 4–6 digit PIN.
///
/// Desktop: type digits, Backspace deletes, Enter submits. The entry clears
/// itself after each submit.
class PinPad extends StatefulWidget {
  const PinPad({
    required this.onSubmit,
    super.key,
    this.autoSubmitLength,
    this.enabled = true,
    this.errorText,
  });

  /// Called with the digits when OK / Enter is pressed (4–6 digits), or as
  /// soon as [autoSubmitLength] digits are typed.
  final ValueChanged<String> onSubmit;
  final int? autoSubmitLength;
  final bool enabled;
  final String? errorText;

  static const maxLength = 6;
  static const minLength = 4;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _digits = '';
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _add(String d) {
    if (!widget.enabled || _digits.length >= PinPad.maxLength) return;
    setState(() => _digits += d);
    if (_digits.length == widget.autoSubmitLength) _submit();
  }

  void _delete() {
    if (!widget.enabled || _digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  void _submit() {
    if (!widget.enabled || _digits.length < PinPad.minLength) return;
    final value = _digits;
    setState(() => _digits = '');
    widget.onSubmit(value);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final char = event.character;
    if (char != null && RegExp(r'^\d$').hasMatch(char)) {
      _add(char);
    } else if (key == LogicalKeyboardKey.backspace) {
      _delete();
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _submit();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final slots = widget.autoSubmitLength ?? PinPad.maxLength;
    final error = widget.errorText;

    Widget key(String label, {VoidCallback? onTap, Widget? child}) => SizedBox(
      width: 72,
      height: 64,
      child: TextButton(
        onPressed: widget.enabled ? onTap : null,
        style: TextButton.styleFrom(shape: const CircleBorder()),
        child: child ?? Text(label, style: const TextStyle(fontSize: 24)),
      ),
    );

    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: '${_digits.length} / $slots',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < slots; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _digits.length
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      border: Border.all(
                        color: tokens.borderStrong,
                        width: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 36,
            child: Center(
              child: error == null
                  ? null
                  : Text(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
            ),
          ),
          for (final row in const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ])
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [for (final d in row) key(d, onTap: () => _add(d))],
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              key(
                l10n.pinPadDelete,
                onTap: _delete,
                child: Semantics(
                  label: l10n.pinPadDelete,
                  child: const Icon(Icons.backspace_outlined),
                ),
              ),
              key('0', onTap: () => _add('0')),
              key(
                l10n.pinPadOk,
                onTap: _submit,
                child: Text(
                  l10n.pinPadOk,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

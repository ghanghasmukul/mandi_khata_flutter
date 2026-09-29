import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mk_ui/src/theme.dart';

/// Label above an input, as in the prototype forms.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: MkTokens.of(context).textBody,
        ),
      ),
    );
  }
}

/// Single- or multi-line text input with an optional label above it.
class MkTextField extends StatelessWidget {
  const MkTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.style,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;

  /// Used only when [controller] is null.
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Widget? suffix;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final bool obscureText;
  final int maxLines;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      autofocus: autofocus,
      enabled: enabled,
      obscureText: obscureText,
      maxLines: maxLines,
      style: style ?? const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefix,
        suffixIcon: suffix,
        prefixIconConstraints: const BoxConstraints(minWidth: 32),
        constraints: BoxConstraints(minHeight: mkIsTouch(context) ? 48 : 40),
      ),
    );
    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [_FieldLabel(label!), field],
    );
  }
}

/// What an [MkNumberField] holds.
enum MkNumberKind {
  /// Rupees and paise; the value is whole paise.
  money,

  /// A whole number such as bags or days.
  integer,
}

/// Blocks keystrokes that cannot become a valid value: letters, a second
/// decimal point, a third decimal digit or too many digits. Commas and spaces
/// are ignored so pasted `1,55,580` works.
class MkNumberInputFormatter extends TextInputFormatter {
  const MkNumberInputFormatter(this.kind);

  final MkNumberKind kind;

  /// Keeps amounts inside the range an int holds exactly on the web.
  static const maxDigits = 13;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text.replaceAll(RegExp(r'[\s,]'), '');
    final pattern = kind == MkNumberKind.money
        ? RegExp(
            r'^\d{0,'
            '$maxDigits'
            r'}(\.\d{0,2})?$',
          )
        : RegExp(
            r'^\d{0,'
            '$maxDigits'
            r'}$',
          );
    if (!pattern.hasMatch(cleaned)) return oldValue;
    if (cleaned == newValue.text) return newValue;
    final removed = newValue.text.length - cleaned.length;
    final offset = (newValue.selection.baseOffset - removed).clamp(
      0,
      cleaned.length,
    );
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

/// Numeric input that never goes through `double`.
///
/// For [MkNumberKind.money] the reported value is whole paise, parsed with
/// `Money.tryParse`; for [MkNumberKind.integer] it is the integer. `null` means
/// empty or not yet a valid number (e.g. just ".").
class MkNumberField extends StatefulWidget {
  const MkNumberField({
    required this.onChanged,
    super.key,
    this.kind = MkNumberKind.money,
    this.initialValue,
    this.label,
    this.hint,
    this.errorText,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.suffixText,
  });

  final MkNumberKind kind;

  /// Paise for money, the plain value for integers.
  final int? initialValue;
  final ValueChanged<int?> onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  /// Unit after the value, e.g. "qtl" or "bags".
  final String? suffixText;

  /// Parses field text into the reported value.
  static int? parse(String text, MkNumberKind kind) {
    if (kind == MkNumberKind.money) return Money.tryParse(text)?.paise;
    final cleaned = text.replaceAll(RegExp(r'[\s,]'), '');
    return RegExp(r'^\d+$').hasMatch(cleaned) ? int.parse(cleaned) : null;
  }

  @override
  State<MkNumberField> createState() => _MkNumberFieldState();
}

class _MkNumberFieldState extends State<MkNumberField> {
  late final TextEditingController _controller = TextEditingController(
    text: _initialText(),
  );

  String _initialText() {
    final v = widget.initialValue;
    if (v == null) return '';
    return widget.kind == MkNumberKind.money
        ? Money(v).format(symbol: false).replaceAll(',', '')
        : '$v';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMoney = widget.kind == MkNumberKind.money;
    final mono = MkText.mono();
    return MkTextField(
      controller: _controller,
      label: widget.label,
      hint: widget.hint,
      errorText: widget.errorText,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      style: mono,
      keyboardType: TextInputType.numberWithOptions(decimal: isMoney),
      inputFormatters: [MkNumberInputFormatter(widget.kind)],
      prefix: isMoney
          ? Padding(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Text('₹', style: mono),
            )
          : null,
      suffix: widget.suffixText == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Align(
                widthFactor: 1,
                child: Text(
                  widget.suffixText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: MkTokens.of(context).textMuted,
                  ),
                ),
              ),
            ),
      onChanged: (text) =>
          widget.onChanged(MkNumberField.parse(text, widget.kind)),
      onSubmitted: widget.onSubmitted == null
          ? null
          : (_) => widget.onSubmitted!(),
    );
  }
}

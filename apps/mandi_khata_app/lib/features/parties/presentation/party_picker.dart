import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Picks a party with [role] by typing: results appear after
/// [minChars] characters (name, father's name, village, code or mobile).
/// ↑ / ↓ move, Enter picks, Esc clears the search. Once picked, the party is
/// shown with a button to change it.
class PartyPicker extends ConsumerStatefulWidget {
  const PartyPicker({
    required this.role,
    required this.selected,
    required this.onSelected,
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.minChars = 3,
    this.maxResults = 6,
  });

  final PartyRole role;
  final Party? selected;

  /// Null when the choice is cleared.
  final ValueChanged<Party?> onSelected;
  final String? label;
  final String? hint;
  final String? errorText;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final int minChars;
  final int maxResults;

  @override
  ConsumerState<PartyPicker> createState() => _PartyPickerState();
}

class _PartyPickerState extends ConsumerState<PartyPicker> {
  final _controller = TextEditingController();
  FocusNode? _ownFocus;
  String _query = '';
  int _highlight = 0;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void dispose() {
    _controller.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  bool get _searching => _query.trim().length >= widget.minChars;

  List<Party> _results() {
    if (!_searching) return const [];
    final all = ref.watch(partyListProvider(_query, widget.role)).value;
    if (all == null) return const [];
    return all.take(widget.maxResults).toList();
  }

  void _pick(Party p) {
    _controller.clear();
    setState(() {
      _query = '';
      _highlight = 0;
    });
    widget.onSelected(p);
  }

  void _clear() {
    widget.onSelected(null);
    _focus.requestFocus();
  }

  void _move(int by, int count) {
    if (count == 0) return;
    setState(() => _highlight = (_highlight + by) % count);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = widget.selected;
    if (selected != null) return _selectedView(context, l10n, selected);

    final results = _results();
    if (_highlight >= results.length) _highlight = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                _move(1, results.length),
            const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                _move(-1, results.length),
            const SingleActivator(LogicalKeyboardKey.escape): () {
              _controller.clear();
              setState(() => _query = '');
            },
          },
          child: MkTextField(
            controller: _controller,
            focusNode: _focus,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            label: widget.label,
            hint: widget.hint ?? l10n.partyPickerHint(widget.minChars),
            errorText: widget.errorText,
            textInputAction: TextInputAction.next,
            prefix: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.search, size: 20),
            ),
            onChanged: (v) => setState(() {
              _query = v;
              _highlight = 0;
            }),
            onSubmitted: (_) {
              if (results.isNotEmpty) {
                _pick(results[_highlight]);
              } else {
                _focus.requestFocus();
              }
            },
          ),
        ),
        if (_searching)
          _ResultList(results: results, highlight: _highlight, onPick: _pick),
      ],
    );
  }

  Widget _selectedView(BuildContext context, AppLocalizations l10n, Party p) {
    final tokens = MkTokens.of(context);
    final details = [p.code, ?p.village, ?p.mobile].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: tokens.textMuted,
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: tokens.border),
            borderRadius: BorderRadius.circular(MkRadius.md),
          ),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              child: Text(p.name.characters.first.toUpperCase()),
            ),
            title: Text(
              l10n.partyFullName(p),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              details,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: widget.enabled
                ? IconButton(
                    tooltip: l10n.partyPickerChange,
                    icon: const Icon(Icons.close),
                    onPressed: _clear,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.results,
    required this.highlight,
    required this.onPick,
  });

  final List<Party> results;
  final int highlight;
  final ValueChanged<Party> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(MkSpacing.md),
        child: Text(
          l10n.partiesNoMatch,
          style: TextStyle(color: tokens.textMuted),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(top: MkSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < results.length; i++)
            ListTile(
              key: ValueKey('party-pick-${results[i].id}'),
              selected: i == highlight,
              selectedTileColor: tokens.rowHover,
              title: Text(
                l10n.partyFullName(results[i]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                [results[i].code, ?results[i].village].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => onPick(results[i]),
            ),
        ],
      ),
    );
  }
}

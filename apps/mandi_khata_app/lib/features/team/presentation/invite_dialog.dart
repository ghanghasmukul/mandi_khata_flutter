import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/team/data/invite_service.dart';
import 'package:mandi_khata_app/features/team/presentation/permission_grid.dart';
import 'package:mandi_khata_app/features/team/presentation/team_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Invite a phone number: role + permissions, sent by WhatsApp / SMS through
/// the `invite-member` Edge Function. Online only (needs the server).
class InviteDialog extends ConsumerStatefulWidget {
  const InviteDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
    context: context,
    barrierColor: MkColors.scrim,
    builder: (_) => const InviteDialog(),
  );

  @override
  ConsumerState<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<InviteDialog> {
  final _phone = TextEditingController();
  final _name = TextEditingController();
  MemberRole _role = MemberRole.munshi;
  Set<Permission> _granted = TeamRules.effective(MemberRole.munshi, const {});
  String _channel = 'whatsapp';
  bool _sending = false;
  String? _error;
  String? _phoneError;

  /// Set when nothing could be sent: the owner shares this by hand.
  InviteSent? _manual;

  @override
  void dispose() {
    _phone.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final (draft, problem) = TeamRules.validateInvite(
      phone: _phone.text,
      role: _role,
    );
    if (draft == null) {
      setState(() {
        _error = null;
        _phoneError = problem == InviteError.phone
            ? l10n.inviteErrPhone
            : l10n.inviteErrRole;
      });
      return;
    }
    // Read before the first await.
    final ctx = ref.read(writeContextProvider);
    final lang = Localizations.localeOf(context).languageCode;
    if (ctx == null) return;
    setState(() {
      _sending = true;
      _error = null;
      _phoneError = null;
    });
    final result = await ref
        .read(inviteServiceProvider)
        .invite(
          tenantId: ctx.tenantId,
          phone: draft.phone,
          role: _role.name,
          customPermissions: TeamRules.overridesFor(_role, _granted),
          fullName: _name.text.trim().isEmpty ? null : _name.text.trim(),
          deviceId: ctx.deviceId,
          language: lang,
          channel: _channel,
        );
    if (!mounted) return;
    switch (result) {
      case InviteRejected(:final reason):
        setState(() {
          _sending = false;
          if (reason == InviteFailure.invalidPhone) {
            _phoneError = l10n.inviteErrPhone;
          } else {
            _error = l10n.inviteError(reason);
          }
        });
      case InviteSent(:final delivery, :final phone)
          when delivery != InviteDelivery.none:
        Navigator.of(context).pop();
        final shown = TeamRules.displayPhone(phone);
        MkToast.show(
          context,
          delivery == InviteDelivery.whatsapp
              ? l10n.inviteSentWhatsapp(shown)
              : l10n.inviteSentSms(shown),
          tone: MkToastTone.success,
        );
      case final InviteSent sent:
        setState(() {
          _sending = false;
          _manual = sent;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final manual = _manual;
    if (manual != null) {
      return MkDialog(
        title: l10n.inviteNotSentTitle,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.inviteNotSentBody(TeamRules.displayPhone(manual.phone))),
            const SizedBox(height: MkSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.surfaceAlt,
                border: Border.all(color: tokens.border),
                borderRadius: BorderRadius.circular(MkRadius.sm),
              ),
              child: Padding(
                padding: const EdgeInsets.all(MkSpacing.md),
                child: SelectableText(
                  manual.message,
                  key: const ValueKey('invite-message'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          MkButton(
            label: l10n.inviteCopy,
            icon: Icons.copy,
            variant: MkButtonVariant.secondary,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: manual.message));
              if (context.mounted) {
                MkToast.show(context, l10n.inviteCopied);
              }
            },
          ),
          MkButton(
            label: l10n.commonClose,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }
    return MkDialog(
      title: l10n.inviteTitle,
      maxWidth: 560,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MkTextField(
            key: const ValueKey('invite-phone'),
            controller: _phone,
            label: l10n.invitePhone,
            hint: '98140 22110',
            autofocus: true,
            keyboardType: TextInputType.phone,
            prefix: const Padding(
              padding: EdgeInsets.only(left: 12, right: 6),
              child: Center(widthFactor: 1, child: Text('+91')),
            ),
            errorText: _phoneError,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: MkSpacing.md),
          MkTextField(
            key: const ValueKey('invite-name'),
            controller: _name,
            label: l10n.inviteName,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _send(),
          ),
          const SizedBox(height: MkSpacing.lg),
          Text(l10n.teamRole, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: MkSpacing.sm),
          RoleChoice(
            roles: TeamRules.invitableRoles,
            selected: _role,
            enabled: !_sending,
            onSelected: (r) => setState(() {
              _role = r;
              _granted = TeamRules.effective(r, const {});
            }),
          ),
          const SizedBox(height: MkSpacing.lg),
          Text(
            l10n.teamPermissions,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          PermissionGrid(
            role: _role,
            granted: _granted,
            enabled: !_sending,
            onChanged: (p, {required on}) => setState(() {
              _granted = {..._granted};
              if (on) {
                _granted.add(p);
              } else {
                _granted.remove(p);
              }
            }),
          ),
          const SizedBox(height: MkSpacing.md),
          Text(
            l10n.inviteChannel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: MkSpacing.sm),
          Wrap(
            spacing: MkSpacing.sm,
            children: [
              ChoiceChip(
                key: const ValueKey('channel-whatsapp'),
                label: Text(l10n.inviteChannelWhatsapp),
                selected: _channel == 'whatsapp',
                onSelected: (_) => setState(() => _channel = 'whatsapp'),
              ),
              ChoiceChip(
                key: const ValueKey('channel-sms'),
                label: Text(l10n.inviteChannelSms),
                selected: _channel == 'sms',
                onSelected: (_) => setState(() => _channel = 'sms'),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.md),
              child: Text(
                _error!,
                key: const ValueKey('invite-error'),
                style: TextStyle(color: tokens.udhaar),
              ),
            ),
        ],
      ),
      actions: [
        MkButton(
          label: l10n.commonCancel,
          variant: MkButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MkButton(
          key: const ValueKey('invite-send'),
          label: l10n.inviteSend,
          icon: Icons.send,
          busy: _sending,
          onPressed: _send,
        ),
      ],
    );
  }
}

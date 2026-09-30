import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/auth/sign_out_service.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

enum _Choice { signOut, uploadFirst }

/// Asks before signing out. With changes still queued it offers to upload
/// them first; signing out anyway deletes them (the local database is
/// cleared on sign-out).
Future<void> confirmAndSignOut(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final service = ref.read(signOutServiceProvider);
  final pending = await service.pendingChanges();
  if (!context.mounted) return;

  final choice = await MkDialog.show<_Choice>(
    context,
    title: l10n.signOutTitle,
    content: Text(
      pending == 0 ? l10n.signOutBody : l10n.signOutPendingBody(pending),
    ),
    actions: [
      Builder(
        builder: (context) => MkButton(
          label: l10n.commonCancel,
          variant: MkButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      if (pending > 0) ...[
        Builder(
          builder: (context) => MkButton(
            label: l10n.signOutAnyway,
            variant: MkButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(_Choice.signOut),
          ),
        ),
        Builder(
          builder: (context) => MkButton(
            label: l10n.signOutUploadFirst,
            icon: Icons.cloud_upload_outlined,
            onPressed: () => Navigator.of(context).pop(_Choice.uploadFirst),
          ),
        ),
      ] else
        Builder(
          builder: (context) => MkButton(
            label: l10n.accountSignOut,
            icon: Icons.logout,
            onPressed: () => Navigator.of(context).pop(_Choice.signOut),
          ),
        ),
    ],
  );
  if (choice == null || !context.mounted) return;

  if (choice == _Choice.uploadFirst) {
    final uploaded = await _withProgress(
      context,
      l10n.signOutUploading,
      service.waitForUpload(),
    );
    if (!uploaded) {
      if (context.mounted) {
        MkToast.show(
          context,
          l10n.signOutUploadFailed,
          tone: MkToastTone.error,
        );
      }
      return;
    }
  }
  // The router moves to /login once the session ends.
  await service.signOut();
}

Future<T> _withProgress<T>(
  BuildContext context,
  String message,
  Future<T> work,
) async {
  final navigator = Navigator.of(context);
  final dialog = showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: MkColors.scrim,
    builder: (_) => PopScope(
      canPop: false,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(MkSpacing.xl),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: MkSpacing.lg),
              Flexible(child: Text(message)),
            ],
          ),
        ),
      ),
    ),
  );
  try {
    return await work;
  } finally {
    navigator.pop();
    await dialog;
  }
}

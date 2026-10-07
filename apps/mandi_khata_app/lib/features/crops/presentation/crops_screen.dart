import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:mandi_khata_app/features/crops/presentation/crop_form_dialog.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/shortcuts.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class CropRoutes {
  static const list = '/crops';
  static String detail(String id) => '/crops/$id';
}

/// The business's crops master. Owners add crops (Ctrl/⌘+N) and open one to
/// set its mandi charges.
class CropsScreen extends ConsumerStatefulWidget {
  const CropsScreen({super.key});

  @override
  ConsumerState<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends ConsumerState<CropsScreen> {
  bool _showInactive = false;

  Future<void> _add() async {
    final id = await CropFormDialog.show(context);
    if (id != null && mounted) context.go(CropRoutes.detail(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAdd = ref.watch(canProvider(Permission.settingsManage));
    final crops = ref
        .watch(cropListProvider(includeInactive: _showInactive))
        .value;

    return CallbackShortcuts(
      bindings: {if (canAdd) ...primaryShortcut(LogicalKeyboardKey.keyN, _add)},
      child: Focus(
        autofocus: true,
        child: Scaffold(
          floatingActionButton: canAdd
              ? FloatingActionButton.extended(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.cropsAdd),
                )
              : null,
          body: Column(
            children: [
              MkTopBar(title: l10n.cropsTitle),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(
                      children: [
                        SwitchListTile(
                          key: const ValueKey('crops-show-inactive'),
                          title: Text(l10n.cropsShowInactive),
                          value: _showInactive,
                          onChanged: (v) => setState(() => _showInactive = v),
                        ),
                        Expanded(child: _list(l10n, crops)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(AppLocalizations l10n, List<Crop>? crops) {
    if (crops == null) return const Center(child: CircularProgressIndicator());
    if (crops.isEmpty) {
      return MkEmptyState(icon: Icons.grass_outlined, title: l10n.cropsEmpty);
    }
    return ListView.builder(
      itemCount: crops.length,
      padding: const EdgeInsets.only(bottom: 88),
      itemBuilder: (context, i) => CropTile(crop: crops[i]),
    );
  }
}

/// One row of the crop list.
class CropTile extends StatelessWidget {
  const CropTile({required this.crop, super.key});

  final Crop crop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final rate = crop.stdRate;
    return ListTile(
      onTap: () => context.go(CropRoutes.detail(crop.id)),
      leading: const CircleAvatar(child: Icon(Icons.grass_outlined)),
      title: Text(crop.nameIn(lang)),
      subtitle: Text(
        [
          crop.code,
          if (rate == null)
            l10n.cropNoRate
          else
            l10n.cropRatePerQtl(rate.format()),
        ].join(' · '),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: crop.isActive
          ? const Icon(Icons.chevron_right)
          : MkRoleChip(label: l10n.cropInactive, warning: true),
    );
  }
}

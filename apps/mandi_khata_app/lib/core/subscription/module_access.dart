import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/subscription/subscription_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'module_access.g.dart';

/// Whether [module] (`khata`, `arrivals`, `karza`, `accounting`, `shop`) is
/// usable: the plan includes it AND the business has not switched it off
/// (`app.modules.<m>`). The switch can only turn a module off, never on.
@riverpod
bool moduleEnabled(Ref ref, String module) {
  final planAllows = ref.watch(entitlementsProvider).module(module);
  if (!planAllows) return false;
  final setting = ref.watch(
    settingProvider('app.modules.$module', businessTarget),
  );
  return setting?.value != false;
}

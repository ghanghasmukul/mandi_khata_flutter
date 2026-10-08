import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Camera scanning is offered on Android and iOS only. Safe on web and
/// desktop (no dart:io); the arguments exist so tests can pass a platform.
bool cameraScanSupported({bool? web, TargetPlatform? platform}) {
  if (web ?? kIsWeb) return false;
  final p = platform ?? defaultTargetPlatform;
  return p == TargetPlatform.android || p == TargetPlatform.iOS;
}

/// Ignores the same code seen again within [window] (a camera reports a
/// held barcode many times a second).
class ScanDebouncer {
  ScanDebouncer({this.window = const Duration(milliseconds: 1500)});

  final Duration window;
  String? _last;
  DateTime? _at;

  /// True when [code] should be acted on.
  bool accept(String code, DateTime now) {
    final value = code.trim();
    if (value.isEmpty) return false;
    final at = _at;
    if (value == _last && at != null && now.difference(at) < window) {
      return false;
    }
    _last = value;
    _at = now;
    return true;
  }
}

/// Scan button for the POS search bar; renders nothing where the camera is
/// not supported. [onCode] is the same add-by-barcode path as type + Enter.
class PosScanButton extends StatelessWidget {
  const PosScanButton({
    required this.onCode,
    this.web,
    this.platform,
    super.key,
  });

  final ValueChanged<String> onCode;
  final bool? web;
  final TargetPlatform? platform;

  @override
  Widget build(BuildContext context) {
    if (!cameraScanSupported(web: web, platform: platform)) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    return IconButton(
      key: const ValueKey('pos-scan'),
      tooltip: l10n.posScanTooltip,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: const Icon(Icons.qr_code_scanner),
      onPressed: () => Navigator.of(context).push<void>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => PosScannerPage(onCode: onCode),
        ),
      ),
    );
  }
}

/// Full-screen camera. Stays open so several items can be scanned in a row.
class PosScannerPage extends StatefulWidget {
  const PosScannerPage({required this.onCode, super.key});

  final ValueChanged<String> onCode;

  @override
  State<PosScannerPage> createState() => _PosScannerPageState();
}

class _PosScannerPageState extends State<PosScannerPage> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _debounce = ScanDebouncer();
  String? _last;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _detected(BarcodeCapture capture) {
    for (final b in capture.barcodes) {
      final code = b.rawValue;
      if (code == null || !_debounce.accept(code, DateTime.now())) continue;
      unawaited(HapticFeedback.mediumImpact());
      setState(() => _last = code);
      widget.onCode(code);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.posScanTitle),
        actions: [
          IconButton(
            key: const ValueKey('pos-scan-torch'),
            tooltip: l10n.posScanTorch,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: () => unawaited(_controller.toggleTorch()),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _detected,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  error.errorCode == MobileScannerErrorCode.permissionDenied
                      ? l10n.posScanPermissionDenied
                      : l10n.posScanUnavailable,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _last == null ? l10n.posScanHint : l10n.posScanLast(_last!),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

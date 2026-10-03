import 'package:flutter/foundation.dart' show immutable;

/// A release version `major.minor.patch` (build number and `v` prefix are
/// ignored: `v1.4.2+17` is 1.4.2). Compared numerically, so 1.10.0 > 1.9.0.
@immutable
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);

  static final _pattern = RegExp(r'^v?(\d+)(?:\.(\d+))?(?:\.(\d+))?');

  /// Null for text that is not a version.
  static AppVersion? tryParse(String? text) {
    final m = _pattern.firstMatch((text ?? '').trim());
    if (m == null) return null;
    return AppVersion(
      int.parse(m.group(1)!),
      int.parse(m.group(2) ?? '0'),
      int.parse(m.group(3) ?? '0'),
    );
  }

  final int major;
  final int minor;
  final int patch;

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator <(AppVersion other) => compareTo(other) < 0;
  bool operator >(AppVersion other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

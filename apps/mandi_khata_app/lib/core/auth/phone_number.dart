import 'package:khata_core/khata_core.dart';

/// Indian mobile numbers, as typed at the login screen.
///
/// Accepts what people actually type — `98140 22110`, `098140-22110`,
/// `+91 98140 22110`, `919814022110` — and returns the E.164 form Supabase
/// Auth expects (`+919814022110`), or null if it is not a valid Indian
/// mobile number (10 digits starting 6–9).
String? normaliseIndianMobile(String input) {
  final digits = IndianMobile.normalise(input);
  return digits == null ? null : '+91$digits';
}

/// `+919814022110` → `+91 98140 22110` for display. Other values are
/// returned unchanged.
String formatIndianMobile(String e164) {
  final m = RegExp(r'^\+91(\d{5})(\d{5})$').firstMatch(e164);
  if (m == null) return e164;
  return '+91 ${m[1]} ${m[2]}';
}

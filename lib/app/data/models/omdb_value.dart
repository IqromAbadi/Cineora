/// OMDb sends missing values as the literal string "N/A".
String? omdbValue(Object? raw) {
  if (raw is! String) return null;
  final value = raw.trim();
  if (value.isEmpty || value == 'N/A') return null;
  return value;
}

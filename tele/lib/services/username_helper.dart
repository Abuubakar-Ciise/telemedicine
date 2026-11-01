import 'dart:math';

/// Builds a username from a person's full name with a unique ending,
/// e.g. "Abuubakar Ciise" -> "abuubakar.ciise4821".
String generateUsername(String fullName) {
  final parts = fullName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  final base = parts.isEmpty
      ? 'user'
      : parts.length == 1
          ? parts.first
          : '${parts.first}.${parts.last}';
  final suffix = 1000 + Random.secure().nextInt(9000); // 4 digits
  return '$base$suffix';
}

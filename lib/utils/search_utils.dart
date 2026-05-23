String normalizeSearchText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

bool matchesSearchQuery(String query, List<String?> values) {
  final normalizedQuery = normalizeSearchText(query);
  if (normalizedQuery.isEmpty) return true;

  return values.any((value) {
    final normalizedValue = normalizeSearchText(value ?? '');
    return normalizedValue.contains(normalizedQuery);
  });
}

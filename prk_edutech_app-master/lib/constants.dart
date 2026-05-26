const String kBaseUrl = String.fromEnvironment(
  'BASE_URL',
  // defaultValue: 'http://192.168.0.63:5000',
  defaultValue: 'https://server.prkedutech.com',
);

const String kApiBaseUrl = '$kBaseUrl/api';
const bool kBlockScreenshots = bool.fromEnvironment(
  'BLOCK_SCREENSHOTS',
  defaultValue: true,
);

String buildBaseUrl(String path) {
  if (path.isEmpty) return kBaseUrl;
  return path.startsWith('/') ? '$kBaseUrl$path' : '$kBaseUrl/$path';
}

String buildApiUrl(String path) {
  if (path.isEmpty) return kApiBaseUrl;
  return path.startsWith('/') ? '$kApiBaseUrl$path' : '$kApiBaseUrl/$path';
}

String _asString(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

Map<String, dynamic> normalizeResourceItem(Map<String, dynamic> raw) {
  final normalized = Map<String, dynamic>.from(raw);

  normalized['_id'] = _asString(normalized['_id']);
  normalized['title'] = _asString(
    normalized['title'],
    fallback: _asString(normalized['bookName'], fallback: 'Untitled Resource'),
  );
  normalized['description'] = _asString(
    normalized['description'],
    fallback: 'No description available',
  );
  normalized['author'] = _asString(
    normalized['author'],
    fallback: 'Unknown Author',
  );
  normalized['imageUrl'] = _asString(
    normalized['imageUrl'],
    fallback: _asString(normalized['thumbnail']),
  );
  normalized['pdfUrl'] = _asString(
    normalized['pdfUrl'],
    fallback: _asString(normalized['pdf']),
  );
  normalized['contentType'] = _asString(
    normalized['contentType'],
    fallback: 'ebook',
  );
  normalized['difficultyLevel'] = _asString(
    normalized['difficultyLevel'],
    fallback: 'general',
  );
  normalized['pricing'] = _asString(
    normalized['pricing'],
    fallback: 'free',
  );
  normalized['subject'] = _asString(
    normalized['subject'],
    fallback: 'General',
  );
  normalized['createdAt'] = _asString(
    normalized['createdAt'],
    fallback: DateTime.now().toIso8601String(),
  );

  return normalized;
}

List<Map<String, dynamic>> normalizeResourceList(dynamic decoded) {
  if (decoded is! List) return <Map<String, dynamic>>[];
  return decoded
      .whereType<Map<String, dynamic>>()
      .map(normalizeResourceItem)
      .toList();
}

List<String> resourceListApiCandidates() {
  return <String>[
    buildBaseUrl('resources/'),
    buildApiUrl('resources'),
    buildApiUrl('ebooks'),
  ];
}

List<String> resourceDetailApiCandidates(String id) {
  return <String>[
    buildApiUrl('ebooks/$id'),
    buildBaseUrl('resources/$id'),
    buildApiUrl('resources/$id'),
  ];
}

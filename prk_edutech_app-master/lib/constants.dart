const String kBaseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://192.168.0.23:5000',
  // defaultValue: 'https://server.prkedutech.com',
);

const String kApiBaseUrl = '$kBaseUrl/api';

String buildBaseUrl(String path) {
  if (path.isEmpty) return kBaseUrl;
  return path.startsWith('/') ? '$kBaseUrl$path' : '$kBaseUrl/$path';
}

String buildApiUrl(String path) {
  if (path.isEmpty) return kApiBaseUrl;
  return path.startsWith('/') ? '$kApiBaseUrl$path' : '$kApiBaseUrl/$path';
}

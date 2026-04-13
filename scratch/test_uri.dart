
void main() {
  final baseUrl = 'https://api.medicompares.com/api/v1';
  final path = '/vendor/branch/list';
  final queryParameters = {
    'page': '1',
    'limit': '100',
    'search': 'manjeera',
  };

  final uri = Uri.parse('$baseUrl$path').replace(
    queryParameters: queryParameters,
  );

  print('URI: $uri');
}

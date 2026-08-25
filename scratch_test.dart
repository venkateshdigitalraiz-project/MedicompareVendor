import 'dart:convert';
void main() {
  var jsonStr = '''
  {
    "_id": "123",
    "price": 100,
    "tablets": {
      "name": "Critical Patient Transports",
      "facilities": [
          "699ea11391678356629640fe",
          "69a6765689e508cd55fe19f3",
          "69a9d58c8e7273a31e53efa9",
          "69a6768589e508cd55fe1b81",
          "69a675e889e508cd55fe1907"
      ]
    }
  }
  ''';
  var json = jsonDecode(jsonStr);
  List<dynamic>? rawFacilitiesList = (json['facilitiesDetails'] as List?) ?? (json['facilities'] as List?);
  if (rawFacilitiesList == null || rawFacilitiesList.isEmpty) {
      if (json['tablets'] is Map<String, dynamic>) {
        rawFacilitiesList = (json['tablets']['facilitiesDetails'] as List?) ?? (json['tablets']['facilities'] as List?);
      } else if (json['tablets'] is List && (json['tablets'] as List).isNotEmpty) {
        final tList = json['tablets'] as List;
        if (tList[0] is Map) {
          rawFacilitiesList = (tList[0]['facilitiesDetails'] as List?) ?? (tList[0]['facilities'] as List?);
        }
      }
  }
  print(rawFacilitiesList?.length);
}

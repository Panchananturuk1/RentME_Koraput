// Fallback stubs for non-web platforms to satisfy conditional imports.
Future<List<Map<String, dynamic>>> webAutocomplete(String input, {double? lat, double? lng, int? radius}) async {
  throw UnsupportedError('webAutocomplete is only available on web');
}

Future<Map<String, dynamic>> webPlaceDetails(String placeId) async {
  throw UnsupportedError('webPlaceDetails is only available on web');
}

Future<String?> webReverseGeocode(double lat, double lng) async {
  throw UnsupportedError('webReverseGeocode is only available on web');
}
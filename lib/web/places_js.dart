import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

@JS('PlacesBridge.autocomplete')
external Object _autocomplete(String input, double? lat, double? lng, int? radius);

@JS('PlacesBridge.details')
external Object _details(String placeId);

@JS('PlacesBridge.geocodePlaceId')
external Object _geocodePlaceId(String placeId);

@JS('PlacesBridge.reverseGeocode')
external Object _reverseGeocode(double lat, double lng);

Future<List<Map<String, dynamic>>> webAutocomplete(String input, {double? lat, double? lng, int? radius}) async {
  final res = await js_util.promiseToFuture<List<dynamic>>(
    _autocomplete(input, lat, lng, radius),
  );
  return res.map((item) {
    final desc = js_util.getProperty(item, 'description') as String?;
    final pid = js_util.getProperty(item, 'placeId') as String?;
    return {
      'description': desc ?? '',
      'placeId': pid ?? '',
    };
  }).toList();
}

Future<Map<String, dynamic>> webPlaceDetails(String placeId) async {
  final obj = await js_util.promiseToFuture<dynamic>(_details(placeId));
  final lat = js_util.getProperty(obj, 'lat') as num?;
  final lng = js_util.getProperty(obj, 'lng') as num?;
  final address = js_util.getProperty(obj, 'address') as String?;
  return {
    'lat': lat,
    'lng': lng,
    'address': address,
  };
}

Future<Map<String, dynamic>> webGeocodePlaceId(String placeId) async {
  final obj = await js_util.promiseToFuture<dynamic>(_geocodePlaceId(placeId));
  final lat = js_util.getProperty(obj, 'lat') as num?;
  final lng = js_util.getProperty(obj, 'lng') as num?;
  final address = js_util.getProperty(obj, 'address') as String?;
  return {
    'lat': lat,
    'lng': lng,
    'address': address,
  };
}

Future<String?> webReverseGeocode(double lat, double lng) async {
  try {
    final res = await js_util.promiseToFuture<String>(_reverseGeocode(lat, lng));
    return res;
  } catch (_) {
    return null;
  }
}
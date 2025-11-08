import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/maps_config.dart';
import '../web/places_stub.dart' if (dart.library.html) '../web/places_js.dart' as web;

class PlacePrediction {
  final String description;
  final String placeId;
  PlacePrediction({required this.description, required this.placeId});
}

class PlacesService {
  final String _key = MapsConfig.apiKey;
  final String _base = 'https://maps.googleapis.com/maps/api';

  Future<List<PlacePrediction>> autocomplete(String input, {LatLng? location}) async {
    if (input.trim().isEmpty) return [];
    if (kIsWeb) {
      final maps = await web.webAutocomplete(
        input,
        lat: location?.latitude,
        lng: location?.longitude,
        radius: 50000,
      );
      return maps.map((m) => PlacePrediction(
        description: (m['description'] as String?) ?? '',
        placeId: (m['placeId'] as String?) ?? '',
      )).where((p) => p.placeId.isNotEmpty).toList();
    }
    // Mobile/desktop: use REST
    final params = {
      'input': input,
      'key': _key,
      if (location != null) 'location': '${location.latitude},${location.longitude}',
      if (location != null) 'radius': '50000',
      'components': 'country:in',
    };
    final uri = Uri.parse('$_base/place/autocomplete/json').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final data = json.decode(res.body);
    final preds = (data['predictions'] as List?) ?? [];
    return preds.map((p) => PlacePrediction(
      description: p['description'] ?? '',
      placeId: p['place_id'] ?? '',
    )).where((p) => p.placeId.isNotEmpty).toList();
  }

  Future<(LatLng?, String?)> placeLatLngAndAddress(String placeId) async {
    if (kIsWeb) {
      try {
        final res = await web.webPlaceDetails(placeId);
        final lat = res['lat'] as num?;
        final lng = res['lng'] as num?;
        final addr = res['address'] as String?;
        final latLng = (lat != null && lng != null) ? LatLng(lat.toDouble(), lng.toDouble()) : null;
        return (latLng, addr);
      } catch (_) {
        return (null, null);
      }
    }
    // Mobile/desktop: use REST
    final params = {
      'place_id': placeId,
      'key': _key,
      'fields': 'geometry,formatted_address,name',
    };
    final uri = Uri.parse('$_base/place/details/json').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode != 200) return (null, null);
    final data = json.decode(res.body);
    final result = data['result'];
    if (result == null) return (null, null);
    final geom = result['geometry'];
    final loc = geom?['location'];
    if (loc == null) return (null, result['formatted_address'] as String?);
    final latLng = LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
    final addr = result['formatted_address'] as String?;
    return (latLng, addr);
  }

  Future<String?> reverseGeocode(double lat, double lng) async {
    if (kIsWeb) {
      try {
        return await web.webReverseGeocode(lat, lng);
      } catch (_) {
        return null;
      }
    }
    // Mobile/desktop: use REST
    final params = {
      'latlng': '$lat,$lng',
      'key': _key,
    };
    final uri = Uri.parse('$_base/geocode/json').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final data = json.decode(res.body);
    final results = (data['results'] as List?) ?? [];
    if (results.isEmpty) return null;
    return results.first['formatted_address'] as String?;
  }
}
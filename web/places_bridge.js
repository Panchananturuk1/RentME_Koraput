// Minimal Google Places bridge to avoid CORS by using the JS library directly on web.
// Exposes Promise-based helpers accessed via Dart JS interop.
window.PlacesBridge = {
  autocomplete: function(input, biasLat, biasLng, radius) {
    return new Promise(function(resolve, reject) {
      try {
        var svc = new google.maps.places.AutocompleteService();
        var opts = {
          input: input,
          componentRestrictions: { country: 'in' }
        };
        if (biasLat != null && biasLng != null) {
          opts.location = new google.maps.LatLng(biasLat, biasLng);
          opts.radius = radius || 50000;
        }
        svc.getPlacePredictions(opts, function(preds, status) {
          if (status !== google.maps.places.PlacesServiceStatus.OK &&
              status !== google.maps.places.PlacesServiceStatus.ZERO_RESULTS) {
            reject(status);
            return;
          }
          var mapped = (preds || []).map(function(p) {
            return { description: p.description || '', placeId: p.place_id || '' };
          });
          resolve(mapped);
        });
      } catch (e) { reject(e); }
    });
  },
  details: function(placeId) {
    return new Promise(function(resolve, reject) {
      try {
        var container = document.createElement('div');
        var svc = new google.maps.places.PlacesService(container);
        svc.getDetails({ placeId: placeId, fields: ['geometry','formatted_address','name'] }, function(res, status) {
          if (status !== google.maps.places.PlacesServiceStatus.OK || !res) {
            reject(status);
            return;
          }
          var loc = res.geometry && res.geometry.location;
          var lat = loc ? loc.lat() : null;
          var lng = loc ? loc.lng() : null;
          var address = res.formatted_address || res.name || '';
          resolve({ lat: lat, lng: lng, address: address });
        });
      } catch (e) { reject(e); }
    });
  },
  // Fallback using Geocoder by placeId, helpful when PlacesService.details fails.
  geocodePlaceId: function(placeId) {
    return new Promise(function(resolve, reject) {
      try {
        var geocoder = new google.maps.Geocoder();
        geocoder.geocode({ placeId: placeId }, function(results, status) {
          if (status !== google.maps.GeocoderStatus.OK || !results || !results.length) {
            reject(status);
            return;
          }
          var r = results[0];
          var loc = r.geometry && r.geometry.location;
          var lat = loc ? loc.lat() : null;
          var lng = loc ? loc.lng() : null;
          var address = r.formatted_address || '';
          resolve({ lat: lat, lng: lng, address: address });
        });
      } catch (e) { reject(e); }
    });
  },
  reverseGeocode: function(lat, lng) {
    return new Promise(function(resolve, reject) {
      try {
        var geocoder = new google.maps.Geocoder();
        geocoder.geocode({ location: { lat: lat, lng: lng } }, function(results, status) {
          if (status !== google.maps.GeocoderStatus.OK || !results || !results.length) {
            reject(status);
            return;
          }
          resolve(results[0].formatted_address);
        });
      } catch (e) { reject(e); }
    });
  }
};
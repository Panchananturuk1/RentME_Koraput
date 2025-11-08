class MapsConfig {
  // Use a dart-define to override at runtime if desired:
  // flutter run --dart-define=MAPS_API_KEY=XXXX
  static const String apiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: 'AIzaSyDj8NpyRM6MepqWdWgOc03mYgIBeC5zZCk',
  );
}
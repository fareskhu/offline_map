import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

LatLngBounds calculateBounds(List<LatLng> points) {
  double north = -double.infinity;
  double south = double.infinity;
  double east = -double.infinity;
  double west = double.infinity;

  for (LatLng point in points) {
    if (point.latitude > north) north = point.latitude;
    if (point.latitude < south) south = point.latitude;
    if (point.longitude > east) east = point.longitude;
    if (point.longitude < west) west = point.longitude;
  }

  return LatLngBounds(
    LatLng(south, west),
    LatLng(north, east),
  );
}

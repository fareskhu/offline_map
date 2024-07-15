import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'calculate_bounds_mapbox.dart';

void updateCameraBounds(MapController controller, List<LatLng> polygonPoints) {
  var bounds = calculateBounds(polygonPoints);

  controller.fitCamera(CameraFit.bounds(bounds: bounds));
}

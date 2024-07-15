import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

Future<void> centerAndZoomIn(
    latlng.LatLng position, MapController controller) async {
  final double currentZoom = controller.camera.zoom;
  final double newZoom = currentZoom + 2; // Adjust the zoom increment as needed
  controller.move(position, newZoom);
}

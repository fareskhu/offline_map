import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

Future<void> zoomIntoCluster(
    latlng.LatLng clusterCenter, MapController controller) async {
  final double currentZoom = controller.camera.zoom;
  final double newZoom = currentZoom + 2; // Increase zoom level by 2
  controller.move(clusterCenter, newZoom);
}

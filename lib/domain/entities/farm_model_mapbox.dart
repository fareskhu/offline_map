import 'package:latlong2/latlong.dart';

class FarmModel {
  final String uid;
  final String name;
  final List<LatLng> locations;

  FarmModel({
    required this.uid,
    required this.name,
    required this.locations,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'locations': locations
          .map((latLng) =>
              {'latitude': latLng.latitude, 'longitude': latLng.longitude})
          .toList(),
    };
  }

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    var locationsList = json['locations'] as List;
    List<LatLng> locations = locationsList.map((location) {
      return LatLng(location['latitude'], location['longitude']);
    }).toList();
    return FarmModel(
      uid: json['uid'],
      name: json['name'],
      locations: locations,
    );
  }

  factory FarmModel.fromDatabase(Map<String, dynamic> dbJson) {
    List<LatLng> locations =
        (dbJson['locations'] as String).split(';').map((location) {
      final latLng = location.split(',');
      return LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
    }).toList();
    return FarmModel(
      uid: dbJson['uid'],
      name: dbJson['name'],
      locations: locations,
    );
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      'uid': uid,
      'name': name,
      'locations': locations
          .map((latLng) => '${latLng.latitude},${latLng.longitude}')
          .join(';'),
    };
  }
}

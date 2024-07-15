import 'package:latlong2/latlong.dart';

class TreeModel {
  final String uid;
  final String label;
  final LatLng location;

  TreeModel({
    required this.uid,
    required this.label,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'label': label,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    };
  }

  factory TreeModel.fromJson(Map<String, dynamic> json) {
    return TreeModel(
      uid: json['uid'],
      label: json['label'],
      location: LatLng(
        json['location']['latitude'],
        json['location']['longitude'],
      ),
    );
  }

  factory TreeModel.fromDatabase(Map<String, dynamic> dbJson) {
    return TreeModel(
      uid: dbJson['uid'],
      label: dbJson['label'],
      location: LatLng(dbJson['latitude'], dbJson['longitude']),
    );
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      'uid': uid,
      'label': label,
      'latitude': location.latitude,
      'longitude': location.longitude,
    };
  }
}

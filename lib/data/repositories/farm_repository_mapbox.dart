import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:palmear_application/domain/entities/farm_model_mapbox.dart';

class FarmRepository {
  final FirebaseFirestore firestore;
  final String userId;

  FarmRepository({FirebaseFirestore? firestore, required this.userId})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addFarm(FarmModel farm) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .doc(farm.uid)
        .set(farm.toJson());
  }

  Future<List<FarmModel>> getFarms() async {
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .get();
    return querySnapshot.docs
        .map((doc) => FarmModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<FarmModel>> getFarmsStream() {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FarmModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> updateFarmGeopoints(
      String farmId, List<LatLng> newLocations) async {
    List<GeoPoint> newGeopoints = newLocations
        .map((latLng) => GeoPoint(latLng.latitude, latLng.longitude))
        .toList();
    await firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .doc(farmId)
        .update({'locations': newGeopoints});
  }
}

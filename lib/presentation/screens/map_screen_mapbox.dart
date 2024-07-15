import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:palmear_application/data/services/firestore_services/database_helper.dart';
import 'package:palmear_application/data/services/user_services/user_session_mapbox.dart';
import 'package:palmear_application/domain/entities/farm_model_mapbox.dart';
import 'package:palmear_application/domain/entities/tree_model_mapbox.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/calculate_centroid_mapbox.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/pie_chart_marker_bitmap_mapbox.dart';
import 'package:palmear_application/domain/use_cases/map_screen_use_cases/marker_bitmap_mapbox.dart';

class MapScreenMapbox extends StatefulWidget {
  const MapScreenMapbox({super.key});

  @override
  State<MapScreenMapbox> createState() => _MapScreenMapboxState();
}

class _MapScreenMapboxState extends State<MapScreenMapbox>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimatedMapController _animatedMapController;
  bool isLoading = true;
  List<Marker> _markers = [];
  final List<Polygon> _polygons = [];
  List<latlng.LatLng> _polygonPoints = [];
  final Map<String, TreeModel> _treeModelsById = {};

  @override
  void initState() {
    super.initState();
    _animatedMapController =
        AnimatedMapController(vsync: this, mapController: _mapController);
    _initializeUserSession();
  }

  Future<void> _initializeUserSession() async {
    await UserSession().loadUserFromPrefs();
    var sessionUser = UserSession().getUser();
    if (sessionUser != null) {
      await _setFarmLocations(sessionUser.uid);
    } else {
      _setLoading(false);
    }
  }

  Future<void> _setFarmLocations(String userId) async {
    final farms = await _getCachedFarms(userId);
    if (farms.isNotEmpty) {
      await _updateFarmData(farms);
    } else {
      _clearData();
    }
  }

  Future<void> _updateFarmData(List<FarmModel> farms) async {
    List<latlng.LatLng> updatedPolygonPoints = [];
    List<TreeModel> updatedTreesList = [];

    for (var farm in farms) {
      updatedPolygonPoints.addAll(farm.locations);
      updatedTreesList.addAll(await _getCachedTrees(farm.uid));
    }

    _updateMarkers(updatedTreesList);

    setState(() {
      _polygonPoints = updatedPolygonPoints;
      _polygons.clear();
      _polygons.add(Polygon(
        points: _polygonPoints,
        color: const Color(0xFF00916E).withOpacity(0.50),
        borderStrokeWidth: 2,
        borderColor: Colors.black,
        isFilled: true,
      ));
      isLoading = false;
    });
  }

  void _clearData() {
    setState(() {
      _polygonPoints.clear();
      _markers.clear();
      isLoading = false;
    });
  }

  Future<List<FarmModel>> _getCachedFarms(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final maps =
        await db.query('farms', where: 'user_id = ?', whereArgs: [userId]);
    return maps.map((map) => FarmModel.fromDatabase(map)).toList();
  }

  Future<List<TreeModel>> _getCachedTrees(String farmId) async {
    final db = await DatabaseHelper.instance.database;
    final maps =
        await db.query('trees', where: 'farm_id = ?', whereArgs: [farmId]);
    return maps.map((map) => TreeModel.fromDatabase(map)).toList();
  }

  void _updateMarkers(List<TreeModel> trees) async {
    final markerWidgets = await Future.wait(trees.map((tree) {
      return getMarkerBitmap(30,
          color: tree.label == "Infested" ? Colors.red : Colors.green);
    }).toList());

    setState(() {
      _markers = trees.asMap().entries.map((entry) {
        final tree = entry.value;
        _treeModelsById[tree.uid] = tree;
        return Marker(
          width: 30.0,
          height: 30.0,
          point: latlng.LatLng(tree.location.latitude, tree.location.longitude),
          child: markerWidgets[entry.key],
          key: ValueKey(tree.uid),
        );
      }).toList();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _polygonPoints.isNotEmpty
                        ? calculateCentroid(_polygonPoints)
                        : const latlng.LatLng(
                            31.99514837693595, 35.879547964711016),
                    initialZoom: 6,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://api.mapbox.com/styles/v1/zeidsinokrot/clybgqhfk00e301pf8q7ydxii/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiemVpZHNpbm9rcm90IiwiYSI6ImNsZzVxZXlrbzA2MGMzZXFpazViaHdyenAifQ.Pi3rh-sl9mNNVdw_78LDEQ",
                      additionalOptions: const {
                        'accessToken':
                            'pk.eyJ1IjoiemVpZHNpbm9rcm90IiwiYSI6ImNsZzVxZXlrbzA2MGMzZXFpazViaHdyenAifQ.Pi3rh-sl9mNNVdw_78LDEQ',
                        'id': 'mapbox.satellite',
                      },
                    ),
                    PolygonLayer(polygons: _polygons),
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 120,
                        size: const Size(40, 40),
                        markers: _markers,
                        polygonOptions: const PolygonOptions(
                          borderColor: Colors.blueAccent,
                          color: Colors.black12,
                          borderStrokeWidth: 3,
                        ),
                        builder: (context, clusterMarkers) =>
                            _buildClusterMarkers(clusterMarkers),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 50,
                  right: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () => _animatedMapController.animateTo(
                          dest: _mapController.camera.center,
                          zoom: _mapController.camera.zoom + 1,
                        ),
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: () => _animatedMapController.animateTo(
                          dest: _mapController.camera.center,
                          zoom: _mapController.camera.zoom - 1,
                        ),
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildClusterMarkers(List<Marker> clusterMarkers) {
    if (clusterMarkers.isEmpty) {
      return const SizedBox.shrink();
    }
    if (clusterMarkers.length == 1) {
      final marker = clusterMarkers.first;
      final tree = _treeModelsById[(marker.key as ValueKey).value]!;
      final markerColor = tree.label == "Healthy" ? Colors.green : Colors.red;
      return FutureBuilder<Widget>(
        future: getMarkerBitmap(30, color: markerColor),
        builder: (context, snapshot) =>
            snapshot.data ?? const SizedBox.shrink(),
      );
    }

    int greenCount = 0, redCount = 0;
    for (var marker in clusterMarkers) {
      final tree = _treeModelsById[(marker.key as ValueKey).value]!;
      if (tree.label == "Healthy") {
        greenCount++;
      } else if (tree.label == "Infested") {
        redCount++;
      }
    }

    return FutureBuilder<Widget>(
      future: getPieChartMarkerBitmap(
          100, greenCount, redCount, clusterMarkers.length),
      builder: (context, snapshot) => GestureDetector(
        onTap: () => _animatedMapController.animateTo(
            dest: clusterMarkers.first.point,
            zoom: _mapController.camera.zoom + 1.5),
        child: snapshot.data ?? const SizedBox.shrink(),
      ),
    );
  }

  void _setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }
}

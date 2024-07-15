// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
// import 'package:palmear_application/domain/entities/tree_model_mapbox.dart';
// import 'package:palmear_application/domain/use_cases/map_screen_use_cases/center_and_zoom_in_mapbox.dart';
// import 'package:palmear_application/domain/use_cases/map_screen_use_cases/marker_bitmap_mapbox.dart';
// import 'package:palmear_application/domain/use_cases/map_screen_use_cases/pie_chart_marker_bitmap_mapbox.dart';
// import 'package:palmear_application/domain/use_cases/map_screen_use_cases/zoom_into_cluster_mapbox.dart';

// Future<Widget> Function(MarkerClusterNode) markerBuilder(
//         MapController controller) =>
//     (cluster) async {
//       if (cluster.mapMarkers.isEmpty) {
//         return const SizedBox.shrink();
//       }

//       if (cluster.mapMarkers.length > 1) {
//         int greenCount = 0;
//         int redCount = 0;
//         for (var item in cluster.mapMarkers) {
//           TreeModel tree = item.key as TreeModel;
//           if (tree.label == "Healthy") {
//             greenCount++;
//           } else if (tree.label == "Infested") {
//             redCount++;
//           }
//         }
//         int totalCount = cluster.mapMarkers.length;
//         return GestureDetector(
//           onTap: () => zoomIntoCluster(cluster.bounds.center, controller),
//           child: await getPieChartMarkerBitmap(
//               100, greenCount, redCount, totalCount),
//         );
//       } else {
//         TreeModel tree = cluster.mapMarkers.first.key as TreeModel;
//         Color markerColor = tree.label == "Healthy" ? Colors.green : Colors.red;
//         return GestureDetector(
//           onTap: () => centerAndZoomIn(cluster.bounds.center, controller),
//           child: await getMarkerBitmap(30, color: markerColor),
//         );
//       }
//     };

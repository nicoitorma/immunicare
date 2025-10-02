import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';

class GisMapping extends StatefulWidget {
  const GisMapping({super.key});

  @override
  State<GisMapping> createState() => _GisMappingState();
}

class _GisMappingState extends State<GisMapping> {
  GeoJsonParser? geoJsonParser;
  String? selectedBarangay;
  double? selectedCoverage;

  // Center of Caramoran, Catanduanes (approximate)
  final LatLng caramoranCenter = const LatLng(13.9839, 124.1337);

  @override
  void initState() {
    super.initState();
    // _loadGeoJson();
  }

  // Define a color scheme based on coverage percentage
  Color _getCoverageColor(double coverage) {
    if (coverage >= 90.0) {
      return Colors.green.shade700.withOpacity(
        0.7,
      ); // High Coverage (Target met)
    } else if (coverage >= 75.0) {
      return Colors.yellow.shade700.withOpacity(0.7); // Medium Coverage
    } else {
      return Colors.red.shade700.withOpacity(
        0.7,
      ); // Low Coverage (Needs attention)
    }
  }

  // // Custom styling function for the GeoJSON Polygons
  // PolygonOptions _polygonStyle(GeoJsonProperties properties) {
  //   final coverage =
  //       properties.containsKey('coverage')
  //           ? properties['coverage'] as double
  //           : 0.0;

  //   return PolygonStyle(
  //     color: _getCoverageColor(coverage),
  //     strokeWidth: 1.5,
  //     borderColor: Colors.black,
  //   );
  // }

  // Future<void> _loadGeoJson() async {
  //   try {
  //     // 1. Load the dummy GeoJSON file from assets
  //     final geoJsonString = await rootBundle.loadString(
  //       'assets/caramoran_barangays.geojson',
  //     );

  //     // 2. Parse the GeoJSON
  //     final parser = GeoJsonParser(
  //       data: geoJsonString,
  //       polygonStyle: _polygonStyle, // Apply custom coloring
  //       // Set up the onTap callback to handle user interaction
  //       onTap: (properties, geometryType, latLng) {
  //         if (properties != null && properties.containsKey('name')) {
  //           setState(() {
  //             selectedBarangay = properties['name'] as String;
  //             selectedCoverage = properties['coverage'] as double;
  //           });
  //         }
  //       },
  //     );

  //     setState(() {
  //       geoJsonParser = parser;
  //     });
  //   } catch (e) {
  //     print('Error loading GeoJSON: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until the GeoJSON is parsed
    if (geoJsonParser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caramoran, Catanduanes 👶 Vax Coverage'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: caramoranCenter, initialZoom: 11.5),
        children: [
          // Background map tiles (OpenStreetMap is a good free option)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),

          // GeoJSON Layer: This displays the colored barangay polygons
          PolygonLayer(polygons: geoJsonParser!.polygons),

          // Display selected barangay info
          if (selectedBarangay != null)
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'Barangay: $selectedBarangay\nCoverage: ${selectedCoverage!.toStringAsFixed(1)}%',
                  // Add a custom style for better visibility
                  // In a real app, use a Card/Dialog for this.
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.blueGrey.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_test/api_calls.dart';

class GoogleMapsPage extends StatefulWidget {
  GoogleMapsPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GoogleMapsPageState createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  GoogleMapController controller;

  Set<Polygon> allBuildings = {};
  Set<Polygon> visibleBuildings = {};
  Set<Polygon> allLots = {};
  Set<Polygon> visibleLots = {};

  DateTime lastUpdateTime;

  @override
  void initState() {
    super.initState();
    loadBuildings();
    loadParking();
  }

  void loadBuildings() async {
    final dynamic buildingsJson = await getBuildings();

    final newPolygons = Set<Polygon>();

    final List<dynamic> buildings = buildingsJson["features"]
        .where((dynamic it) => it["type"] == "Feature")
        .toList() as List<dynamic>;

    buildings.forEach((dynamic building) {
      final bldgName = building["properties"]["BldgName"] as String;
      final bldgNum = building["properties"]["BldgNum"] as int;
      final centerLat = building["properties"]["Latitude"] as double;
      final centerLng = building["properties"]["Longitude"] as double;
      final buildingParts = <List<LatLng>>[];

      if (building["geometry"]["type"] == "MultiPolygon") {
        building["geometry"]["coordinates"].forEach((dynamic polygon) {
          // Fun fact: if I declare 'points' as a List, this code will throw an exception.
          // But casting it is okay for some reason.
          polygon.forEach((dynamic points) {
            buildingParts.add((points as List)
                .map<LatLng>(
                    (dynamic it) => LatLng(it[1] as double, it[0] as double))
                .toList());
          });
        });
      } else {
        building["geometry"]["coordinates"].forEach((dynamic points) {
          final latLngPoints = points
              .map<LatLng>(
                  (dynamic it) => LatLng(it[1] as double, it[0] as double))
              .toList() as List<LatLng>;
          buildingParts.add(latLngPoints);
        });
      }

      buildingParts.forEach((latLngs) {
        newPolygons.add(Polygon(
          strokeWidth: 5,
//          fillColor: Colors.transparent,
//          strokeColor: Colors.transparent,
          consumeTapEvents: true,
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(title: Text(bldgName)),
            );
          },
          polygonId: PolygonId(bldgNum.toString()),
          points: latLngs,
        ));
      });
    });

    setState(() {
      allBuildings = newPolygons;
      visibleBuildings = newPolygons;
    });
  }

  void loadParking() async {
    final dynamic parkingJson = await getParking();

    final newPolygons = Set<Polygon>();

    final List<dynamic> parkingLots = parkingJson["features"]
        .where((dynamic it) => it["type"] == "Feature")
        .toList() as List<dynamic>;

    parkingLots.forEach((dynamic parkingLot) {
      final lotName = parkingLot["properties"]["Lot_Name"] as String;
      final lotID = int.parse(parkingLot["properties"]["Parking_ID"] as String);
      final centerLat = parkingLot["properties"]["Latitude"] as double;
      final centerLng = parkingLot["properties"]["Longitude"] as double;
      final lotParts = <List<LatLng>>[];

      if (parkingLot["geometry"]["type"] == "MultiPolygon") {
        parkingLot["geometry"]["coordinates"].forEach((dynamic polygon) {
          // Fun fact: if I declare 'points' as a List, this code will throw an exception.
          // But casting it is okay for some reason.
          polygon.forEach((dynamic points) {
            lotParts.add((points as List)
                .map<LatLng>(
                    (dynamic it) => LatLng(it[1] as double, it[0] as double))
                .toList());
          });
        });
      } else {
        parkingLot["geometry"]["coordinates"].forEach((dynamic points) {
          final latLngPoints = points
              .map<LatLng>(
                  (dynamic it) => LatLng(it[1] as double, it[0] as double))
              .toList() as List<LatLng>;
          lotParts.add(latLngPoints);
        });
      }

      lotParts.forEach((latLngs) {
        newPolygons.add(Polygon(
          strokeWidth: 5,
          fillColor: Color(0x889E9E9E),
          strokeColor: Color(0x889E9E9E),
          consumeTapEvents: true,
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(title: Text(lotName)),
            );
          },
          polygonId: PolygonId(lotID.toString()),
          points: latLngs,
        ));
      });
    });

    setState(() {
      allLots = newPolygons;
      visibleLots = newPolygons;
    });
  }

  @override
  Widget build(BuildContext context) {
    lastUpdateTime = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text("Rutgers Map Stuff"),
      ),
      body: Center(
        child: GoogleMap(
//          mapType: MapType.satellite,
          buildingsEnabled: false,
          myLocationEnabled: true,
          onMapCreated: (controller) => this.controller = controller,
          onCameraMove: (cameraPosition) async {
            final now = DateTime.now();
            if (now.difference(lastUpdateTime).inMilliseconds > 250) {
              print("${now.second}: updating polygons!");
              lastUpdateTime = now;
              final bounds = await controller?.getVisibleRegion();
              final visibleBuildings = allBuildings.where((polygon) {
                return polygon.points.any((point) => bounds.contains(point));
              }).toSet();
              final visibleLots = allLots.where((polygon) {
                return polygon.points.any((point) => bounds.contains(point));
              }).toSet();
              setState(() {
                this.visibleBuildings = visibleBuildings;
                this.visibleLots = visibleLots;
              });
            }
          },
          polygons: visibleBuildings.union(visibleLots),
          minMaxZoomPreference: MinMaxZoomPreference(10, 20),
          cameraTargetBounds: CameraTargetBounds(
            LatLngBounds(
              southwest: LatLng(39.844001, -75.314648),
              northeast: LatLng(40.837580, -73.963602),
            ),
          ),
          initialCameraPosition: CameraPosition(
            target: LatLng(40.5218723486, -74.4624206535),
            zoom: 15,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:knight_transporter_flutter/api_calls.dart';

class GoogleMapsPage extends StatefulWidget {
  GoogleMapsPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GoogleMapsPageState createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  GoogleMapController controller;

  Set<Polygon> allPolygons = {};
  Set<Polygon> visiblePolygons = {};

  DateTime lastUpdateTime;

  @override
  void initState() {
    super.initState();
    loadWalkways();
    loadBuildings();
    loadParkingLots();
  }

  void loadWalkways() async {
    final dynamic walkwaysJson = await getWalkways();

    final newPolygons = Set<Polygon>();

    final walkways = walkwaysJson["features"]
        .where((dynamic it) => it["type"] == "Feature")
        .toList() as List<dynamic>;

    int walkwayPolygonId = 1; // this needs to be unique

    walkways.forEach((dynamic walkway) {
      final walkwayParts = <List<LatLng>>[];

      // TODO: Are all the walkways MultiPolygons?
      if (walkway["geometry"]["type"] == "MultiPolygon") {
        walkway["geometry"]["coordinates"].forEach((dynamic polygon) {
          polygon.forEach((dynamic points) {
            walkwayParts.add((points as List)
                .map<LatLng>(
                    (dynamic it) => LatLng(it[1] as double, it[0] as double))
                .toList());
          });
        });
      } else {
        walkway["geometry"]["coordinates"].forEach((dynamic points) {
          final latLngPoints = points
              .map<LatLng>(
                  (dynamic it) => LatLng(it[1] as double, it[0] as double))
              .toList() as List<LatLng>;
          walkwayParts.add(latLngPoints);
        });
      }

      walkwayParts.forEach((latLngs) {
        newPolygons.add(Polygon(
          strokeColor: Colors.transparent,
          fillColor: Color(0x88964b00),
          polygonId: PolygonId("walkway $walkwayPolygonId"),
          points: latLngs,
          zIndex: 0,
        ));
        walkwayPolygonId++;
      });
    });

    setState(() {
      allPolygons.addAll(newPolygons);
      visiblePolygons.addAll(newPolygons);
    });
  }

  void loadBuildings() async {
    final dynamic buildingsJson = await getBuildings();

    final newPolygons = Set<Polygon>();

    final buildings = buildingsJson["features"]
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
          strokeColor: Colors.transparent,
//          fillColor: Colors.transparent,
          consumeTapEvents: true,
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(title: Text(bldgName)),
            );
          },
          polygonId: PolygonId("building $bldgNum"),
          points: latLngs,
          zIndex: 1,
        ));
      });
    });

    setState(() {
      allPolygons.addAll(newPolygons);
      visiblePolygons.addAll(newPolygons);
    });
  }

  void loadParkingLots() async {
    final dynamic parkingJson = await getParkingLots();

    final newPolygons = Set<Polygon>();

    final parkingLots = parkingJson["features"]
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
          strokeColor: Colors.transparent,
          fillColor: Color(0x889E9E9E),
          consumeTapEvents: true,
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(title: Text(lotName)),
            );
          },
          polygonId: PolygonId("parking lot $lotID"),
          points: latLngs,
          zIndex: 2,
        ));
      });
    });

    setState(() {
      allPolygons.addAll(newPolygons);
      visiblePolygons.addAll(newPolygons);
    });
  }

  @override
  Widget build(BuildContext context) {
    lastUpdateTime = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter + Google Maps"),
      ),
      body: Center(
        child: GoogleMap(
//          mapType: MapType.satellite,
          buildingsEnabled: false,
          myLocationEnabled: true,
          onMapCreated: (controller) {
            this.controller = controller;
            // I can't hide the green pedestrian paths without also hiding roads
            controller.setMapStyle('[{"featureType": "landscape.man_made","stylers": [{"visibility": "off"}]},{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
          },
          onCameraMove: (cameraPosition) async {
//            print("Printing ${visiblePolygons.length} polygons");
            final now = DateTime.now();
            if (now.difference(lastUpdateTime).inMilliseconds > 250) {
//              print("${now.second}: updating polygons!");
              lastUpdateTime = now;
              final bounds = await controller?.getVisibleRegion();
              final visiblePolygons = allPolygons.where((polygon) {
                return polygon.points.any((point) => bounds.contains(point));
              }).toSet();
              setState(() => this.visiblePolygons = visiblePolygons);
            }
          },
          polygons: visiblePolygons,
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

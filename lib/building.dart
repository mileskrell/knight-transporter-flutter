import 'package:google_maps_flutter/google_maps_flutter.dart';

class Building {
  String bldgName;
  int bldgNum;
  double lat;
  double lon;
  List<LatLng> polygon;

  Building({this.bldgName, this.bldgNum, this.lat, this.lon, this.polygon});
}

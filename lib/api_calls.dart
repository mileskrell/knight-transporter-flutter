import 'dart:convert';

import 'package:http/http.dart' as http;

const xMin = "-75.314648";
const yMin = "39.844001";
const xMax = "-73.963602";
const yMax = "40.837580";
const commonParams = "f=geojson&geometry=%7B%22xmin%22%3A+$xMin%2C+%22ymin%22%3A+$yMin%2C+%22xmax%22%3A+$xMax%2C+%22ymax%22%3A+$yMax%7D&inSR=4326&outSR=4326&geometryType=esriGeometryEnvelope&spatialRel=esriSpatialRelIntersects&returnDistinctValues=true";

const baseUrl = "https://services1.arcgis.com/ze0XBzU1FXj94DJq/arcgis/rest/services/";

const walkwaysUrl = baseUrl + "Rutgers_University_Walkways/FeatureServer/0/query?$commonParams&outFields="; // outFields=Site_ID%2CDistrict or whatever we want to use
const buildingsUrl = baseUrl + "Rutgers_University_Buildings/FeatureServer/0/query?$commonParams&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=BldgName%2C+BldgNum%2C+Latitude%2C+Longitude&returnGeometry=true&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&cacheHint=false&returnZ=false&returnM=false&returnExceededLimitFeatures=true&sqlFormat=none";
const parkingLotsUrl = baseUrl + "Rutgers_University_Parking/FeatureServer/0/query?$commonParams&outFields=Parking_ID%2C%20Lot_Name%2C%20Latitude%2C%20Longitude&where=1%3D1";

Future<dynamic> getWalkways() async {
  final response = await http.get(walkwaysUrl);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw "Getting buildings returned response code ${response.statusCode}";
  }
}

Future<dynamic> getBuildings() async {
  final response = await http.get(buildingsUrl);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw "Getting buildings returned response code ${response.statusCode}";
  }
}

Future<dynamic> getParkingLots() async {
  final response = await http.get(parkingLotsUrl);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw "Getting parking returned response code ${response.statusCode}";
  }
}

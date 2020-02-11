import 'dart:convert';

import 'package:http/http.dart' as http;

const xMin = "-75.314648";
const yMin = "39.844001";
const xMax = "-73.963602";
const yMax = "40.837580";

Future<dynamic> getBuildings() async {
  final url = "https://services1.arcgis.com/ze0XBzU1FXj94DJq/arcgis/rest/services/Rutgers_University_Buildings/FeatureServer/0/query?geometry={%22xmin%22%3A+$xMin%2C+%22ymin%22%3A+$yMin%2C+%22xmax%22%3A+$xMax%2C+%22ymax%22%3A+$yMax}&geometryType=esriGeometryEnvelope&inSR=4326&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=BldgName%2C+BldgNum%2C+Latitude%2C+Longitude&returnGeometry=true&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&outSR=4326&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=true&cacheHint=false&returnZ=false&returnM=false&returnExceededLimitFeatures=true&sqlFormat=none&f=geojson";
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw "Getting buildings returned response code ${response.statusCode}";
  }
}

Future<dynamic> getParking() async {
  final url = "https://services1.arcgis.com/ze0XBzU1FXj94DJq/arcgis/rest/services/Rutgers_University_Parking/FeatureServer/0/query?f=geojson&outFields=Parking_ID%2C%20Lot_Name%2C%20Latitude%2C%20Longitude&outSR=4326&returnDistinctValues=true&where=1%3D1&geometryType=esriGeometryEnvelope&inSR=4326&spatialRel=esriSpatialRelIntersects&geometry=%7B%22xmin%22%3A+$xMin%2C+%22ymin%22%3A+$yMin%2C+%22xmax%22%3A+$xMax%2C+%22ymax%22%3A+$yMax%7D";
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw "Getting parking returned response code ${response.statusCode}";
  }
}

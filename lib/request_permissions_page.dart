import 'package:flutter/material.dart';
import 'package:google_maps_test/google_maps_page.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPermissionsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RequestPermissionsPageState();
}

class RequestPermissionsPageState extends State<RequestPermissionsPage> {
  PermissionStatus grantStatus;

  void openMapPage() {
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute(builder: (context) => GoogleMapsPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    () async {
      final grantStatus = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.location);
      if (grantStatus == PermissionStatus.granted) {
        openMapPage();
      } else {
        setState(() => this.grantStatus = grantStatus);
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Maps Flutter")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () async {
                final result = await PermissionHandler()
                    .requestPermissions([PermissionGroup.location]);

                if (result[PermissionGroup.location] ==
                    PermissionStatus.granted) {
                  openMapPage();
                } else {
                  setState(
                      () => grantStatus = result[PermissionGroup.location]);
                }
              },
              child: Text("Grant permissions to continue"),
            ),
            if (grantStatus != null)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text("Current status: $grantStatus"),
              ),
          ],
        ),
      ),
    );
  }
}

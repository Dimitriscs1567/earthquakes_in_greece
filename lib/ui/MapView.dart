import 'dart:async';
import 'package:eartquakes_in_greece/models/Data.dart';
import 'package:eartquakes_in_greece/models/Earthquake.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  final int one;

  MapView([this.one]);

  @override
  _MapViewState createState() => _MapViewState(this.one);
}

class _MapViewState extends State<MapView> {
  final int _one;
  Set<Marker> markers = Set<Marker>();
  Completer<GoogleMapController> _controller = Completer();
  static CameraPosition _kGooglePlex;

  _MapViewState(this._one);

  @override
  void initState() {
    int numberOfPoints;
    if(_one != null)
      numberOfPoints = 1;
    else if(Data.earthquakes.length > Data.NUMBER_OF_POINTS_IN_MAP)
      numberOfPoints = Data.NUMBER_OF_POINTS_IN_MAP;
    else
      numberOfPoints = Data.earthquakes.length;

    if(numberOfPoints > 1) {
      for (int i = 0; i < numberOfPoints; i++) {
        Earthquake earthquake = Data.earthquakes[i];
        double color;
        if (earthquake.magnitude < 3.0)
          color = BitmapDescriptor.hueGreen;
        else if (earthquake.magnitude < 4.5)
          color = BitmapDescriptor.hueYellow;
        else
          color = BitmapDescriptor.hueRed;

        markers.add(Marker(
          markerId: MarkerId(earthquake.id),
          position: LatLng(earthquake.latitude, earthquake.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(color),
          infoWindow: InfoWindow(
            title: "Magnitude: ${earthquake.magnitude}, Depth: ${earthquake
                .depth}km",
            snippet: "${_getTimeInString(earthquake)} at ${earthquake.time}",
          ),
        ));
      }

      _kGooglePlex = CameraPosition(
        target: LatLng(37.97945, 23.71622),
        zoom: 6.2,
      );
    }
    else{
      Earthquake earthquake = Data.earthquakes[_one];
      double color;
      if (earthquake.magnitude < 3.0)
        color = BitmapDescriptor.hueGreen;
      else if (earthquake.magnitude < 4.5)
        color = BitmapDescriptor.hueYellow;
      else
        color = BitmapDescriptor.hueRed;

      markers.add(Marker(
        markerId: MarkerId(earthquake.id),
        position: LatLng(earthquake.latitude, earthquake.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(color),
        infoWindow: InfoWindow(
          title: "Magnitude: ${earthquake.magnitude}, Depth: ${earthquake
              .depth}km",
          snippet: "${_getTimeInString(earthquake)} at ${earthquake.time}",
        ),
      ));

      _kGooglePlex = CameraPosition(
        target: LatLng(earthquake.latitude, earthquake.longitude),
        zoom: 8.0,
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: markers,
    );
  }

  String _getTimeInString(Earthquake earthquake){
    String day;
    List<String> date = earthquake.date.split("-");
    DateTime earthquakeDateTime = DateTime(int.parse(date[2]),
        int.parse(date[1]), int.parse(date[0]));
    Duration diff = DateTime.now().difference(earthquakeDateTime);

    if(earthquakeDateTime.month - DateTime.now().month == 0) {
      if (diff.inDays == 0)
        day = "Today";
      else if (diff.inDays == 1)
        day = "Yesterday";
      else
        day = diff.inDays.toString() + " days ago";
    }
    else{
      day = earthquake.date;
    }

    return day;
  }
}

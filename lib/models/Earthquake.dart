import 'dart:core';
import 'City.dart';
import 'Data.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Earthquake {
  String _id;
  String _date;
  String _time;
  double _latitude;
  double _longitude;
  double _depth;
  double _magnitude;
  String _location;

  Earthquake(this._date, this._time, this._latitude, this._longitude,
      this._depth, this._magnitude) {
    _id = "$_latitude$longitude$_magnitude";

    List<String> date = _date.split("/");
    List<String> time = _time.split(":");
    DateTime greekTime = DateTime(int.parse(date[2]), int.parse(date[1]),
      int.parse(date[0]), int.parse(time[0]), int.parse(time[1]));
    greekTime = greekTime.add(Duration(hours: 3));

    List<String> dateTime = greekTime.toString().split(" ");
    date = dateTime[0].split("-");
    _date = "${date[2]}-${date[1]}-${date[0]}";
    time = dateTime[1].split(":");
    _time = "${time[0]}:${time[1]}";

    _createLocation();
  }

  void _createLocation() async {
    City finalCity;
    LatLng finalCityLocation;
    double distance = -1;
    LatLng earthquakeLocation =  LatLng(_latitude, _longitude);

    for(City city in Data.cities){
      LatLng cityLocation =  LatLng(city.latitude, city.longitude);
      double tempDistance = distanceBetween(cityLocation, earthquakeLocation);
      if(tempDistance < distance || distance == -1){
        distance = tempDistance;
        finalCity = city;
        finalCityLocation = cityLocation;
      }
    }


    double bearing = calculateBearing(finalCityLocation, earthquakeLocation);
    String bearingString;
    if(bearing >= -22.5 && bearing <= 22.5)
    bearingString = "N";
    else if(bearing >= 22.5 && bearing <= 67.5)
    bearingString = "NE";
    else if(bearing >= 67.5 && bearing <= 112.5)
    bearingString = "E";
    else if(bearing >= 112.5 && bearing <= 157.5)
    bearingString = "SE";
    else if(bearing >= 157.5 || bearing <= -157.5)
    bearingString = "S";
    else if(bearing >= -157.5 && bearing <= -112.5)
    bearingString = "SW";
    else if(bearing >= -112.5 && bearing <= -67.5)
    bearingString = "W";
    else
    bearingString = "NW";

    _location = (distance~/1000).toString() + "km $bearingString of ${finalCity.name}";
  }

  double distanceBetween(LatLng A, LatLng B){
    final double R = 6371000.0;
    final double toRadians = 0.0174533;

    double f1 = A.latitude*toRadians;
    double f2 = B.latitude*toRadians;
    double df = (B.latitude - A.latitude)*toRadians;
    double dl = (B.longitude - A.longitude)*toRadians;

    double a = sin(df/2.0) * sin(df/2.0) + cos(f1) * cos(f2) * sin(dl/2.0) * sin(dl/2.0);
    double c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a));

    return R*c;
  }

  double calculateBearing(LatLng A, LatLng B){
    final double toRadians = 0.0174533;

    double X = cos(B.latitude*toRadians) * sin(B.longitude*toRadians - A.longitude*toRadians);
    double Y = (cos(A.latitude*toRadians) * sin(B.latitude*toRadians)) -
        (sin(A.latitude*toRadians) * cos(B.latitude*toRadians)* cos(B.longitude*toRadians - A.longitude*toRadians));

    double b = atan2(X, Y);
    return b/toRadians;
  }

  String get id => this._id;

  String get date => this._date;

  String get time => this._time;

  double get latitude => this._latitude;

  double get longitude => this._longitude;

  double get depth => this._depth;

  double get magnitude => this._magnitude;

  String get location => this._location;
}
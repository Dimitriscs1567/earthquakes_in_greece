import 'dart:core';

class City {
  String _name;
  double _latitude;
  double _longitude;

  City(this._name, this._latitude, this._longitude);

  String get name => this._name;

  double get latitude => this._latitude;

  double get longitude => this._longitude;
}
import 'package:eartquakes_in_greece/models/Data.dart';
import 'package:eartquakes_in_greece/models/Earthquake.dart';
import 'package:flutter/material.dart';

class EarthquakeWidget extends StatelessWidget {
  int index;
  Function onTap;
  EarthquakeWidget(this.index, {@required this.onTap});

  @override
  Widget build(BuildContext context) {
    Earthquake earthquake = Data.earthquakes[index];

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

    double magnitude = earthquake.magnitude;
    Color magnitudeColor;
    if(magnitude < 3.0)
      magnitudeColor = Colors.green;
    else if(magnitude < 4.5)
      magnitudeColor = Colors.yellow;
    else
      magnitudeColor = Colors.red;

    return Card(
      margin: new EdgeInsets.all(8.0),
      color: Colors.grey[500],
      elevation: 5.0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: new EdgeInsets.all(5.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height/ 10.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: magnitudeColor,
                  ),
                  child: Text(magnitude.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 26.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: <Widget>[
                    Text(day + " at " + earthquake.time,
                      style: TextStyle(color: Colors.black, fontSize: 21.0),
                      textAlign: TextAlign.center,
                    ),
                    Padding(padding: new EdgeInsets.all(3.0)),
                    Text(earthquake.location,
                      style: TextStyle(color: Colors.black, fontSize: 21.0),
                      textAlign: TextAlign.center,
                    ),
                    Padding(padding: new EdgeInsets.all(3.0)),
                    Text("Depth: " + earthquake.depth.toString() + "km",
                      style: TextStyle(color: Colors.black, fontSize: 21.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}

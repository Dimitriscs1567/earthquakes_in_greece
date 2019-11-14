import 'package:eartquakes_in_greece/models/Data.dart';
import 'package:eartquakes_in_greece/models/Earthquake.dart';
import 'package:http/http.dart' as http;

class EarthquakesProvider{
  static List<String> _earthquakesInString;
  static int _readLine = 0;

  static Future readEarthquakes(int number, int days) async {
    _readLine = 0;
    _earthquakesInString = null;
    Data.earthquakes.clear();
    var response;

    if(days < 100) {
      response = await http.get(
          "http://www.geophysics.geol.uoa.gr/stations/maps/recent_eq_${days}d_el.htm");
      if (response.statusCode == 200) {
        _earthquakesInString = _fixEarthquakeLines(response.body);
        readMoreEarthquakes(number, false);
      }
    }
    else{
      response = await http.get(
          "http://www.geophysics.geol.uoa.gr/stations/gmaps3/event_output2j.php?type=cat");
      if (response.statusCode == 200) {
        _earthquakesInString = response.body.split("\n");
        _earthquakesInString.removeLast();
        _earthquakesInString.removeAt(0);
        readMoreEarthquakes(number, true);
      }
    }
  }

  static Future readEarthquakesFromYear(int number, int year) async {
    _readLine = 0;
    _earthquakesInString = null;
    Data.earthquakes.clear();
    final response = await http.get("http://www.geophysics.geol.uoa.gr/catalog/"
        "source_par_$year.epi");
    if (response.statusCode == 200) {
      _earthquakesInString = response.body.split("\n");
      _earthquakesInString.removeLast();
      _earthquakesInString.removeRange(0, 3);
      readMoreEarthquakes(number, true);
    }
  }

  static void readMoreEarthquakes(int number, bool fromNumberLine){
    if(_readLine + number >= _earthquakesInString.length) {
      for (int i = _readLine; i < _earthquakesInString.length; i++) {
        Earthquake earthquake;
        if(fromNumberLine) {
          earthquake = _createEarthquakeFromNumberLine(_earthquakesInString[i]);
        }
        else{
          earthquake = _createEarthquakeFromString(
            _earthquakesInString[i], i == 0 ? true : false,
          );
        }
        Data.earthquakes.add(earthquake);
      }
    }
    else{
      for (int i = _readLine; i < _readLine + number; i++) {
        Earthquake earthquake;
        if(fromNumberLine) {
          earthquake = _createEarthquakeFromNumberLine(_earthquakesInString[i]);
        }
        else{
          earthquake = _createEarthquakeFromString(
            _earthquakesInString[i], i == 0 ? true : false,
          );
        }
        Data.earthquakes.add(earthquake);
      }
    }

    _readLine += number;
  }

  static Future readNewEarthquakes() async {
    final response = await http.get(
        "http://www.geophysics.geol.uoa.gr/stations/maps/recent_eq_1d_el.htm");

    if(response.statusCode == 200){
      List<String> lines = _fixEarthquakeLines(response.body);
      Earthquake existEarthquake = Data.earthquakes.first;

      List<Earthquake> newEarthquakes = [];
      int index = 0;
      Earthquake earthquake = _createEarthquakeFromString(lines[index], true);
      while(earthquake.id != existEarthquake.id && index < lines.length) {
        newEarthquakes.add(earthquake);
        index++;
        if(index < lines.length)
          earthquake = _createEarthquakeFromString(lines[index], false);
      }
      if(newEarthquakes.isNotEmpty){
        for(int i=newEarthquakes.length - 1; i>=0; i--){
          Data.earthquakes.insert(0, newEarthquakes[i]);
        }
      }
    }
  }

  static Future<List<int>> getSignificantYears() async {
    final String beforeYears = "<span class=\"style31\"><u>";
    final String endYears = "</span>";

    final response = await http.get("http://www.geophysics.geol.uoa.gr/stations/"
        "gmaps3/leaf_significant.php?mapmode=mech&lng=el&year="
        "${DateTime.now().year - 1}");

    if(response.statusCode == 200){
      List<String> lines =  response.body.split("\n");

      int index = 0;
      while(!lines[index].contains(beforeYears)){
        index++;
      }

      lines.removeRange(0, index + 1);
      index = 0;
      while(!lines[index].contains(endYears)){
        index++;
      }
      lines.removeRange(index - 1, lines.length);

      List<int> years = [];
      for(String line in lines){
        List<int> yearsInLine = _getYearsFromString(line);
        for(int year in yearsInLine)
          years.add(year);
      }

      return years;
    }

    return null;
  }

  static Earthquake _createEarthquakeFromString(String line, bool first){
    String depthStart = "ÂÜèïò:</b>";
    String depthEnd = "÷ì";
    String depthString = line.split(depthStart)[1].split(depthEnd)[0];

    List<String> data = line.split("[");
    if(first)
      data = data[2].split(",");
    else
      data = data[1].split(",");

    data[0] = data[0].substring(1, data[0].length);
    List<String> datetime = data[0].split(" ");
    String date = datetime[0] + "/" + DateTime.now().year.toString();
    String time = datetime[1].split(":")[0] + ":" + datetime[1].split(":")[1];

    data[1] = data[1].substring(0, data[1].length - 1);
    double magnitude = double.parse(data[1].split(":")[1]);

    Earthquake earthquake = Earthquake(date, time, double.parse(data[2]), double.parse(data[3]),
        double.parse(depthString), magnitude);

    return earthquake;
  }

  static List<String> _fixEarthquakeLines(String body){
    String earthquakesStop = "];";
    int startIndex = 333;

    List<String> lines = body.split("\n");
    lines.removeRange(0, startIndex);
    String line = lines[0];
    int lastIndex = 0;

    while(!line.contains(earthquakesStop)){
      lastIndex++;
      line = lines[lastIndex];
    }

    lines.removeRange(lastIndex, lines.length);
    lines.removeWhere((line){
      return line.trim().isEmpty;
    });

    return lines;
  }

  static Earthquake _createEarthquakeFromNumberLine(String line){
    List<String> data = line.split(" ");
    data.removeWhere((value){
      return value.trim().isEmpty;
    });

    String date = "${data[2]}/${data[1]}/${data[0]}";
    String time = "${data[3]}:${data[4]}";


    return Earthquake(date, time, double.parse(data[6]), double.parse(data[7]),
        double.parse(data[8]), double.parse(data[9]));
  }

  static List<int> _getYearsFromString(String line){
    List<String> data = line.split("\">");
    if(data.length == 2){
      String year = data[1].split("<")[0];
      return [int.parse(year)];
    }
    else{
      String year1 = data[1].split("<")[0];
      String year2 = data[2].split("<")[0];
      return [int.parse(year1), int.parse(year2)];
    }
  }

  static bool hasMoreEarthquakes(){
    if(_readLine >= _earthquakesInString.length)
      return false;

    return true;
  }
}
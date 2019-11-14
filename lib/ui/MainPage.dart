import 'package:async/async.dart';
import 'package:eartquakes_in_greece/models/Data.dart';
import 'package:eartquakes_in_greece/providers/EartquakesProvider.dart';
import 'package:flutter/material.dart';
import 'EarthquakeWidget.dart';
import 'MapView.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double _savedOffset = 0.0;
  bool _hasLoaded = false;
  AsyncMemoizer _memoizer = AsyncMemoizer();
  AsyncMemoizer _memoizerForYears = AsyncMemoizer();
  int _selectedPage = 0;
  List<bool> _selectedButton = [false, true, false, false, false];
  List<bool> _selectedYear = [];
  int _earthquakeToShow = -1;
  List<int> _significantYears;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Earthquakes in Greece",
            style: TextStyle(fontSize: 25.0),
          ),
        ),
        centerTitle: true,
        bottom: _selectedPage == 0 ? PreferredSize(
          child: Row(
            children: <Widget>[
              Expanded(child: _stateButton("Last 24 hours", 0)),
              Expanded(child: _stateButton("Last 48 hours", 1)),
              Expanded(child: _stateButton("Last 10 days", 2)),
              Expanded(child: _stateButton("Last 20 days", 3)),
              Expanded(child: _stateButton("All 0f ${DateTime.now().year}", 4)),
            ],
          ),
          preferredSize: Size.fromHeight(50),
        ) : null,
      ),
      drawer: _selectedPage == 0 ? Drawer(
        child: FutureBuilder(
          future: _fetchSignificantYearsWithMemorizer(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done)
              return _drawerWidget();
            else
              return Center(child: CircularProgressIndicator(),);
          },
        ),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 5.0,
        selectedFontSize: 15.0,
        unselectedFontSize: 13.0,
        currentIndex: _selectedPage,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              height: _selectedPage==0 ? MediaQuery.of(context).size.height / 22.0
                : MediaQuery.of(context).size.height / 24.0,
              child: Image.asset("icons/earthquake_icon.png",
                color: _selectedPage==0 ? Colors.blue : Colors.black,
              ),
            ),
            title: Text("Eartquakes"),
          ),
          BottomNavigationBarItem(
            icon: Container(
              height: _selectedPage==1 ? MediaQuery.of(context).size.height / 22.0
                  : MediaQuery.of(context).size.height / 24.0,
              child: Image.asset("icons/map_icon.png",
                color: _selectedPage==1 ? Colors.blue : Colors.black,
              ),
            ),
            title: Text("Map"),
          ),
          BottomNavigationBarItem(
            icon: Container(
              height: _selectedPage==2 ? MediaQuery.of(context).size.height / 22.0
                  : MediaQuery.of(context).size.height / 24.0,
              child: Image.asset("icons/options_icon.png",
                color: _selectedPage==2 ? Colors.blue : Colors.black,
              ),
            ),
            title: Text("Options"),
          ),
        ],
        onTap: (selected){
          setState(() {
            _selectedPage = selected;
            if(selected == 0)
              _earthquakeToShow = -1;
          });
        },
      ),
      body: FutureBuilder(
        future: _fetchEarthquakesWithMemorizer(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done)
            return _pageView();
          else
            return Center(child: CircularProgressIndicator(),);
        },
      ),
    );
  }

  Future _fetchSignificantYearsWithMemorizer(){
    return this._memoizerForYears.runOnce(() async {
      _significantYears = await EarthquakesProvider.getSignificantYears();
      _significantYears.forEach((year){
        _selectedYear.add(false);
      });
    });
  }

  Future _fetchEarthquakesWithMemorizer(){
    return this._memoizer.runOnce(() async {
      _hasLoaded = false;
      _savedOffset = 0.0;
      if(_findDaysSelected() > -1)
        await EarthquakesProvider.readEarthquakes(Data.NUMBER_OF_POINTS_IN_MAP,
          _findDaysSelected());
      else
        await EarthquakesProvider.readEarthquakesFromYear(Data.NUMBER_OF_POINTS_IN_MAP,
            _yearSelected());
      setState(() {
        _hasLoaded = true;
      });
    });
  }

  Widget _pageView(){
    switch(_selectedPage){
      case 0:
        if(_findDaysSelected() > -1) {
          return RefreshIndicator(
            child: _earthquakesList(),
            onRefresh: _fetchNewEarthquakes,
          );
        }
        else{
          return _earthquakesList();
        }
        break;
      case 1: return _earthquakeToShow > -1 ? MapView(_earthquakeToShow) :
        MapView();
      case 2: return Container();
      default: return null;
    }
  }

  Future _fetchNewEarthquakes() async {
    await EarthquakesProvider.readNewEarthquakes();
  }

  void _fetchMoreEarthquakes() {
    if(_selectedButton.last || _yearSelected() > -1)
      EarthquakesProvider.readMoreEarthquakes(20, true);
    else
      EarthquakesProvider.readMoreEarthquakes(20, false);
  }

  Widget _earthquakesList(){
    final earthquakesScrollController = ScrollController(initialScrollOffset: _savedOffset);

    earthquakesScrollController.addListener((){
      _savedOffset = earthquakesScrollController.offset;
    });

    return ListView.builder(
      controller: earthquakesScrollController,
      itemBuilder: (context, index){
        if(index < Data.earthquakes.length - 10)
          return EarthquakeWidget(index,
            onTap: (){
              setState(() {
                _selectedPage = 1;
                _earthquakeToShow = index;
              });
            },
          );
        else if(EarthquakesProvider.hasMoreEarthquakes()){
          _fetchMoreEarthquakes();
          return EarthquakeWidget(index,
            onTap: (){
              setState(() {
                _selectedPage = 1;
                _earthquakeToShow = index;
              });
            },
          );
        }
        else if(index < Data.earthquakes.length){
          return EarthquakeWidget(index,
            onTap: (){
              setState(() {
                _selectedPage = 1;
                _earthquakeToShow = index;
              });
            },
          );
        }
      }
    );
  }

  Widget _stateButton(String title, int index){
    return GestureDetector(
      child: Container(
        padding: new EdgeInsets.all(5.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _selectedButton[index] ? Colors.blue[500] : Colors.green[800]
        ),
        child: Text(title,
          style: TextStyle(fontSize: 20.0, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      onTap: (){
        if(!_selectedButton[index] && _hasLoaded)
          setState(() {
            for(int i=0; i<_selectedYear.length; i++)
              _selectedYear[i] = false;
            for(int i=0; i<_selectedButton.length; i++)
              _selectedButton[i] = false;

            _selectedButton[index] = true;
            _memoizer = AsyncMemoizer();
          });
      },
    );
  }

  Widget _drawerWidget(){
    List<Widget> yearWidgets = [];
    for(int i=0; i<_significantYears.length; i++){
      yearWidgets.add(GestureDetector(
        child: Card(
          elevation: 5.0,
          margin: new EdgeInsets.all(10.0),
          color: _selectedYear[i] ? Colors.blue[500] : Colors.green[800],
          child: Container(
            height: MediaQuery.of(context).size.height / 10,
            padding: new EdgeInsets.all(5.0),
            alignment: Alignment.center,
            child: Text(_significantYears[i].toString(),
              style: TextStyle(fontSize: 20.0, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        onTap: (){
          if(!_selectedYear[i] && _hasLoaded)
            setState(() {
              for(int i=0; i<_selectedButton.length; i++)
                _selectedButton[i] = false;
              for(int i=0; i<_selectedYear.length; i++)
                _selectedYear[i] = false;

              _selectedYear[i] = true;
              _memoizer = AsyncMemoizer();
              Navigator.pop(context);
            });
        },
      ));
    }

    yearWidgets.insert(0, Container(
      padding: new EdgeInsets.symmetric(vertical: 10.0),
      child: Text("Significant earthquakes from previous years",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black,
          fontSize: 25.0
        ),
        textAlign: TextAlign.center,
      ),
    ));

    return Container(
      child: ListView(
        children: yearWidgets,
      ),
    );
  }

  int _findDaysSelected(){
    if(_selectedButton[0])
      return 1;
    else if(_selectedButton[1])
      return 2;
    else if(_selectedButton[2])
      return 10;
    else if(_selectedButton[3])
      return 20;
    else if(_selectedButton[4])
      return 100;

    return -1;
  }

  int _yearSelected(){
    for(int i=0; i<_significantYears.length; i++)
      if(_selectedYear[i])
        return _significantYears[i];

    return -1;
  }
}

import 'package:flutter/material.dart';
import 'package:weather_app/data/network_data.dart';
import 'package:weather_app/model/weather_json.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => new _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Future _futureWeather;
  TextEditingController _controller;
  PageController _pageController;
  int _selectedDay = 0;

  void cambiaDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Scegli una città"),
            content: TextFormField(
              controller: _controller,
              onFieldSubmitted: (String text) {},
            ),
            actions: [
              FlatButton(
                child: Text("Cerca"),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _futureWeather = NetworkData.getWeather(_controller.text);
                  });
                },
              )
            ],
          );
        });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = new TextEditingController();
    _pageController = new PageController();
    super.initState();
  }

  Widget _bodyLista(_weatherJson) => Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _pageController,
              itemCount: 5,
              itemBuilder: (context, index) {
                List<ListElement> _elementPerDay = _weatherJson.list
                    .where((_w) =>
                        _w.dtTxt.day == (DateTime.now().day + index + 1))
                    .toList();
                return InkWell(
                  onTap: () => setState(() => _selectedDay = index),
                  child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      child: TileWeather(
                        isSelected: _selectedDay == index,
                        listElement: _elementPerDay,
                      )),
                );
              },
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey[50],
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(_controller.text,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => cambiaDialog(),
              color: Colors.black87,
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    "Prossimi 5 giorni",
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
            if (_controller.text.isNotEmpty)
              Expanded(
                child: FutureBuilder(
                  future: _futureWeather,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    CompleteWeather _weatherJson = snapshot.data;

                    if (_weatherJson.cod == "200")
                      return _bodyLista(_weatherJson);
                    return Center(
                      child: Text(_weatherJson.message.toString()),
                    );
                  },
                ),
              ),
            if (_controller.text.isEmpty)
              Expanded(
                child: Center(
                  child: Text("Impostare una città"),
                ),
              )
          ],
        ));
  }
}

class TileWeather extends StatelessWidget {
  final List<ListElement> listElement;
  final bool isSelected;
  TileWeather({@required this.listElement, this.isSelected = false})
      : assert(listElement != null);

  String _testoData(int i) {
    var format = DateFormat('HH:mm').format(listElement[i].dtTxt);

    return format;
  }

  String get _testoPrincipale {
    String _localText = DateFormat("EEEE, dd MMM").format(listElement[5].dtTxt);

    return _localText.substring(0, 1).toUpperCase() +
        _localText.substring(1, _localText.length);
  }

  Widget _chiuso() {
    return Container(
      height: 80,
      margin: EdgeInsets.symmetric(vertical: 1),
      color: Colors.white,
      child: Center(
        child: ListTile(
            leading: CachedNetworkImage(
              imageUrl:
                  "https://openweathermap.org/img/wn/${listElement[5].weather.first.icon}@2x.png",
              placeholder: (context, _) {
                return Container(
                  color: Colors.grey,
                  width: 100,
                  height: 100,
                );
              },
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(listElement[5].main.tempMax.ceil().toString() + "°",
                    style:
                        TextStyle(color: Colors.blueGrey[900], fontSize: 18)),
                Text(" / ",
                    style:
                        TextStyle(color: Colors.blueGrey[900], fontSize: 18)),
                Text(listElement[5].main.tempMin.ceil().toString() + "°",
                    style: TextStyle(color: Colors.blueGrey[900], fontSize: 18))
              ],
            ),
            // subtitle: Text(_testoData,
            //     style: TextStyle(color: Colors.blueGrey[900], fontSize: 14)),
            title: Text(_testoPrincipale,
                style: TextStyle(color: Colors.blueGrey[900], fontSize: 18))),
      ),
    );
  }

  Widget _aperto() {
    return Container(
      height: 280,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 1),
            child: ListTile(
                leading: CachedNetworkImage(
                  imageUrl:
                      "https://openweathermap.org/img/wn/${listElement[5].weather.first.icon}@2x.png",
                  placeholder: (context, _) {
                    return Container(
                      color: Colors.grey,
                      width: 100,
                      height: 100,
                    );
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(listElement[5].main.tempMax.ceil().toString() + "°",
                        style: TextStyle(
                            color: Colors.blueGrey[900], fontSize: 18)),
                    Text(" / ",
                        style: TextStyle(
                            color: Colors.blueGrey[900], fontSize: 18)),
                    Text(listElement[5].main.tempMin.ceil().toString() + "°",
                        style: TextStyle(
                            color: Colors.blueGrey[900], fontSize: 18))
                  ],
                ),
                title: Text(_testoPrincipale,
                    style:
                        TextStyle(color: Colors.blueGrey[900], fontSize: 18))),
          ),
          Divider(thickness: 2, color: Colors.white),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              child: GridView(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 16,
                    crossAxisCount: 2,
                    childAspectRatio: 3),
                children: [
                  _rigaTesto("Precipitazioni",
                      (listElement[5]?.rain?.the3H ?? 0).toString(), "%"),
                  _rigaTesto(
                      "Vento", listElement[5].wind.speed.toString(), "km/h"),
                  _rigaTesto(
                      "Umidità", listElement[5].main.humidity.toString(), "%"),
                  _rigaTesto("Pressione",
                      listElement[5].main.pressure.toString(), "hPa"),
                ],
              ),
            ),
          ),
          Container(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: listElement.length,
              itemBuilder: (context, i) => Container(
                height: 64,
                width: 64,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CachedNetworkImage(
                      height: 48,
                      imageUrl:
                          "https://openweathermap.org/img/wn/${listElement[i].weather.first.icon}@2x.png",
                      placeholder: (context, _) {
                        return Container(
                          color: Colors.grey,
                          width: 30,
                          height: 30,
                        );
                      },
                    ),
                    Text(_testoData(i))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rigaTesto(String titolo, String valore, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titolo, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(valore + unit),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isSelected ? _aperto() : _chiuso();
  }
}

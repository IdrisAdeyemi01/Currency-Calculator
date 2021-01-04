import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'countries_list.dart';
import 'my_charts.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ConverterPage extends StatefulWidget {
  @override
  _ConverterPageState createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {



  @override
  void initState() {
    getData();
    setFlagLink(1);
    setFlagLink(2);
    super.initState();
  }

  var dataBody;
  String richText1;
  String richText2;
  String flagLink1;
  String flagLink2;
  String dropdownValue1 = 'EUR';
  String dropdownValue2 = 'EUR';
  double value;
  DateTime date = DateTime.now();
  bool showSpinner = false;
  // String apiKey = '5504d1d0e31047d4d1b4e574890c589e';
  String apiKey = '49665b2273080a50926cb7b284697769';

  void getValue() {
    //This method helps to set the value of the texts to be placed into the container where the calculated amounts of conversion rates is
    var value1 = dataBody['rates'][dropdownValue2];
    var value2 = dataBody['rates'][dropdownValue1];
    setState(() {
      value = value1 / value2;
      var rich = value.toStringAsFixed(6);
      richText1 = rich.substring(0, rich.length - 3);
      richText2 = rich.substring(rich.length - 3, rich.length);
    });

    print(richText1);
    print(richText2);
  }

  Future getData() async {
    //This function helps with the API call
    http.Response response =
        await http.get('http://data.fixer.io/api/latest?access_key=$apiKey');
    var body = jsonDecode(response.body);
    if (body['success'] == true) {
      setState(() {
        dataBody = body;
      });
    } else {
      print(body['error']['info']);
    }
  }

  Future<String> getCountryFlag(String currency) async {
    //This also helps with API calls but in this case it is to get country flags placed in the dropdown
    http.Response response =
        await http.get('http://restcountries.eu/rest/v2/currency/$currency');
    var responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      var flagLink = responseBody[0]['flag'];
      return flagLink;
    } else {
      print(responseBody['message']);
      return null;
    }
  }

  void setFlagLink(int position) async {
    //This function helps to change the flag of a country after the dropdown of the currency has been selected
    if (position == 1) {
      flagLink1 = await getCountryFlag(dropdownValue1);
      setState(() {});
    } else {
      flagLink2 = await getCountryFlag(dropdownValue2);
      setState(() {});
    }
  }

  List<DropdownMenuItem<String>> getDropdownItems() {
    //This helps to get the list of currency into the dropdown... This list is gotten from an API but copied into data.dart file
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (var i in countriesList()) {
      dropdownItems.add(
        DropdownMenuItem(
          child: Text(i),
          value: i,
        ),
      );
    }
    return dropdownItems;
  }

  Future<List> getHistoryRates() async {
    //This func helps to get the historical data for the two countries in the dropdown list after conversion
    List exchanges = [];

    for (var i = 31; i >= 1; i--) {
      var newDate = date.subtract(Duration(days: i));
      http.Response response = await http.get(
          'http://data.fixer.io/api/${newDate.year.toString().padLeft(4, '0')}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}?access_key=$apiKey&symbols=$dropdownValue1,$dropdownValue2&format=1');
      var result = jsonDecode(response.body);
      
      if (result['success'] == true) {
        var rate1 = result['rates'][dropdownValue1];
        var rate2 = result['rates'][dropdownValue2];
        double rate = rate2 / rate1;
        exchanges.add(rate);
      } else {
        print(result['error']['info']);
      }
    }
    setState(() {
      exchangeRates = exchanges;
    });
    return exchangeRates;
  }

  List exchangeRates;

  MyLineChart getChart(double x) {
    //This function is used to assign values to the graph. The graph is gotten from my_charts.dart file
    if (exchangeRates != null) {
      List exchangeRate2 = exchangeRates.sublist(
          20); //I would use this for when x = 10 so as not to disturb the list of exchangeRates
      num minX = 1.0;
      num maxX = x;
      num minY = exchangeRates
          .reduce((current, next) => current < next ? current : next);
      num maxY = exchangeRates
          .reduce((current, next) => current > next ? current : next);
      List<FlSpot> spots = [];
      for (num i = 1.0; i <= x; i++) {
        if (x == 30) {
          spots.add(FlSpot(i, exchangeRates[(i).toInt()]));
        } else {
          spots.add(FlSpot(i, exchangeRate2[(i).toInt()]));
        }
      }
      return MyLineChart(
          currency1: dropdownValue1,
          maximumX: maxX,
          minimumX: minX,
          maximumY: maxY,
          minimumY: minY,
          spots: spots,
          graphValue: x);
    } else {
      return MyLineChart(
        currency1: dropdownValue1,
        maximumX: 2,
        minimumX: 1,
        maximumY: 2,
        minimumY: 0,
        spots: [
          FlSpot(1, 1),
          FlSpot(2, 1),
        ],
      );
    }
  }

  void changeSpinner() {
    //This helps the user to see a loading screen when some underground task are being done
    setState(() {
      showSpinner = !showSpinner;
    });
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 30, left: 30, right: 30),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            'assets/hamburger.svg',
                            color: Color(0xFF00D998),
                          ),
                          Text(
                            'Sign Up',
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'BR-Firma',
                                color: Color(0xFF00D998)),
                          )
                        ],
                      ),
                      SizedBox(
                        height: screenSize.height * 0.1,
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: 'Currency \nCalculator',
                              style: TextStyle(
                                  fontFamily: 'BR-Firma',
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0075FF))),
                          TextSpan(
                              text: '.',
                              style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00D998)))
                        ]),
                      ),
                      SizedBox(
                        height: screenSize.height * 0.06,
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '1',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800),
                            ),
                            Text(
                              dropdownValue1,
                              style: TextStyle(
                                  fontSize: 18, color: Color(0xFFC4C4C4)),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: screenSize.height * 0.03,
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                text: richText1 == null ? '1.0' : richText1,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800),
                              ),
                              TextSpan(
                                text: richText2 == null ? '' : richText2,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFFC4C4C4),
                                    fontWeight: FontWeight.w800),
                              ),
                            ])),
                            Text(
                              dropdownValue2,
                              style: TextStyle(
                                  fontSize: 18, color: Color(0xFFC4C4C4)),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: screenSize.height * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FittedBox(
                            child: Container(
                              width: screenSize.width * 0.3,
                              height: 50,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFC4C4C4)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  flagLink1 == null
                                      ? Text(
                                          '${dropdownValue1.substring(0, 1)}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800),
                                        )
                                      : SvgPicture.network(
                                          flagLink1,
                                          height: 15,
                                          width: 15,
                                        ),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                        iconSize: 15,
                                        icon: Icon(
                                          FontAwesomeIcons.chevronDown,
                                        ),
                                        value: dropdownValue1,
                                        items: getDropdownItems(),
                                        onChanged: (val) {
                                          setState(() {
                                            dropdownValue1 = val;
                                            setFlagLink(1);
                                          });
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Image.asset('assets/exchange-icon.png',
                              height: 50, width: 100, color: Color(0xFFC4C4C4)),
                          FittedBox(
                            child: Container(
                              width: screenSize.width * 0.3,
                              height: 50,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFC4C4C4)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  flagLink2 == null
                                      ? Text(
                                          '${dropdownValue2.substring(0, 1)}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800),
                                        )
                                      : SvgPicture.network(
                                          flagLink2,
                                          height: 15,
                                          width: 15,
                                        ),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                        iconSize: 15,
                                        icon: Icon(
                                          FontAwesomeIcons.chevronDown,
                                        ),
                                        value: dropdownValue2,
                                        items: getDropdownItems(),
                                        onChanged: (val) {
                                          setState(() {
                                            dropdownValue2 = val;
                                            setFlagLink(2);
                                          });
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: screenSize.height * 0.08,
                      ),
                      GestureDetector(
                        onTap: () async {
                          bool result =
                              await DataConnectionChecker().hasConnection;
                          if (result == true) {
                            changeSpinner();
                            getValue();
                            getHistoryRates();
                            List listOfDates = await getHistoryRates();
                            //getChart(10);
                            //getChart(20);
                            changeSpinner();
                            print(listOfDates);
                          } else {
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: Text(
                                    'You\'re not connected to the internet'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Color(0xFF00D998),
                          ),
                          child: Center(
                            child: Text(
                              'Convert',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 30,
                          left: 10,
                          right: 10,
                        ),
                        child: FittedBox(
                          child: Row(
                            children: [
                              Text(
                                'Mid market exchange rate at 13:38 UTC',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Color(0xFF0075FF),
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(width: 10),
                              CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Color(0xFFE0E0E0),
                                  child: Text(
                                    'i',
                                    style: TextStyle(
                                        fontSize: 18, color: Color(0xff2979ff)),
                                  ))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenSize.height * 0.07,
                      )
                    ],
                  ),
                ),
                DefaultTabController(
                  length: 2,
                  child: Container(
                    height: screenSize.height * 0.7,
                    padding: EdgeInsets.only(top: 30, bottom: 50),
                    decoration: BoxDecoration(
                        color: Color(0xFF0075FF),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            child: TabBar(
                                indicator: CircleTabIndicator(
                                    radius: 5, color: Colors.green),
                                tabs: [
                                  Tab(
                                    child: Text('Past 10 days',
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                  Tab(
                                    child: Text('Past 30 days',
                                        style: TextStyle(fontSize: 18)),
                                  )
                                ]),
                          ),
                          Expanded(
                            child: Container(
                              child: TabBarView(children: [
                                Container(
                                  child: getChart(10),
                                ),
                                Container(
                                  child: getChart(30),
                                ),
                              ]),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10, right: 40),
                            child: Text(
                              'Get rate alert straight to your email box',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color color, @required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  //This is used to make the TabBarIndicator a circle
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}

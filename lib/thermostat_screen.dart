import 'package:flutter/material.dart';
import 'package:thermostat/thermostat.dart';

class ThermostatScreen extends StatefulWidget {
  @override
  _ThermostatScreenState createState() => _ThermostatScreenState();
}

class _ThermostatScreenState extends State<ThermostatScreen> {
  static const textColor = const Color(0xFFFFFFFD);

  bool _turnOn;

  @override
  void initState() {
    _turnOn = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F2027),
          /*gradient: new LinearGradient(
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF2C5364),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),*/
        ),
        child: new SafeArea(
          child: new Column(
            children: <Widget>[
              new Container(
                height: 52.0,
                child: new Row(
                  children: <Widget>[
                    new Container(
                      width: 48.0,
                      alignment: Alignment.center,
                      child: new Icon(
                        Icons.keyboard_backspace,
                        color: textColor,
                      ),
                    ),
                    new Container(
                      width: 1.0,
                      color: textColor,
                      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                    ),
                    new Expanded(
                      child: new Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            'Thermostat',
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          new Text(
                            'Living Room',
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 12.0,
                            ),
                          ),
                          new SizedBox(height: 5.0),
                        ],
                      ),
                    ),
                    new Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new InfoIcon(
                          icon: new Icon(
                            Icons.beach_access,
                            color: const Color(0xFFA9A6AF),
                            size: 16.0,
                          ),
                          text: '27 C',
                        ),
                        new SizedBox(height: 5.0),
                        InfoIcon(
                          icon: new Icon(
                            Icons.invert_colors,
                            color: const Color(0xFFA9A6AF),
                            size: 16.0,
                          ),
                          text: '80.6 F',
                        ),
                      ],
                    )
                  ],
                ),
              ),
              new Expanded(
                child: new Center(
                  child: new Thermostat(
                    radius: 150.0,
                    turnOn: _turnOn,
                    modeIcon: Icon(
                      Icons.ac_unit,
                      color: Color(0xFF3CAEF4),
                    ),
                    textStyle: new TextStyle(
                      color: textColor,
                      fontSize: 34.0,
                    ),
                    minValue: 18,
                    maxValue: 38,
                    initialValue: 26,
                    onValueChanged: (value) {
                      print('Selected value : $value');
                    },
                  ),
                ),
              ),
              new Container(
                //width: double.infinity,
                height: 1.0,
                color: Colors.white.withOpacity(0.2),
              ),
              new Container(
                margin: EdgeInsets.symmetric(vertical: 24.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    BottomButton(
                      icon: new Icon(
                        Icons.ac_unit,
                        color: _turnOn ? Color(0xFF4EC4EC) : Colors.white,
                      ),
                      text: 'Cooling',
                      onTap: () {
                        setState(() {
                          _turnOn = !_turnOn;
                        });
                      },
                    ),
                    BottomButton(
                      icon: new Icon(
                        Icons.invert_colors,
                        color: Colors.white,
                      ),
                      text: 'Fan',
                    ),
                    BottomButton(
                      icon: new Icon(
                        Icons.schedule,
                        color: Colors.white,
                      ),
                      text: 'Schedule',
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InfoIcon extends StatelessWidget {
  final Widget icon;
  final String text;

  const InfoIcon({Key key, this.icon, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        icon,
        new SizedBox(width: 8.0),
        new Text(
          text,
          style: const TextStyle(
            color: const Color(0xFFA9A6AF),
            fontSize: 12.0,
          ),
        ),
        new SizedBox(width: 12.0),
      ],
    );
  }
}

class BottomButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onTap;

  const BottomButton({
    Key key,
    this.icon,
    this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: onTap,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Container(
            width: 52.0,
            height: 52.0,
            margin: const EdgeInsets.only(bottom: 8.0),
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3F5BFA)),
            ),
            child: icon,
          ),
          new Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          )
        ],
      ),
    );
  }
}

bool almostEqual(double a, double b, double eps) {
  return (a - b).abs() < eps;
}

bool angleBetween(
    double angle1, double angle2, double minTolerance, double maxTolerance) {
  final diff = (angle1 - angle2).abs();
  return diff >= minTolerance && diff <= maxTolerance;
}

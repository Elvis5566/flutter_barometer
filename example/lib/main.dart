import 'package:flutter/material.dart';
import 'package:flutter_barometer/flutter_barometer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var openStream = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: FutureBuilder<bool>(
          key: Key(DateTime.now().hashCode.toString()),
          future: FlutterBarometer.instance.isValid,
          initialData: false,
          builder: (_, snapshot) => Column(
            children: [
              Text('Barometer valid: ${snapshot.data}'),
              RaisedButton(
                child: Text(openStream ? 'Close Stream' : 'Open Stream'),
                onPressed: () => setState(() => openStream = !openStream),
              ),
              if (snapshot.data && openStream)
                StreamBuilder<BarometerData>(
                  stream: FlutterBarometer.instance.stream,
                  builder: (context, snapshot) => Text('Pressure: ${snapshot.data?.pressure}, RelativeAltitude: ${snapshot?.data?.altitude}'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

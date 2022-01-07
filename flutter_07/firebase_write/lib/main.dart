import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Coffee Roasting Curve - Firebase Write';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: _title,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(_title),
            backgroundColor: Colors.blueGrey,
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: const MyHomePage(title: 'Realtime Chart'),
          ),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<LiveData> chartData;
  final database = FirebaseDatabase.instance;

  @override
  void initState() {
    chartData = <LiveData>[];
    writeDB();
    super.initState();
  }

  Widget sfchart() => Expanded(
          child: SfCartesianChart(
        primaryXAxis: NumericAxis(
            majorGridLines: const MajorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            interval: 30,
            title: AxisTitle(text: 'Time (seconds)')),
        primaryYAxis: NumericAxis(
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 1),
            interval: 5,
            minimum: 80,
            maximum: 240,
            title: AxisTitle(text: 'Temperature (°C)')),
        series: <LineSeries<LiveData, int>>[
          LineSeries<LiveData, int>(
            dataSource: chartData,
            pointColorMapper: (LiveData dat, _) =>
                (dat.k1 > 180) ? Colors.red : Colors.blue,
            xValueMapper: (LiveData dat, _) => dat.time,
            yValueMapper: (LiveData dat, _) => dat.k1,
          ),
          LineSeries<LiveData, int>(
            dataSource: chartData,
            pointColorMapper: (LiveData dat, _) =>
                (dat.k2 > 180) ? Colors.purple : Colors.green,
            xValueMapper: (LiveData dat, _) => dat.time,
            yValueMapper: (LiveData dat, _) => dat.k2,
          ),
        ],
      ));

  Widget screen() => SizedBox(
        height: 200,
        width: 200,
        child: Card(
          color: Colors.black87,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white12, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          margin: const EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.center,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                k1.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 50,
                  color: (k1 >= 180) ? Colors.red : Colors.green,
                ),
              ),
              Text(
                k2.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 50,
                  color: (k1 >= 180) ? Colors.red : Colors.green,
                ),
              ),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth <= 600) {
          return Column(children: [
            sfchart(),
            screen(),
          ]);
        } else {
          return Row(children: [
            sfchart(),
            screen(),
          ]);
        }
      },
    ));
  }

  CoffeeRoasting tempK1 = CoffeeRoasting();
  double k1 = 210;
  double k2 = 0;

  Future<void> writeDB() async {
    DatabaseReference fbRef = database.ref('roaster1');
    await fbRef.remove();
    for (var clk = 0; clk <= 5*10; clk += 5) {
      k1 = tempK1.next();
      k2 = k1 + 15 + Random().nextInt(5);
      await fbRef.push().set({
        'time': clk,
        'k1': double.parse(k1.toStringAsFixed(1)),
        'k2': double.parse(k2.toStringAsFixed(1)),
      });
      setState(() {
        chartData.add(LiveData(clk, k1, k2));
      });
    }
  }
}

class LiveData {
  LiveData(this.time, this.k1, this.k2);

  final int time;
  final num k1;
  final num k2;
}

class CoffeeRoasting {
  double k1 = 210;
  double kt = 210;
  int step = 90;
  int state = 0;
  int rate = 5;

  List<List<double>> ns = [
    [210, 30], [90, 90], [92, 30], [95, 30], [160, 180],
    [170, 180], [190, 60], [200, 90],  [210, 60], [220, 180]];

  double next() {
    if (k1 == kt) {
      kt = ns[state][0];
      step = ns[state++][1] ~/ rate;
      if (state >= ns.length) state = 0;
    }
    if (step >= 1) {
      if (Random().nextBool()) k1 -= (k1 - kt) / step;
      if (step == 1) k1 = kt;
      step--;
    }
    return k1;
  }
}


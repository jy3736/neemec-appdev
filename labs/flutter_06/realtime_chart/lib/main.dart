import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'App Development 2021 Fall',
        home: Scaffold(
          appBar: AppBar(
              title: const Text(
            'Realtime Line Chart',
          )),
          body: const MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title = "Flutter"}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<LiveData> netData1 = <LiveData>[];
  List<LiveData> netData2 = <LiveData>[];
  late ChartSeriesController _controller1;
  late ChartSeriesController _controller2;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer =
        Timer.periodic(const Duration(milliseconds: 300), updateDataSource);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: SfCartesianChart(
                series: <LineSeries<LiveData, int>>[
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              _controller1 = controller;
            },
            dataSource: netData1,
            color: const Color.fromRGBO(192, 108, 132, 1),
            xValueMapper: (LiveData dat, _) => dat.time,
            yValueMapper: (LiveData dat, _) => dat.temp,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              _controller2 = controller;
            },
            dataSource: netData2,
            color: const Color.fromRGBO(14, 59, 113, 1.0),
            xValueMapper: (LiveData dat, _) => dat.time,
            yValueMapper: (LiveData dat, _) => dat.temp,
          )
        ],
                primaryXAxis: NumericAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    interval: 3,
                    title: AxisTitle(text: 'Time (seconds)')),
                primaryYAxis: NumericAxis(
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    title: AxisTitle(text: 'Temperature (°C)')))));
  }

  int _counter = 0;
  int _t1 = 0;
  int _t2 = 0;

  int randTemp(int t) => t + Random().nextInt(4) - 2;

  void updateDataSource(Timer timer) {
    setState(() {
      netData1.add(LiveData(_counter++, _t1));
      netData2.add(LiveData(_counter++, _t2));
      _t1 = randTemp(_t1);
      _t2 = randTemp(_t2);
    });
    if (_counter > 50) {
      netData1.removeAt(0);
      netData2.removeAt(0);
      _controller1.updateDataSource(
          addedDataIndex: netData1.length - 1, removedDataIndex: 0);
      _controller2.updateDataSource(
          addedDataIndex: netData2.length - 1, removedDataIndex: 0);
    }
  }
}

class LiveData {
  LiveData(this.time, this.temp);

  final int time;
  final num temp;
}

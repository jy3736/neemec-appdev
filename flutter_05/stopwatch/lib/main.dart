import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Intro. App Development 2021 Fall',
        home: Scaffold(
          appBar: AppBar(
              title: const Text(
            'Simple Stopwatch',
          )),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/3.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: const MyHomePage(),
          ),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title = "STUST"}) : super(key: key);

  final String? title;

  @override
  State<StatefulWidget> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  bool flip = false;
  int counter = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(milliseconds: 300),
      (timer) {
        setState(() {
          if (flip) counter++;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Expanded(flex: 1, child: Container()),
      Expanded(
        flex: 2,
        child: Text("$counter",
            style: const TextStyle(fontSize: 120, color: Colors.black)),
      ),
      Expanded(
        flex: 3,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 200,
            child: TextButton(
              onPressed: () {
                setState(() {
                  flip = !flip;
                });
              },
              child: flip
                  ? const Text("PAUSE",
                      style: TextStyle(fontSize: 50, color: Colors.red))
                  : const Text("GO",
                      style: TextStyle(fontSize: 50, color: Colors.green)),
            ),
          ),
          TextButton(
              onPressed: () {
                setState(() {
                  flip = false;
                  counter = 0;
                });
              },
              child: const Text("CLEAR",
                  style: TextStyle(fontSize: 50, color: Colors.deepOrange))),
        ]),
      ),
      const SizedBox(height: 20),
    ]));
  }
}


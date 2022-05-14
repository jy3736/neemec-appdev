import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final cid = uuid.v4();
const broker = 'broker.emqx.io';
const port = 1883;
const user = 'stust2021f';
const passwd = 'password';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('MQTT Client'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const MyHomePage(),
      ),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController txtMsgCtrl =
      TextEditingController(text: 'Uint8Buffer轉成中文亂碼問題');
  final TextEditingController txtTopicCtrl =
      TextEditingController(text: 'P306-100');

  final client = MqttServerClient(broker, cid);
  bool _connected = false;
  Map<String, String> mqttMsg = <String, String>{};

  @override
  void initState() {
    connect();
    super.initState();
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
                _connected ? 'MQTT Broker Connected' : 'No MQTT Connection'),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 3.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.deepOrangeAccent, width: 3.0),
                ),
                hintText: 'MQTT Message Topic...',
              ),
              controller: txtTopicCtrl,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: txtMsgCtrl,
              decoration:
                  const InputDecoration(hintText: 'Message to MQTT Broker...'),
            ),
          ),
          ElevatedButton(
            child: const Text('Publish'),
            onPressed: btnEvent,
          ),
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              mqttMsg.toString(),
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }

  void btnEvent() {
    String pubTopic = txtTopicCtrl.text;
    final builder = MqttClientPayloadBuilder();
    //builder.addString(txtMsgCtrl.text);
    builder.addUTF8String(txtMsgCtrl.text);
    client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload!);
  }

  Future<MqttServerClient?> connect() async {
    client.port = port;
    client.keepAlivePeriod = 30;
    client.setProtocolV311();
    client.logging(on: false);
    await client.connect(user, passwd);
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      setState(() {
        _connected =
            client.connectionStatus!.state == MqttConnectionState.connected;
      });
    } else {
      client.disconnect();
    }
    client.subscribe("P306-100/#", MqttQos.atLeastOnce);
    client.subscribe("P306-200/+/K1", MqttQos.atLeastOnce);
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final message = c[0].payload as MqttPublishMessage;
      setState(() {
        mqttMsg[c[0].topic] =
            const Utf8Decoder().convert(message.payload.message);
      });
    });
  }
}


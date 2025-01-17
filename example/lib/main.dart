
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_peripheral/flutter_blue_peripheral.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await FlutterBluePeripheral.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    FlutterBluePeripheral.init(didReceiveRead: (MethodCall call) {
      print(call.arguments);
      return Uint8List.fromList([11,2,3,4,5,6,7,8,9,10]);
    }, didReceiveWrite: (MethodCall call) {
      FlutterBluePeripheral.peripheralUpdateValue(
        centralUuid: call.arguments["centralUuid"],
        characteristicUuid: call.arguments["characteristicUuid"],
        data: Uint8List.fromList([11,2,3]),
      );
      print(call.arguments);
    }, didSubscribeTo: (MethodCall call) {
      print(call.arguments);
      FlutterBluePeripheral.peripheralUpdateValue(
        centralUuid: call.arguments["centralUuid"],
        characteristicUuid: call.arguments["characteristicUuid"],
        data: Uint8List.fromList([11,2,3,4,5,6,7,8,9,10,11,2,3]),
      );
    }, didUnsubscribeFrom: (MethodCall call) {
      print(call.arguments);
    }, peripheralManagerDidUpdateState: (MethodCall call) {
      print(call.arguments);
    });

    FlutterBluePeripheral.startPeripheral(
      serviceUuid: "00000000-0000-0000-0000-AAAAAAAAAAA1",
      characteristicUuid: "00000000-0000-0000-0000-AAAAAAAAAAA2",
    ).then((_){});

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}

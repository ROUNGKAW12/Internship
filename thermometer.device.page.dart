import 'dart:async';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ThermometerBluetoothCharacteristic {
  static const thermo = "";
}

class ThermometerBluetoothService {
  static const thermo = "";
}

class ConnectDevicePage extends StatefulWidget {
  const ConnectDevicePage({
    super.key,
    required this.title,
    required this.device,
  });
  final String title;
  final BluetoothDevice device;

  @override
  State<StatefulWidget> createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  List<BluetoothService> services = [];
  StreamSubscription? sub;
  late BluetoothCharacteristic targetChar;

  void initState() {
    super.initState();
    findTargetChar();
  }

  void findTargetChar() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    BluetoothService targetService = services.firstWhere((service) =>
        service.uuid.toString() == ThermometerBluetoothService.thermo);
    BluetoothCharacteristic targetChar = targetService.characteristics
        .firstWhere((char) =>
            char.uuid.toString() == ThermometerBluetoothCharacteristic.thermo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SfRadialGauge(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (sub != null) sub!.cancel();
  }
}

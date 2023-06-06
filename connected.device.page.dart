import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class OximeterBluetoothCharacteristic {
  static const oxygen = "cdeacb81-5235-4c07-8846-93a37ee6b86d";
}

class OximeterBluetootService {
  static const oxygen = "cdeacb80-5235-4c07-8846-93a37ee6b86d";
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
  State<ConnectDevicePage> createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  List<BluetoothService> services = [];
  StreamSubscription? sub;
  late BluetoothCharacteristic targetChar;

  int x = -1;
  int y = -1;
  int z = -1;

  @override
  void initState() {
    super.initState();
    findTargetChar();
  }

  void findTargetChar() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    BluetoothService targetService = services.firstWhere(
        (service) => service.uuid.toString() == OximeterBluetootService.oxygen);
    BluetoothCharacteristic targetChar = targetService.characteristics
        .firstWhere((char) =>
            char.uuid.toString() == OximeterBluetoothCharacteristic.oxygen);
    sub = targetChar.value.listen((event) {
      if (event[0] == 129) {
        x = event[1];
        y = event[2];
        z = event[3];
        setState(() {});
      }

      print(event);
    });
    targetChar.setNotifyValue(!targetChar.isNotifying);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    if (sub != null) sub!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          child: Column(
            children: [
              Text(
                "$x $y $z",
              ),
            ],
          ),
        ));
  }

  List<Widget> servicesList() {
    List<Widget> list = services.map((service) {
      List<BluetoothCharacteristic> charsList = service.characteristics;

      List<Widget> charsWidget = charsList.map(
        (char) {
          if (OximeterBluetoothCharacteristic.oxygen != char.uuid.toString()) {
            return const SizedBox.shrink();
          }
          return Column(
            children: [
              Text("char id: ${char.uuid.toString()}"),
              Text("$x $y $z"),
              ElevatedButton(
                  onPressed: () {
                    char.setNotifyValue(!char.isNotifying);
                    setState(() {});
                  },
                  child: Text("${char.isNotifying}"))
            ],
          );
        },
      ).toList();
      if (OximeterBluetootService.oxygen != service.uuid.toString()) {
        return const SizedBox.shrink();
      }
      return Column(
        children: [
          Text(
            service.uuid.toString(),
          ),
          Column(
            children: charsWidget,
          )
        ],
      );
    }).toList();
    return list;
  }
}

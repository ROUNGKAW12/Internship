import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';

class OximeterBluetoothCharacteristic {
  static const oxygen = "cdeacb81-5235-4c07-8846-93a37ee6b86d";
}

class OximeterBluetoothService {
  static const oxygen = "cdeacb80-5235-4c07-8846-93a37ee6b86d";
}

class ConnectDevicePage extends StatefulWidget {
  const ConnectDevicePage({
    Key? key,
    required this.title,
    required this.device,
  }) : super(key: key);

  final String title;
  final BluetoothDevice device;

  @override
  State<ConnectDevicePage> createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  List<BluetoothService> services = [];
  StreamSubscription<List<int>>? sub;
  late BluetoothCharacteristic targetChar;

  int x = -1;
  int y = -1;
  int z = -1;

  final Logger logger = Logger('ConnectDevicePage');

  @override
  void initState() {
    super.initState();
    findTargetChar();
  }

  void findTargetChar() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    BluetoothService targetService = services.firstWhere((service) =>
        service.uuid.toString() == OximeterBluetoothService.oxygen);
    targetChar = targetService.characteristics.firstWhere((char) =>
        char.uuid.toString() == OximeterBluetoothCharacteristic.oxygen);
    sub = targetChar.value.listen((event) {
      if (event[0] == 129) {
        x = event[1];
        y = event[2];
        z = event[3];
        setState(() {});
      }

      logger.info(event);
    });
    targetChar.setNotifyValue(!targetChar.isNotifying);
    setState(() {});
  }

  void resetValues() {
    setState(() {
      x = 0;
      y = 0;
      z = 0;
    });
  }

  @override
  void dispose() {
    super.dispose();
    sub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.deepPurple),
                text: 'Value : \n',
                children: [
                  TextSpan(
                    text: '$x bpmPR  \n',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 246, 144, 11),
                    ),
                  ),
                  TextSpan(
                    text: '$y %SpO2 \n',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 168, 216, 21),
                    ),
                  ),
                  TextSpan(
                    text: '$z PI% \n',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 246, 11, 109),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: resetValues,
              child: Text('Reset Values'),
            ),
          ],
        ),
      ),
    );
  }
}

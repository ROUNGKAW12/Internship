import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ThermometerBluetoothCharacteristic {
  static const thermo = "0000fff3-0000-1000-8000-00805f9b34fb";
}

class ThermometerBluetoothService {
  static const thermo = "0000fff0-0000-1000-8000-00805f9b34fb";
}

class ConnectDevicePage extends StatefulWidget {
  const ConnectDevicePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ConnectDevicePage> createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  StreamSubscription<List<int>>? _streamSubscription;
  double _currentTemperature = 0;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _startScan() async {
    FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

    try {
      await flutterBlue.stopScan();
      await flutterBlue.startScan(timeout: const Duration(seconds: 4));

      flutterBlue.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (result.device.name == "My Thermometer") {
            _connectToDevice(result.device);
            break;
          }
        }
      });
    } catch (e) {
      print("Error starting Bluetooth scan: $e");
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    List<BluetoothService> services = await device.discoverServices();

    for (BluetoothService service in services) {
      if (service.uuid.toString() == ThermometerBluetoothService.thermo) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString() ==
              ThermometerBluetoothCharacteristic.thermo) {
            setState(() {});

            _startMonitoringTemperature(characteristic);
            break;
          }
        }
      }
    }
  }

  void _startMonitoringTemperature(
      BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);

    _streamSubscription = characteristic.value.listen((value) {
      double temperature = _getTemperatureValue(value);
      setState(() {
        _currentTemperature = temperature;
      });
    });
  }

  double _getTemperatureValue(List<int> value) {
    if (value.isEmpty || value.length < 5) {
      return 0;
    }

    int a = value[2];
    int a2 = value[3];
    double d2 = ((a << 8) + a2) + 0.0;
    double tempVal = (d2 * 1.0) / 100.0;
    return tempVal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Thermometer',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Temperature: $_currentTemperature °C',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:frame_app/pages/connected.device.page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ScanResult> foundDevices = [];
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Find Devices',
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 55, 55),
                    fontWeight: FontWeight.w900,
                    fontSize: 24),
              ),
              ElevatedButton(
                  onPressed: () async {
                    foundDevices = await flutterBlue.startScan(
                        timeout: Duration(seconds: 4)) as List<ScanResult>;
                    setState(() {});
                  },
                  child: Text("Scan")),
              ElevatedButton(
                  onPressed: () async {
                    var b = await flutterBlue.stopScan();
                    print(b);
                  },
                  child: Text("Stop")),
              Column(
                children: scannedDeviceBlock(),
              )
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<Widget> scannedDeviceBlock() {
    List<Widget> list = foundDevices.map((e) {
      BluetoothDevice device = e.device;
      String deviceName = e.device.name;
      if (deviceName.isEmpty) return const SizedBox.shrink();
      return Container(
        child: Row(
          children: [
            Text(deviceName.isEmpty ? "no name" : deviceName),
            ElevatedButton(
              onPressed: () async {
                try {
                  await e.device.connect();
                } catch (e) {
                  //
                } finally {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => ConnectDevicePage(
                                title: deviceName,
                                device: device,
                              )));
                  // getService(device);
                }
              },
              child: Text(
                "connect",
              ),
            ),
          ],
        ),
      );
    }).toList();
    return list;
  }
}

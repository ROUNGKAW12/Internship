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
        backgroundColor: Color.fromARGB(255, 88, 27, 121),
        title: Align(
          alignment: Alignment.center,
          child: Text(
            widget.title,
            style: TextStyle(
              fontFamily: 'Nunito',
              color: Colors.white70,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              shadows: [
                Shadow(
                  color: Color.fromARGB(255, 155, 155, 155),
                  offset: Offset(2, 2),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text.rich(
                TextSpan(
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: Color.fromARGB(255, 80, 38, 110),
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 155, 155, 155),
                          offset: Offset(2, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    text: 'Hi, ',
                    children: [
                      TextSpan(
                          text: 'Guest',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Color.fromARGB(255, 255, 154, 3),
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            shadows: [
                              Shadow(
                                color: Color.fromARGB(255, 155, 155, 155),
                                offset: Offset(2, 2),
                                blurRadius: 3,
                              ),
                            ],
                          ))
                    ]),
              ),
              const Text(
                'Find Devices',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: Color.fromARGB(
                      255, 87, 36, 171), // เปลี่ยนสีข้อความเป็นสีม่วง
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  shadows: [
                    Shadow(
                      color: Color.fromARGB(255, 155, 155, 155),
                      offset: Offset(2, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    foundDevices = await flutterBlue.startScan(
                            timeout: const Duration(seconds: 4))
                        as List<ScanResult>;
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 196, 163, 207)),
                  child: const Text(
                    "Scan",
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 244, 229, 255)),
                  )),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                deviceName.isEmpty ? "no name" : deviceName,
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    color: const Color.fromARGB(255, 123, 39, 176)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 145, 113, 162),
                ),
                child: const Text(
                  "Connect",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
    return list;
  }
}

import 'package:flutter/material.dart';
import 'package:frame_app/pages/myhomepage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 235, 174, 174)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ':3 Frame App'),
    );
  }
}

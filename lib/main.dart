import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final textController = TextEditingController();
  Color containerColor = const Color(0xffffaaff);
  String message = '';
  late Socket socket;

  @override
  void initState() {
    initSocket();
    super.initState();
  }

  void initSocket() async {
    socket = await Socket.connect('192.168.1.150', 3000);
    socket.listen((event) {
      receiveData(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: sendData,
        child: const Icon(Icons.send),
      ),
      appBar: AppBar(
        title: const Center(child: Text('Websocket Test')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: containerColor,
                ),
              ),
            ),
            TextField(
              controller: textController,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void sendData() async {
    if (textController.text.isNotEmpty) {
      socket.write(textController.text);
      textController.text = '';
    }
  }

  void receiveData(event) {
    List<String> data = event.toString().split(':');

    setState(() {
      if (data.length > 1 && data[0] == 'color') {
        int colorNum = 0xffaaffaa;
        try {
          colorNum = int.parse(data[1]);
          message = colorNum.toString();
        } on FormatException {
          colorNum = 0xff770000;
          message = 'Couldn\'t convert to number (${data[1]})';
        }
        containerColor = Color(colorNum);
      } else {
        message = event.toString();
      }
    });
  }

  @override
  void dispose() {
    socket.close();
    super.dispose();
  }
}

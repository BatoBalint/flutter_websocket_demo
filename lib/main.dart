import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

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
  final String url = 'http://192.168.1.150:3000';

  @override
  void initState() {
    initSocket();
    super.initState();
  }

  void initSocket() {
    socket = io(
        url,
        OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();
    socket.onConnect((data) {
      setState(() {
        message = 'Connected to $url';
      });
    });
    // socket.onAny((event, data) {
    //   setState(() {
    //     message = 'Random $event';
    //   });
    // });
    socket.onError((data) {
      setState(() {
        message = 'Error during connection ($data)';
      });
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

  void sendData() {
    socket.emit('test', 'haloooo');
  }

  @override
  void dispose() {
    super.dispose();
  }
}

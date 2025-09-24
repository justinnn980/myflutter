import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:myflutter/util/helper/network_helper.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Deddmo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Hssome Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  //
  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  List numberList = [];

  void searchNumberList() async {
    try {
      // final res = await Dio(BaseOptions(
      //   baseUrl: 'https://jsonplaceholder.typicode.com',
      //   connectTimeout: const Duration(seconds: 10), // 연결 타임아웃
      //   receiveTimeout: const Duration(seconds: 15), // 데이터 수신 타임아웃
      // )).get('/todos/1');

      // final res = await Dio(BaseOptions(
      //   baseUrl: 'http://192.168.0.130:8083',
      // )).get('/api/numbers/numberAll');
      final res = await NetworkHelper.dio.get(
        'http://172.17.12.94:8083/api/numbers/numberAll',
      );
      logger.d(res.data);
      logger.d('Response Status: ${res.statusCode}');
      logger.d('Response Headers: ${res.headers}');
      logger.d('Response Data: ${res.data}');
    } catch (e, s) {
      logger.d('fall NumberAll', error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '0',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: searchNumberList,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

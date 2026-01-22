import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notifier/conter_notifier.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '숫자 증가 App'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       const DrawerHeader(
      //         decoration: BoxDecoration(
      //           color: Colors.blue,
      //         ), child: Text('여러 앱'),
      //       ),
      //       ListTile(
      //         title: Text('숫자 증가'),
      //         onTap: () {
      //           Navigator.pop(context);
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('숫자 확인'),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(
              Alignment.bottomRight.x,
              Alignment.bottomRight.y - 0.4,
            ),
            child: FloatingActionButton(
              onPressed: () => ref.read(counterProvider.notifier).reset(),
              tooltip: 'Reset',
              child: const Icon(Icons.refresh),
            ),
          ),
          Align(
            alignment: Alignment(
              Alignment.bottomRight.x,
              Alignment.bottomRight.y - 0.2,
            ),
            child: FloatingActionButton(
              onPressed: () => ref.read(counterProvider.notifier).increment(),
              tooltip: 'Add',
              child: const Icon(Icons.add),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () => ref.read(counterProvider.notifier).decrement(),
              tooltip: 'Minus',
              child: const Icon(Icons.remove),
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:myflutter/src/model/number.dart';
import 'package:myflutter/util/helper/network_helper.dart';
import 'package:logger/logger.dart';

import 'ad_helper.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '숫자 증가 App'),
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
  List<Number> numberList = [];

  // TODO: Add _kAdIndex
  static final _kAdIndex = 4;

  // TODO: Add a banner ad instance
  BannerAd? _ad;
  int _getDestinationItemIndex(int rawIndex) {
    if (rawIndex >= _kAdIndex && _ad != null) {
      return rawIndex - 1;
    }
    return rawIndex;
  }

  void searchNumberList() async {
    try {
      final res = await NetworkHelper.dio.get(
        'https://hello-spring-3t9w.onrender.com/api/numbers/numberAll',
      );

      final List<dynamic> data =
          res.data is String ? jsonDecode(res.data) : res.data;

      // Number.fromJson(data[0]);
      /// for 문이라고 생각하면 됨
      final fetchedNumbers = data
          .map((item) => Number.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        numberList = fetchedNumbers;
      });

      logger.d('✅ numbers: $numberList');
    } catch (e, s) {
      logger.d('fall NumberAll', error: e, stackTrace: s);
    }
  }

  void numbertotal() async {
    try {
      final res = await NetworkHelper.dio.get(
        'https://hello-spring-3t9w.onrender.com/api/numbers/total',
      );
      logger.d('$res');
    } catch (e, s) {
      logger.d('fall total', error: e, stackTrace: s);
    }
  }

  void postCount() async {
    try {
      final res = await NetworkHelper.dio.post(
        'https://hello-spring-3t9w.onrender.com/api/numbers',
      );
      final data = res.data is String ? jsonDecode(res.data) : res.data;

      final number = Number.fromJson(data as Map<String, dynamic>);

      setState(() {
        numberList = [number]; // 리스트로 감싸줌
      });
    } catch (e, s) {
      logger.d('fall post Count', error: e, stackTrace: s);
    }
  }

  void deleteAll() async {
    try {
      final res = await NetworkHelper.dio.delete(
        'https://hello-spring-3t9w.onrender.com/api/numbers/deleteall',
      );
      final data = res.data is String ? jsonDecode(res.data) : res.data;

      final number = Number.fromJson(data as Map<String, dynamic>);

      setState(() {
        numberList = [number]; // 리스트로 감싸줌
      });
    } catch (e, s) {
      logger.d('fall Delete All', error: e, stackTrace: s);
    }
  }

  @override
  void initState() {
    super.initState();
    searchNumberList();

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    // TODO: Dispose a BannerAd object
    _ad?.dispose();

    super.dispose();
  }

  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ), child: Text('여러 앱'),
            ),
            ListTile(
              title: Text('숮자 증가'),
              onTap: () {

              },
            ),
            ListTile(
              title: Text('갓챠'),
              onTap: () {

              },
            )
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '숫자 확인',
            ),
            if (numberList.isEmpty)
              Text(
                '0',
                style: Theme.of(context).textTheme.headlineMedium,
              )
            else
              Text(
                numberList[numberList.length - 1].count.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(
                Alignment.bottomRight.x, Alignment.bottomRight.y - 0.2),
            child: FloatingActionButton(
              onPressed: deleteAll,
              tooltip: 'Increment',
              child: const Icon(Icons.refresh),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: postCount,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }
}

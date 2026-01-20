import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:myflutter/src/model/number.dart';
import 'package:myflutter/util/helper/network_helper.dart';
import 'package:riverpod/legacy.dart';

final logger = Logger(printer: PrettyPrinter());

/// UI에서 watch/read 할 Provider
final counterProvider = StateNotifierProvider<CounterNotifier, int>(
      (ref) => CounterNotifier()..fetchLatestCount(),
);

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  List<Number> _numberList = [];
  List<Number> get numberList => _numberList;

  /// 기존 searchNumberList()
  Future<void> fetchLatestCount() async {
    try {
      final res = await NetworkHelper.dio.get(
        'https://hello-spring-1-t4e1.onrender.com/api/numbers/numberAll',
      );

      final List<dynamic> data =
      res.data is String ? jsonDecode(res.data) : res.data;

      final fetchedNumbers = data
          .map((item) => Number.fromJson(item as Map<String, dynamic>))
          .toList();

      _numberList = fetchedNumbers;
      state = _numberList.isEmpty ? 0 : _numberList.last.count;

      logger.d('✅ latest count: $state');
    } catch (e, s) {
      logger.d('fail NumberAll', error: e, stackTrace: s);
    }
  }

  /// 기존 postCount()
  Future<void> increment() async {
    try {
      final res = await NetworkHelper.dio.post(
        'https://hello-spring-1-t4e1.onrender.com/api/numbers',
      );
      final data = res.data is String ? jsonDecode(res.data) : res.data;

      final number = Number.fromJson(data as Map<String, dynamic>);
      _numberList = [number];
      state = number.count;
    } catch (e, s) {
      logger.d('fail post Count', error: e, stackTrace: s);
    }
  }

  /// 기존 postMinus()
  Future<void> decrement() async {
    try {
      final res = await NetworkHelper.dio.post(
        'https://hello-spring-1-t4e1.onrender.com/api/numbers/minus',
      );
      final data = res.data is String ? jsonDecode(res.data) : res.data;

      final number = Number.fromJson(data as Map<String, dynamic>);
      _numberList = [number];
      state = number.count;
    } catch (e, s) {
      logger.d('fail post Minus', error: e, stackTrace: s);
    }
  }

  /// 기존 deleteAll()
  Future<void> reset() async {
    try {
      final res = await NetworkHelper.dio.delete(
        'https://hello-spring-1-t4e1.onrender.com/api/numbers/deleteall',
      );
      final data = res.data is String ? jsonDecode(res.data) : res.data;

      final number = Number.fromJson(data as Map<String, dynamic>);
      _numberList = [number];
      state = number.count; // 보통 0 내려오면 0 됨
    } catch (e, s) {
      logger.d('fail Delete All', error: e, stackTrace: s);
    }
  }
}

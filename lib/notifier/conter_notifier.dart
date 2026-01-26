import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:myflutter/src/model/number.dart';
import 'package:myflutter/util/helper/network_helper.dart';
import 'package:riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myflutter/config/env.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

final baseUrlProvider = Provider<String>((ref) => Env.baseUrl);
final logger = Logger(printer: PrettyPrinter());

final counterProvider = StateNotifierProvider<CounterNotifier, int>(
      (ref) => CounterNotifier(ref)
    ..fetchLatestCount()
    ..connectWebSocket(),
);

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier(this.ref) : super(0);

  final Ref ref;
  late final String baseUrl = ref.read(baseUrlProvider);

  String get _numbers => '$baseUrl/api/numbers';

  List<Number> _numberList = [];
  List<Number> get numberList => _numberList;

  StompClient? _client;

  /// 🔌 WebSocket 연결
  void connectWebSocket() {
    // ✅ baseUrl이 https면 wss, http면 ws로 자동 변환 + path를 /ws로 고정
    final httpUri = Uri.parse(baseUrl);
    final wsUri = httpUri.replace(
      scheme: httpUri.scheme == 'https' ? 'wss' : 'ws',
      path: '/ws', // 🔥 서버 WebSocketConfig의 addEndpoint("/ws")와 정확히 일치
    );

    logger.d('WS URL => $wsUri');

    _client = StompClient(
      config: StompConfig(
        url: wsUri.toString(),
        onConnect: _onConnect,
        onWebSocketError: (error) => logger.e('WebSocket error: $error'),
        onWebSocketDone: () => logger.w('WebSocket closed'),
        onStompError: (frame) => logger.e('STOMP error: ${frame.body}'),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _client!.activate();
  }



  void _onConnect(StompFrame frame) {
    logger.d('🟢 WebSocket connected');

    _client!.subscribe(
      destination: '/topic/total',
      callback: (frame) {
        logger.d('📩 raw frame: ${frame.body}');
        if (frame.body == null) return;

        final data = jsonDecode(frame.body!);
        final total = (data['total'] as num).toInt(); // ✅ Long/int 안전

        state = total;
        logger.d('📡 realtime total: $total');
      },
    );

    logger.d('✅ subscribed /topic/total');
  }


  @override
  void dispose() {
    _client?.deactivate();
    super.dispose();
  }

  /// 최초 로딩 시 REST로 현재 값 동기화
  Future<void> fetchLatestCount() async {
    try {
      final res = await NetworkHelper.dio.get('$_numbers/numberAll');

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

  /// 증가 (REST는 트리거 용도만)
  Future<void> increment() async {
    try {
      await NetworkHelper.dio.post(_numbers);
      // 결과는 WebSocket으로 들어옴
    } catch (e, s) {
      logger.d('fail post Count', error: e, stackTrace: s);
    }
  }

  /// 감소
  Future<void> decrement() async {
    try {
      await NetworkHelper.dio.post('$_numbers/minus');
    } catch (e, s) {
      logger.d('fail post Minus', error: e, stackTrace: s);
    }
  }

  /// 초기화
  Future<void> reset() async {
    try {
      await NetworkHelper.dio.delete('$_numbers/deleteall');
    } catch (e, s) {
      logger.d('fail Delete All', error: e, stackTrace: s);
    }
  }
}

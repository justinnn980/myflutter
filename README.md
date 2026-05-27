# 숫자 대결 — 실시간 증감 게임

여러 사용자가 실시간으로 숫자를 증가/감소시키며 경쟁하는 게임입니다.  
기획부터 Flutter 프론트엔드, Spring Boot 백엔드, 배포까지 **3일 내 단독 완성**했습니다.

![프로젝트 이미지](https://github.com/user-attachments/assets/d1070a01-0ff9-4ff0-a413-d13d8dcd1150)

---

## 핵심 설계 — 서버 중심 상태관리 + WebSocket

다중 클라이언트 환경에서 클라이언트마다 다른 숫자 값이 보이는 **데이터 불일치 문제**를 해결하기 위해 아래 구조를 설계했습니다.

```
[Flutter 앱]  →  버튼 클릭 시 REST POST  →  [Spring Boot 서버]
                                                      ↓
[Flutter 앱]  ←  WebSocket(STOMP)으로 전체 전파  ←  최종 값 계산
```

- 클라이언트는 **트리거만 전송** (증가/감소 요청)
- 서버가 최종 값을 계산한 후 **연결된 모든 클라이언트에 WebSocket으로 즉시 전파**
- 클라이언트는 서버에서 받은 값으로만 상태를 갱신 → 데이터 일관성 보장

> Polling 방식을 먼저 고려했으나, 실시간성이 떨어지고 불필요한 요청이 증가하는 문제로 WebSocket을 선택했습니다.

---

## 기술 스택

| 구분 | 기술 |
|------|------|
| 앱 | Flutter, Dart |
| 상태관리 | Riverpod (StateNotifier) |
| 실시간 통신 | WebSocket, STOMP (`stomp_dart_client`) |
| REST 통신 | Dio |
| 백엔드 | Spring Boot, H2 DB |
| 배포 | AWS EC2 |

---

## 프로젝트 구조

```
lib/
 ├── config/
 │    └── env.dart                  # 환경변수 (baseUrl 등)
 ├── notifier/
 │    └── conter_notifier.dart      # Riverpod StateNotifier — WebSocket + REST 통합
 ├── src/
 │    └── model/
 │         ├── number.dart          # 숫자 데이터 모델
 │         └── resData.dart         # API 응답 공통 모델
 ├── util/
 │    └── helper/
 │         └── network_helper.dart  # Dio 공통 설정
 └── main.dart                      # ProviderScope, 앱 진입점
```

---

## 상태관리 핵심 코드

`CounterNotifier`가 WebSocket 연결, REST 초기 동기화, 상태 갱신을 모두 담당합니다.

```dart
final counterProvider = StateNotifierProvider<CounterNotifier, int>(
  (ref) => CounterNotifier(ref)
    ..fetchLatestCount()   // 앱 시작 시 REST로 현재 값 동기화
    ..connectWebSocket(),  // WebSocket 연결 및 실시간 구독 시작
);
```

- 앱 시작 시 REST로 최신 값을 받아 초기 상태 동기화
- 이후 WebSocket `/topic/total` 구독 → 서버 전파 값으로 state 갱신
- 버튼 클릭 → REST POST(트리거) → 서버 계산 → WebSocket 전파 → UI 반영

---

## 실행 방법

```bash
# 1. 패키지 설치
flutter pub get

# 2. 환경변수 설정
# lib/config/env.dart 에서 baseUrl을 서버 주소로 변경

# 3. 실행
flutter run
```

> Flutter 3.x 이상 필요

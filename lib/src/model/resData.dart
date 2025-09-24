// import 'number.dart';
//
// class resData {
//   final List<number> resDataList;
//
//   resData({required this.resDataList});
//
//   factory resData.fromJson(List<dynamic> jsonList) {
//     return resData(
//       resDataList: (jsonList as List<dynamic>?)
//           ?.map((e) => number.fromJson(e as Map<String, dynamic>))
//           .toList() ??
//           [], // null이거나 잘못된 경우 빈 배열
//     );
//   }
// }

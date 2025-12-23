import 'dart:io';

class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-5873189881059783/9846753122";
    } else if (Platform.isIOS) {
      return "<YOUR_IOS_BANNER_AD_UNIT_ID>";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // static String get nativeAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "ca-app-pub-5873189881059783~7100158523";
  //   } else if (Platform.isIOS) {
  //     return "<YOUR_IOS_NATIVE_AD_UNIT_ID>";
  //   } else {
  //     throw UnsupportedError("Unsupported platform");
  //   }
  // }
}
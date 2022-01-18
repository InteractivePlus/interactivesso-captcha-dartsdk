import 'dart:math';

import 'package:interactivesso_captcha_dartsdk/interactivesso_captcha_dartsdk.dart';
import 'package:test/test.dart';

void main() {
  group('API Validation Test', () {
    final sdkCaller = SSOCaptchaServerSDK();

    setUp(() {
      // Additional setup goes here.
    });

    test('Get Not OK Captcha', () {
      expect(sdkCaller.getCaptcha(''), throwsA(anything));
    });

    test("Get Captcha", () async {
      var normalCaptchaResult = await sdkCaller.getCaptcha('test');
      expect(normalCaptchaResult, isA<CaptchaInfo>());
    });
  });
}

import 'package:interactivesso_captcha_dartsdk/interactivesso_captcha_dartsdk.dart';

void main() async {
  var normalCaptchaResult = await SSOCaptchaServerSDK().getCaptcha('test');
  print(normalCaptchaResult);
}

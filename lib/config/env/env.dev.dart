import 'package:flutter_sign_in/config/env/abstract_current_env.dart';
import 'package:flutter_sign_in/utils/shared_preferences.dart';

class EnvironmentDev extends CurrentEnv {
  EnvironmentDev() {
    final getUrl = SpHelper.getLocalStorage('baseUrl');
    baseUrl = 'http://10.30.13.134:4040';

    RegExp reg = RegExp(r"\/\/([\d\w.]+)", multiLine: true, unicode: true);
    final getURL = reg.firstMatch(getUrl)?.group(1);
    final baseURL = reg.firstMatch(baseUrl)?.group(1);

    if (getURL != baseURL) {
      SpHelper.setLocalStorage('baseUrl', baseUrl);
    } else {
      baseUrl = getUrl;
    }
  }
}
// 启动页

import 'package:flutter/material.dart';
import 'package:flutter_sign_in/components/animation/icon_animation/icon_animation.dart';
import 'package:flutter_sign_in/utils/plugin/index.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    initUrlScheme();
  }

  ///  初始化Scheme只使用了String类型的路由跳转
  ///  所以只有一个有需求可以使用[initPlatformStateForUriUniLinks]
  initUrlScheme() async {
    await initPlatformStateForStringUniLinks(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const IconAnimation();
    // return ClickJumpSplash(
    //   goPagePath: CustomRoute().home,
    //   localImageUrl: Assets.splash,
    // );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sign_in/components/busin/setting_bg.dart';
import 'package:flutter_sign_in/http/version.dart';
import 'package:flutter_sign_in/utils/plugin/shared_preferences.dart';
import 'package:flutter_sign_in/utils/string_handle.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum PageState {
  loading, // 加载中
  auto, // 自动更新
  noAuto, // 不自动更新
}

class Update extends StatefulWidget {
  const Update({Key? key}) : super(key: key);

  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  late PageState _currentState = PageState.noAuto;

  // 当前版本或者最新版本
  late String _newVersion = '';
  late String _localVersion = '';
  late bool _isForceUpdate = false;
  late bool _isNew = false;

  @override
  void initState() {
    super.initState();

    setLocalVersionInfo();
    setNewVersionInfo();
  }

  // 设置本地版本信息
  void setLocalVersionInfo() async {
    // 获取当前版本信息
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    setState(() => {_localVersion = currentVersion});
  }

  // 设置当前版本、是否最新、是否强制更新
  void setNewVersionInfo() async {
    // 获取最新版本接口
    // dynamic newRes = await getNewVersion(currentVersion);

    dynamic isAutoUpdate = SpHelper.getLocalStorage('isAutoUpdate');
    if (isAutoUpdate == null) {
      await SpHelper.setLocalStorage('isAutoUpdate', true);
      isAutoUpdate = true;
      setState(() => _currentState = PageState.auto);
    }

    // 如果是自动更新状态就加载loading
    if (isAutoUpdate) {
      _currentState = PageState.auto;

      setState(() => _currentState = PageState.loading);
      dynamic versionRes = await getHistoryVersion();
      setState(() => _currentState = PageState.auto);

      // 获取最新版本的信息
      final List list = versionRes['list'];

      if (versionRes['count'] > 0) {
        for (var versionItem in list) {
          _isNew = versionCompare(versionItem['versionCode'], _localVersion);
          _isNew
              ? setState(() {
                  _newVersion = versionItem['versionCode'];
                  _isForceUpdate = versionItem['isForceUpdate'];
                })
              : setState(() {
                  _newVersion = _localVersion;
                });

          if (_isNew) {
            break;
          }
        }
      }
    }

    // 不自动更新
    if (!isAutoUpdate) {
      setState(() {
        _currentState = PageState.noAuto;
      });
    }
  }

  void _isAutoUpdateButton(v) async {
    await SpHelper.setLocalStorage('isAutoUpdate', v);
    setNewVersionInfo();
    setState(() {
      if (v) _currentState = PageState.auto;
      if (!v) _currentState = PageState.noAuto;
    });
  }

  // 是否是加载中的状态
  Widget _isLoading() {
    if (_currentState == PageState.loading) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 144.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CupertinoActivityIndicator(radius: 6, animating: true),
                SizedBox(width: 6.w),
                Text(
                  'Serendipity Envoy 正在检查更新',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xff8A8A8D),
                  ),
                )
              ],
            )
          ],
        ),
      );
    } else {
      return Column(
        children: [
          // 自动更新
          SettingBg(
            leftLine: 16.w,
            child: Container(
              height: 44.h,
              margin: EdgeInsets.fromLTRB(16.w, 0, 22.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('自动更新', style: TextStyle(fontSize: 18.sp)),
                  Transform.scale(
                    // 1.r 屏幕放大的倍率也是1个像素放大的倍率
                    scale: 1.r,
                    child: CupertinoSwitch(
                      value: _currentState == PageState.auto,
                      onChanged: _isAutoUpdateButton,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // _isAutoUpdate 控制是否展示界面
          _isShowAutoUpdate()
        ],
      );
    }
  }

  // 是否展示自动更新的状态
  Widget _isShowAutoUpdate() {
    if (_currentState == PageState.auto) {
      return Column(
        children: [
          SizedBox(height: 30.h),
          SettingBg(
            leftLine: 17.w,
            childs: [
              // 服务器
              GestureDetector(
                child: Container(
                  height: 44.h,
                  margin: EdgeInsets.fromLTRB(16.w, 0, 22.w, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '最新版本',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      Text(
                        'Version $_newVersion',
                        style: TextStyle(
                            fontSize: 18.sp, color: const Color(0xff8A8A8D)),
                      ),
                    ],
                  ),
                ),
              ),

              // 使用https
              Container(
                height: 44.h,
                margin: EdgeInsets.fromLTRB(16.w, 0, 22.w, 0),
                child: GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '更新建议',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      Text(
                        _isForceUpdate ? '强制' : '非强制',
                        style: TextStyle(
                            fontSize: 18.sp, color: const Color(0xff8A8A8D)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 30.h),
          // 蓝色更新按钮
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              borderRadius: BorderRadius.circular(40),
              color: const Color(0xff0C508F),
              onPressed: () {},
              child: Text(
                '更新',
                style: TextStyle(fontSize: 18.sp),
              ),
            ),
          )
        ],
      );
    } else if (_currentState == PageState.noAuto) {
      return Column(
        children: [
          SizedBox(height: 330.h),
          Text(
            'Version $_localVersion',
            style: TextStyle(fontSize: 16.sp, color: const Color(0xff8A8A8D)),
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 5.w),
              Text(
                'Serendipity Envoy 已是最新版本',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xff8A8A8D),
                ),
              ),
            ],
          )
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          '软件更新',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.fromLTRB(20.w, 108.h, 20.w, 0),
        child: _isLoading(),
      ),
    );
  }
}

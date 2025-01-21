import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const white = Colors.white;
  static const grey400 = Color(0xffCACACA);
  static const grey500 = Color(0xff989898);
  static const greyShadow = Color(0xffFBFCFB);
  static const blue = Color(0xff1674EA);
  static const green = Color(0xff159947);
  static const red = Color(0xffF2021F);

  //secondary
  static const secondary0 = Color(0x00FDEEEE);
  static const secondary500 = Color(0xff9F0000);
  static const secondary600 = Color(0xff400000);
}

class AppOverlayStyle {
  static const SystemUiOverlayStyle secondaryNavBarColor = SystemUiOverlayStyle(
    systemNavigationBarColor: AppColors.grey500,
  );
  static const SystemUiOverlayStyle defaultyNavBarColor = SystemUiOverlayStyle(
    systemNavigationBarColor: AppColors.white,
  );
}

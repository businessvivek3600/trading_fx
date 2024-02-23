import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '/constants/app_constants.dart';
import '/constants/assets_constants.dart';

import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import 'package:rive/rive.dart';

Widget assetSvg(String path,
        {BoxFit? fit, Color? color, double? width, double? height}) =>
    SvgPicture.asset(
      'assets/svg/$path',
      fit: fit ?? BoxFit.contain,
      color: color,
      width: width,
      height: height,
    );
Widget assetRive(String path, {BoxFit? fit}) => RiveAnimation.asset(
      'assets/rive/$path',
      fit: fit ?? BoxFit.contain,
    );
Widget assetLottie(String path,
        {BoxFit? fit,
        double? width,
        double? height,
        LottieDelegates? delegates}) =>
    Lottie.asset(
      'assets/lottie/$path',
      fit: fit ?? BoxFit.contain,
      width: width,
      height: height,
      delegates: delegates,
    );

Widget assetImages(String path,
        {BoxFit? fit, Color? color, double? width, double? height}) =>
    Image.asset(
      'assets/images/$path',
      fit: fit ?? BoxFit.contain,
      color: color,
      width: width,
      height: height,
    );

ImageProvider assetImageProvider(String path, {BoxFit? fit}) =>
    AssetImage('assets/images/$path');

ImageProvider userAppBgImageProvider(BuildContext context) {
  var userData = sl.get<AuthProvider>().userData;
  String bgImage = '';
  if (userData.anualMembership != null && userData.anualMembership == 1) {
    bgImage = Assets.appPlatinumUserBgImage;
    // print('You are platinum user 😊 ${bgImage}');
  } else {
    bgImage = Assets.appUserBgImage;
  }

  return AssetImage('assets/images/$bgImage');
}

ImageProvider netImageProvider(String path,
        {BoxFit? fit, Color? color, double? width, double? height}) =>
    NetworkImage('$path');

//cached Network Image
Widget buildCachedNetworkImage(
  String image, {
  double? ph,
  double? pw,
  BoxFit? fit,
  String? placeholderImg,
  String? cacheFileName,
  Color? errorBgColor,
  Color? placeholderBgColor,
  Widget? errorStackChild,
  bool cache = true,
  double borderRadius = 0,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: CachedNetworkImage(
      imageUrl: image,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) => Center(
          child: Container(
              height: ph ?? 50,
              width: pw ?? 100,
              color: placeholderBgColor,
              child: Center(
                  child: CircularProgressIndicator(
                      color: appLogoColor.withOpacity(0.5))))),
      errorWidget: (context, url, error) => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                  padding: EdgeInsets.all(placeholderImg != null ? 0 : 10),
                  height: ph ?? 50,
                  width: pw ?? 100,
                  color: errorBgColor,
                  child: assetImages(
                    placeholderImg ?? Assets.appWebLogo,
                    fit: placeholderImg != null ? BoxFit.cover : null,
                  )),
              if (errorStackChild != null) errorStackChild
            ],
          ),
        ),
      ),
      cacheManager: cache
          ? CacheManager(Config(
              "${AppConstants.appName}${cacheFileName ?? image}",
              stalePeriod: const Duration(days: 30)))
          : null,
    ),
  );
}

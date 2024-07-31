import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DynamicLinksService {
  static Future<String> createDynamicLink(String longURL) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    debugPrint(packageInfo.packageName);
    String uriPrefix = 'https://wesh.page.link';

    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(longURL),
      uriPrefix: uriPrefix,
      androidParameters: AndroidParameters(packageName: packageInfo.packageName),
    );
    final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    final Uri shortUrl = dynamicLink.shortUrl;
    return shortUrl.toString();
  }

  // static void initDynamicLinks() async {
  //   final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();

  //   _handleDynamicLink(data);

  //   FirebaseDynamicLinks.instance.onLink(
  //       onSuccess: (PendingDynamicLinkData dynamicLink) async {
  //         _handleDynamicLink(dynamicLink);
  //       }, onError: (OnLinkErrorException e) async {
  //     debugPrint('onLinkError');
  //     debugPrint(e.message);
  //   });
  // }

  // static _handleDynamicLink(PendingDynamicLinkData data) async {
  //   final Uri deepLink = data?.link;

  //   if (deepLink == null) {
  //     return;
  //   }
  //   if (deepLink.pathSegments.contains('refer')) {
  //     var title = deepLink.queryParameters['code'];
  //     if (title != null) {
  //       debugPrint("refercode=$title");

  //     }
  //   }
}

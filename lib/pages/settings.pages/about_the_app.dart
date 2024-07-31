import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../../utils/constants.dart';

class AboutTheAppPage extends StatefulWidget {
  const AboutTheAppPage({super.key});

  @override
  State<AboutTheAppPage> createState() => _AboutTheAppPageState();
}

class _AboutTheAppPageState extends State<AboutTheAppPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: MorphingAppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
          heroTag: 'aboutTheAppPageAppBar',
          backgroundColor: Colors.white,
          titleSpacing: 0,
          elevation: 0,
          leading: IconButton(
            splashRadius: 0.06.sw,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
        ),
        body: Column(
          children: [
            // App info
            Expanded(
                child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(weshLogoPic))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    appName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  const Text(
                    'Version $appVersion',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )),

            // Redirect to Licences
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      TextButton(
                          child: const Text(
                            'Licences',
                          ),
                          onPressed: () {
                            // Redirect to Licences Page [Auto-generated]
                            showLicensePage(
                                context: context,
                                applicationName: appName,
                                applicationVersion: 'Version $appVersion',
                                applicationIcon: Container(
                                  margin: const EdgeInsets.all(22),
                                  height: 50,
                                  width: 50,
                                  decoration:
                                      const BoxDecoration(image: DecorationImage(image: AssetImage(weshFaviconPic))),
                                ));
                          }),
                      const SizedBox(
                        height: 7,
                      ),
                      Text(
                        '© $year $appName. All rights reserved.',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ));
  }
}

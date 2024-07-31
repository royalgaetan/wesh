// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import '../../models/user.dart' as usermodel;
import '../../models/bugreport.dart';
import '../../services/firestore.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/textformfield.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({super.key});

  @override
  State<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
  TextEditingController textController = TextEditingController();
  bool includeDeviceInformations = true;
  bool isLoading = false;
  int bugReportLimit = 500;
  ValueNotifier<usermodel.User?> currentUser = ValueNotifier<usermodel.User?>(null);

  dynamic platformVersion = '';
  dynamic imeiNo = '';
  dynamic modelName = '';
  dynamic manufacturer = '';
  dynamic apiLevel = '';
  dynamic deviceName = '';
  dynamic productName = '';
  dynamic cpuType = '';
  dynamic hardware = '';

  @override
  void initState() {
    //
    super.initState();
    //
    resetStatusAndNavigationBar();
  }

  resetStatusAndNavigationBar() {
    // Reset Status and Navigation bar Colors: if not as default
    setSuitableStatusBarColor(Colors.white);
    setSuitableNavigationBarColor(Colors.white);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Show back Status Bar: if not as default
    toggleStatusBar(true);
  }

  @override
  void dispose() {
    //
    super.dispose();
    textController.dispose();
  }

  sendBugReport() async {
    bool result = false;

    showFullPageLoader(context: context);

    // Fetch device infos
    await fetchDeviceInfo(includeDeviceInformations);

    // Modeling an bugReportModel
    Map<String, dynamic> bugReportToSend = BugReport(
      bugReportId: '',
      uid: currentUser.value!.id,
      name: currentUser.value!.name,
      content: textController.text,
      createdAt: DateTime.now(),
      downloadUrl: '',
      platformVersion: includeDeviceInformations ? platformVersion : '',
      imeiNo: includeDeviceInformations ? imeiNo : '',
      modelName: includeDeviceInformations ? modelName : '',
      manufacturer: includeDeviceInformations ? manufacturer : '',
      apiLevel: includeDeviceInformations ? apiLevel : 0,
      deviceName: includeDeviceInformations ? deviceName : '',
      productName: includeDeviceInformations ? productName : '',
      cpuType: includeDeviceInformations ? cpuType : '',
      hardware: includeDeviceInformations ? hardware : '',
    ).toJson();

    if (!mounted) return;
    result = await FirestoreMethods.sendBugReport(context, bugReportToSend);
    debugPrint('Bug report sent : $bugReportToSend');

    if (!mounted) return;
    Navigator.pop(
      context,
    );
    // Pop the Screen once profile updated
    if (result) {
      if (!mounted) return;
      Navigator.pop(context);

      if (!mounted) return;
      showSnackbar(context, 'Your report has been successfully sent!', kSuccessColor);
    }
  }

  Future fetchDeviceInfo(bool includeDeviceInformations) async {
    // Check if User has accepted to share his/her device information
    if (includeDeviceInformations) {
      // Check Phone permission
      if (await Permission.phone.request().isGranted) {
        try {
          platformVersion = await DeviceInformation.platformVersion;
          imeiNo = await DeviceInformation.deviceIMEINumber;
          modelName = await DeviceInformation.deviceModel;
          manufacturer = await DeviceInformation.deviceManufacturer;
          apiLevel = await DeviceInformation.apiLevel;
          deviceName = await DeviceInformation.deviceName;
          productName = await DeviceInformation.productName;
          cpuType = await DeviceInformation.cpuName;
          hardware = await DeviceInformation.hardware;
        } on PlatformException {
          platformVersion = 'Unable to retrieve platform version';
        }
        debugPrint('apiLevel : ${await DeviceInformation.apiLevel}');
      }
    }
  }

  handleCTAButton() async {
    // VIBRATE
    triggerVibration();

    // Send a bug report
    var isConnected = await InternetConnection.isConnected(context);
    if (isConnected) {
      debugPrint("Has connection : $isConnected");
      // Verify if Bug Report is not empty
      if (textController.text.isNotEmpty) {
        // Verify Bug Report Length
        if (textController.text.length <= bugReportLimit) {
          sendBugReport();
        } else {
          showSnackbar(context, 'Your report exceeds the $bugReportLimit character limit. Please shorten it.', null);
        }
      } else {
        showSnackbar(context, 'Please enter a description of your issue', null);
      }
    } else {
      debugPrint("Has connection : $isConnected");
      showSnackbar(context, 'Please check your internet connection', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
          heroTag: 'bugReportPageAppBar',
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
          title: const Text(
            'Report an issue',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            // CTA Button Create or Edit Forever
            GestureDetector(
              onTap: () {
                handleCTAButton();
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 5, 15, 10),
                child: Text(
                  'Send',
                  style: TextStyle(fontSize: 16.sp, color: kSecondColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 5, left: 10, right: 10),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            isLoading
                ? Container(
                    padding: const EdgeInsets.all(50),
                    height: 300,
                    child: const Center(child: CupertinoActivityIndicator()),
                  )
                : SingleChildScrollView(
                    child: StreamBuilder<usermodel.User?>(
                        stream: FirestoreMethods.getUserById(FirebaseAuth.instance.currentUser!.uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            // Update current user
                            currentUser.value = snapshot.data;

                            return Column(
                              children: [
                                // Bug report add content field
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: BuildTextFormField(
                                    controller: textController,
                                    hintText: 'Describe the issue (max $bugReportLimit characters)...',
                                    icon: Icon(Icons.bug_report_outlined, color: Colors.grey.shade600),
                                    maxLines: 30,
                                    minLines: 3,
                                    maxLength: bugReportLimit,
                                    fontSize: 13.sp,
                                    inputBorder: InputBorder.none,
                                    validateFn: (text) {
                                      return null;
                                    },
                                    onChanged: (text) async {
                                      return;
                                    },
                                  ),
                                ),

                                const BuildDivider(),

                                // Include Device informations: User consentment
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      alignment: Alignment.center,
                                      child: Icon(FontAwesomeIcons.mobile, size: 18.sp, color: Colors.grey.shade600),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.only(left: 5, right: 5),
                                        child: Wrap(
                                          children: [
                                            Text(
                                              'Include device information',
                                              style: TextStyle(color: Colors.black87, fontSize: 13.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: includeDeviceInformations,
                                      onChanged: (bool value) {
                                        setState(() {
                                          includeDeviceInformations = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 5,
                                ),
                                // Heads-up
                                Padding(
                                  padding: const EdgeInsets.only(right: 10, bottom: 5, top: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        alignment: Alignment.center,
                                        child:
                                            Icon(FontAwesomeIcons.circleInfo, size: 18.sp, color: Colors.grey.shade400),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.only(left: 5, right: 5),
                                          child: Wrap(
                                            children: [
                                              Text(
                                                'Providing device information helps us quickly understand and resolve your issue. Rest assured, it will never be shared',
                                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }

                          if (snapshot.hasError) {
                            // Handle error
                            debugPrint('error: ${snapshot.error}');
                            return const Center(
                              child: Text('An error occured!', style: TextStyle(color: Colors.white)),
                            );
                          }

                          // Display CircularProgressIndicator
                          return const Center(
                            child:
                                RepaintBoundary(child: CupertinoActivityIndicator(color: Colors.white60, radius: 15)),
                          );
                        }),
                  ),
          ],
        ),
      ),
    );
  }
}

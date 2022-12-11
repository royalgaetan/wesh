import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import '../../models/user.dart' as UserModel;
import '../../models/bugreport.dart';
import '../../providers/user.provider.dart';
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
  ValueNotifier<UserModel.User?> currentUser = ValueNotifier<UserModel.User?>(null);

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
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    textController.dispose();
  }

  sendBugReport() async {
    bool result = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Fetch device infos
    await fetchDeviceInfo(includeDeviceInformations);

    // Modeling an bugReportModel
    Map<String, Object?> bugReportToSend = BugReport(
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

    // ignore: use_build_context_synchronously
    result = await FirestoreMethods().sendBugReport(context, bugReportToSend);
    debugPrint('Bug report sent : $bugReportToSend');

    // ignore: use_build_context_synchronously
    Navigator.pop(
      context,
    );
    // Pop the Screen once profile updated
    if (result) {
      Navigator.pop(context);

      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Votre rapport à bien été envoyé !', kSuccessColor);
    }
  }

  Future fetchDeviceInfo(bool includeDeviceInformations) async {
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
        platformVersion = 'Impossible d\'obtenir la version de la plate forme';
      }
      print('apiLevel : ${await DeviceInformation.apiLevel}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
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
          'Reporter un problème',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          isLoading
              ? LinearProgressIndicator(
                  backgroundColor: kSecondColor.withOpacity(0.2),
                  color: kSecondColor,
                )
              : Container(),
          StreamBuilder<UserModel.User?>(
              stream: Provider.of<UserProvider>(context).getCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  // Update current user
                  currentUser.value = snapshot.data;

                  return Column(
                    children: [
                      // Bug report add content field
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: buildTextFormField(
                          controller: textController,
                          hintText:
                              'Dites nous qu\'est-ce qui s\'est produit ou qu\'est-ce qui ne fonctionne pas correctement (en moins de 500 caractères)',
                          icon: const Icon(Icons.edit_note_rounded),
                          maxLines: 10,
                          maxLength: 500,
                          inputBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kSecondColor)),
                          validateFn: (text) {
                            return null;
                          },
                          onChanged: (text) async {
                            return;
                          },
                        ),
                      ),

                      // Include Device informations : user consentment
                      const SizedBox(
                        height: 20,
                      ),
                      SwitchListTile(
                        title: Text(
                          'Inclure les informations sur l\'appareil',
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                        subtitle: Text(
                          'Les informations sur votre appareil seront inclus dans votre rapport pour nous aider à mieux comprendre et resoudre votre problème',
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                        value: includeDeviceInformations,
                        onChanged: (bool value) {
                          setState(() {
                            includeDeviceInformations = value;
                          });
                        },
                        secondary: const Icon(Icons.perm_device_information_rounded),
                      ),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  // Handle error
                  debugPrint('error: ${snapshot.error}');
                  return const Center(
                    child: Text('Une erreur s\'est produite', style: TextStyle(color: Colors.white)),
                  );
                }

                // Display CircularProgressIndicator
                return const Center(
                  child: CupertinoActivityIndicator(color: Colors.white60, radius: 15),
                );
              }),
        ],
      ),
      floatingActionButton:
          // [ACTION BUTTON] Add Event Button
          FloatingActionButton.extended(
        foregroundColor: Colors.white,
        backgroundColor: kSecondColor,
        label: const Text(
          'Envoyer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          // VIBRATE
          triggerVibration();

          // Send a bug report

          setState(() {
            isLoading = true;
          });
          var isConnected = await InternetConnection().isConnected(context);
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          if (isConnected) {
            debugPrint("Has connection : $isConnected");
            // CONTINUE
            if (textController.text.isNotEmpty) {
              sendBugReport();
            } else {
              // ignore: use_build_context_synchronously
              showSnackbar(context, 'Veuillez entrer une description de votre problème', null);
            }
          } else {
            debugPrint("Has connection : $isConnected");
            // ignore: use_build_context_synchronously
            showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
          }
        },
      ),
    );
  }
}

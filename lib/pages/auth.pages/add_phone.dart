import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/auth.pages/otp.dart';
import '../../services/auth.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/button.dart';

class AddPhonePage extends StatefulWidget {
  final bool isUpdatingPhoneNumber;

  const AddPhonePage({super.key, required this.isUpdatingPhoneNumber, e});

  @override
  State<AddPhonePage> createState() => _AddPhonePageState();
}

class _AddPhonePageState extends State<AddPhonePage> {
  TextEditingController phoneController = TextEditingController();
  bool isPageLoading = false;
  String phoneCode = '242';
  String regionCode = 'CG';
  String countryName = '';

  @override
  void dispose() {
    //
    super.dispose();

    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 0.08.sh),
        child: MorphingAppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
          heroTag: 'addPhonePageAppBar',
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            splashRadius: 0.06.sw,
            onPressed: () {
              // PUSH BACK STEPS OR POP SCREEN
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          isPageLoading
              ? LinearProgressIndicator(
                  backgroundColor: kSecondColor.withOpacity(0.2),
                  color: kSecondColor,
                )
              : Container(),
          Center(
            child: ListView(
              padding: EdgeInsets.fromLTRB(0.1.sw, 0.1.sw, 0.1.sw, 0.1.sw),
              shrinkWrap: true,
              reverse: true,
              children: [
                Column(
                  children: [
                    Text(
                      widget.isUpdatingPhoneNumber
                          ? 'Ajouter le numéro de téléphone'
                          : 'Ajoutez votre numéro de téléphone',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
                    ),
                  ],
                ),
                SizedBox(height: 0.12.sw),

                // Phone Field Input
                Container(
                  decoration: BoxDecoration(
                    color: kGreyColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      FittedBox(
                        child: InkWell(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              showPhoneCode: true,
                              countryListTheme: CountryListThemeData(
                                flagSize: 25,
                                backgroundColor: Colors.white,
                                textStyle: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
                                bottomSheetHeight: MediaQuery.of(context).size.height / 1.2,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                ),
                                //Optional. Styles the search field.
                                inputDecoration: InputDecoration(
                                  filled: true,
                                  fillColor: kGreyColor,
                                  prefixIcon: const Icon(Icons.search),
                                  prefixIconColor: kSecondColor,
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent, width: 0),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent, width: 0),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: kGreyColor, width: 0),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.transparent, width: 0),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  contentPadding: const EdgeInsets.all(0),
                                  hintText: 'Recherchez un pays',
                                  hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                                ),
                              ),
                              favorite: ['CG'],
                              onSelect: (Country country) {
                                setState(() {
                                  phoneCode = country.phoneCode;
                                  regionCode = country.countryCode;
                                });
                                debugPrint(
                                  'Selected phone Code: ${country.phoneCode} & Selected region : ${country.countryCode}, & Selected country Name : ${country.name}',
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                            child: Text('+$phoneCode'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                          ],
                          keyboardType: TextInputType.phone,
                          controller: phoneController,
                          decoration: InputDecoration(
                              hintText: 'Numéro de téléphone',
                              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                              contentPadding: EdgeInsets.all(0.04.sw),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 0.12.sw),

                // Button Action : Username checked
                Button(
                  height: 0.12.sw,
                  width: double.infinity,
                  text: 'Suivant',
                  color: kSecondColor,
                  onTap: () async {
                    setState(() {
                      isPageLoading = true;
                    });
                    var isConnected = await InternetConnection.isConnected(context);
                    setState(() {
                      isPageLoading = false;
                    });
                    if (isConnected) {
                      // Check phone number
                      if (phoneController.text.isNotEmpty) {
                        bool? isPhoneValid = await isPhoneNumberValid(
                          // ignore: use_build_context_synchronously
                          context: context,
                          countryName: countryName,
                          phoneCode: phoneCode,
                          phoneContent: phoneController.text,
                          regionCode: regionCode,
                        );

                        if (isPhoneValid) {
                          // UPDATE PHONE NUMBER
                          if (widget.isUpdatingPhoneNumber) {
                            bool isUserExisting =
                                await AuthMethods.checkUserWithPhoneExistenceInDb('+$phoneCode${phoneController.text}');
                            if (isUserExisting == true) {
                              // ignore: use_build_context_synchronously
                              showSnackbar(context, 'Ce numéro est déjà pris...', null);
                              return;
                            } else {
                              Navigator.push(
                                // ignore: use_build_context_synchronously
                                context,
                                SwipeablePageRoute(
                                  builder: (_) => const OTPverificationPage(
                                    authType: 'updatePhoneNumber',
                                  ),
                                ),
                              );
                            }
                          }

                          // LOGIN WITH PHONE NUMBER
                          else {
                            bool isUserExisting =
                                await AuthMethods.checkUserWithPhoneExistenceInDb('+$phoneCode${phoneController.text}');
                            log('isUserExisting: $isUserExisting');
                            if (isUserExisting == false) {
                              // ignore: use_build_context_synchronously
                              showSnackbar(context, 'Aucun compte n\'existe avec numéro...', null);
                              return;
                            } else {
                              Navigator.push(
                                // ignore: use_build_context_synchronously
                                context,
                                SwipeablePageRoute(
                                  builder: (_) => const OTPverificationPage(
                                    authType: 'login',
                                  ),
                                ),
                              );
                            }
                          }
                        } else {
                          // ignore: use_build_context_synchronously
                          showSnackbar(context, 'Votre numéro est incorrect !', null);
                        }
                      } else {
                        // ignore: use_build_context_synchronously
                        showSnackbar(context, 'Veuillez entrer un numéro...', null);
                      }

                      debugPrint("Has connection : $isConnected");
                    } else {
                      debugPrint("Has connection : $isConnected");
                      // ignore: use_build_context_synchronously
                      showSnackbar(context, 'Please check your internet connection', null);
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                )
              ].reversed.toList(),
            ),
          ),
        ],
      ),
    );
  }
}

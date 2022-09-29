import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_number/phone_number.dart';
import 'package:wesh/pages/auth.pages/otp.dart';
import 'package:wesh/services/sharedpreferences.service.dart';
import '../../services/internet_connection_checher.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/button.dart';
import '../../widgets/textfieldcontainer.dart';

class AddPhonePage extends StatefulWidget {
  AddPhonePage({Key? key}) : super(key: key);

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
    // TODO: implement dispose
    super.dispose();

    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          splashRadius: 25,
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ListView(
                shrinkWrap: true,
                reverse: true,
                children: [
                  Column(
                    children: const [
                      Text(
                        'Ajoutez votre numéro de téléphone',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),

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
                                  textStyle: const TextStyle(
                                      fontSize: 16, color: Colors.blueGrey),
                                  bottomSheetHeight: 600,
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
                                      borderSide: const BorderSide(
                                          color: Colors.transparent, width: 0),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.transparent, width: 0),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: kGreyColor, width: 0),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    hintText: 'Recherchez un pays',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 18),
                                  ),
                                ),
                                favorite: ['CG'],
                                onSelect: (Country country) {
                                  setState(() {
                                    phoneCode = country.phoneCode;
                                    regionCode = country.countryCode;
                                  });
                                  print(
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
                            keyboardType: TextInputType.phone,
                            controller: phoneController,
                            decoration: const InputDecoration(
                                hintText: 'Numéro de téléphone',
                                contentPadding: EdgeInsets.all(20),
                                border: InputBorder.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 27,
                  ),

                  // Button Action : Username checked
                  Button(
                    height: 50,
                    width: double.infinity,
                    text: 'Suivant',
                    color: kSecondColor,
                    onTap: () async {
                      setState(() {
                        isPageLoading = true;
                      });
                      var isConnected =
                          await InternetConnection().isConnected(context);
                      setState(() {
                        isPageLoading = false;
                      });
                      if (isConnected) {
                        // Check phone number

                        bool isPhoneValid = await isPhoneNumberValid(
                          context: context,
                          countryName: countryName,
                          phoneCode: phoneCode,
                          phoneContent: phoneController.text,
                          regionCode: regionCode,
                        );

                        if (isPhoneValid) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OTPverificationPage(
                                authType: 'login',
                              ),
                            ),
                          );
                        } else {
                          showSnackbar(
                              context, 'Votre numéro est incorrect !', null);
                        }

                        print("Has connection : $isConnected");
                      } else {
                        print("Has connection : $isConnected");
                        showSnackbar(context,
                            'Veuillez vérifier votre connexion internet', null);
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ].reversed.toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

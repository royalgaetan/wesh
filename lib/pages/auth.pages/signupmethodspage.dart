import 'package:country_picker/country_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wesh/pages/auth.pages/createpassword_and_confirm.dart';
import 'package:wesh/pages/auth.pages/otp.dart';
import 'package:wesh/services/sharedpreferences.service.dart';

import '../../services/auth.methods.dart';
import '../../services/internet_connection_checher.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';
import '../../widgets/button.dart';
import '../../widgets/textfieldcontainer.dart';
import '../startPage.dart';

class SignUpMethodPage extends StatefulWidget {
  SignUpMethodPage({Key? key}) : super(key: key);

  @override
  State<SignUpMethodPage> createState() => _CheckUsernameState();
}

class _CheckUsernameState extends State<SignUpMethodPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool isPageLoading = false;
  String phoneCode = '242';
  String regionCode = 'CG';
  String countryName = '';

  late String authMethod;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  checkSignUpMethod(context) async {
    setState(() {
      isPageLoading = true;
    });

    // IF method == Phone
    if (_tabController.index == 0) {
      if (phoneController.text.isNotEmpty) {
        setState(() {
          isPageLoading = true;
        });
        var isConnected = await InternetConnection().isConnected(context);
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
            //  Check if the phone is used
            bool isPhoneNumberUsed = await checkIfPhoneNumberInUse(
                context, '+${phoneCode}${phoneController.text}');

            if (isPhoneNumberUsed == false) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OTPverificationPage(
                    authType: 'signup',
                  ),
                ),
              );
            } else {
              showSnackbar(context, 'Ce numéro est déjà pris', null);
            }
          } else {
            showSnackbar(context, 'Votre numéro est incorrect !', null);
          }

          print("Has connection : $isConnected");
        } else {
          print("Has connection : $isConnected");
          showSnackbar(
              context, 'Veuillez vérifier votre connexion internet', null);
        }
      } else {
        return showSnackbar(
            context, 'Veuillez entrer un numéro de téléphone valide', null);
      }
    }

    if (_tabController.index == 1) {
      if (emailController.text.isEmpty ||
          !EmailValidator.validate(emailController.text)) {
        setState(() {
          isPageLoading = false;
        });
        return showSnackbar(
            context, 'Veuillez entrer une adresse email valide', null);
      }

      // Returns true if email address is available

      bool isEmailUsed = await checkIfEmailInUse(context, emailController.text);

      if (isEmailUsed == true) {
        setState(() {
          isPageLoading = false;
        });
        return showSnackbar(
            context, 'Cette adresse email est déjà utilisée', null);
      }
      // Go to Sign Up OTPverificationPage: Email Verify
      UserSimplePreferences.setEmail(emailController.text);
      setState(() {
        isPageLoading = false;
      });

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      emailController.clear();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePassword(),
        ),
      );
    }
  }

  // IF method == Google
  continueWithGoogle(context) async {
    setState(() {
      isPageLoading = true;
    });
    var isConnected = await InternetConnection().isConnected(context);
    setState(() {
      isPageLoading = false;
    });
    if (isConnected) {
      // Continue with Google

      print("Has connection : $isConnected");

      List isAllowedToContinue =
          await AuthMethods().continueWithGoogle(context, 'signup');

      print("isAllowedToContinue: $isAllowedToContinue");

      if (isAllowedToContinue[0]) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        // Redirect to StartPage
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => StartPage(),
            ),
            (route) => false);
      } else {
        showSnackbar(context, isAllowedToContinue[1], null);
      }
    } else {
      print("Has connection : $isConnected");
      showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
    }
  }

  // IF method == Facebook
  continueWithFacebook(context) async {
    setState(() {
      isPageLoading = true;
    });
    var isConnected = await InternetConnection().isConnected(context);
    setState(() {
      isPageLoading = false;
    });
    if (isConnected) {
      // Continue with Google

      print("Has connection : $isConnected");

      List isAllowedToContinue =
          await AuthMethods().continueWithFacebook(context, 'signup');

      print("isAllowedToContinue: $isAllowedToContinue");

      if (isAllowedToContinue[0]) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        // Redirect to StartPage
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => StartPage(),
            ),
            (route) => false);
      } else {
        showSnackbar(context, isAllowedToContinue[1], null);
      }
    } else {
      print("Has connection : $isConnected");
      showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
    }
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
                  Column(children: const [
                    Text(
                      'Continuer avec...',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ]),

                  // Tab Bar
                  TabBar(
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        text: 'Numéro de téléphone',
                      ),
                      Tab(
                        text: 'Email',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // Tab Bar View
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    height: 80,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        //  Phone Field

                        // Phone Field Input
                        Container(
                          decoration: BoxDecoration(
                            color: kGreyColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              // Pick  country
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
                                            fontSize: 16,
                                            color: Colors.blueGrey),
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
                                                color: Colors.transparent,
                                                width: 0),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.transparent,
                                                width: 0),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: kGreyColor, width: 0),
                                            borderRadius:
                                                BorderRadius.circular(14),
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
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 10, 0, 10),
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

                        // Email Field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextformContainer(
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  hintText: 'Email',
                                  contentPadding: EdgeInsets.all(20),
                                  border: InputBorder.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Button : SIGN UP BUTTON or Login
                  const SizedBox(
                    height: 40,
                  ),
                  Column(
                    children: [
                      // Login Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Button(
                          height: 50,
                          width: double.infinity,
                          text: 'Continuer',
                          color: kSecondColor,
                          onTap: () {
                            // Check Sign Up Method --> Continue
                            checkSignUpMethod(context);
                          },
                        ),
                      ),
                    ],
                  ),

                  // Divider
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
                    child: buildDividerWithLabel(label: 'ou'),
                  ),

                  // Other Sign Up Methods : Google, Facebook
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          // Sign Up with Google
                          continueWithGoogle(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            googleLogo,
                            height: 29,
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                      InkWell(
                        onTap: () {
                          // Sign Up with Facebook
                          continueWithFacebook(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            facebookLogo,
                            height: 34,
                            color: Color(0xFF1977F3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ].reversed.toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

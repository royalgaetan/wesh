import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wesh/pages/settings.pages/add_email_and_password_page.dart';
import 'package:wesh/pages/settings.pages/change_email_or_password_page.dart';
import 'package:wesh/pages/settings.pages/payment_activity_page.dart';
import 'package:wesh/services/firestore.methods.dart';
import '../../services/auth.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../services/sharedpreferences.service.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';
import '../../widgets/setting_card.dart';
import '../auth.pages/add_phone.dart';
import 'login_activity_page.dart';
import '../../models/user.dart' as usermodel;

class AccountSecuritySettingsPage extends StatefulWidget {
  const AccountSecuritySettingsPage({super.key});

  @override
  State<AccountSecuritySettingsPage> createState() => _AccountSecuritySettingsPageState();
}

class _AccountSecuritySettingsPageState extends State<AccountSecuritySettingsPage> {
  bool hasPasswordProvider = false;
  String? passwordProviderEmail;
  String? googleAccountEmail;
  String? facebookAccountName;
  ValueNotifier<usermodel.User?> currentUser = ValueNotifier<usermodel.User?>(null);
  @override
  void initState() {
    //
    super.initState();

    // Has currentUser Password Provider ?
    fetchPasswordProviderInfo();

    // Fetch Google Account Email
    fetchGoogleAccountEmail();

    // Fetch Facebook Account Email
    fetchFacebookAccountEmail();

    // REDIRECT
    redirectToAddEmailandPasswordPage();
    redirectToChangeEmailandPasswordPage();

    debugPrint('User Firebase is: ${FirebaseAuth.instance.currentUser!}');
    // getDd();
  }

  fetchPasswordProviderInfo() {
    List<UserInfo> passwordProvider =
        FirebaseAuth.instance.currentUser!.providerData.where((element) => element.providerId == 'password').toList();
    if (passwordProvider.isNotEmpty) {
      setState(() {
        hasPasswordProvider = true;
        passwordProviderEmail = passwordProvider[0].email;
      });
    } else {
      setState(() {
        hasPasswordProvider = false;
        passwordProviderEmail = null;
      });
    }
  }

  fetchGoogleAccountEmail() {
    List<UserInfo> googleProvider =
        FirebaseAuth.instance.currentUser!.providerData.where((element) => element.providerId == 'google.com').toList();
    if (googleProvider.isNotEmpty) {
      setState(() {
        googleAccountEmail = googleProvider[0].email;
      });
    }
  }

  fetchFacebookAccountEmail() {
    List<UserInfo> facebookProvider = FirebaseAuth.instance.currentUser!.providerData
        .where((element) => element.providerId == 'facebook.com')
        .toList();
    if (facebookProvider.isNotEmpty) {
      setState(() {
        facebookAccountName = facebookProvider[0].displayName;
      });
    }
  }

  Future redirectToAddEmailandPasswordPage() async {
    var valueToRedirect = UserSimplePreferences.getRedirectToAddEmailandPasswordPageValue() ?? false;
    debugPrint("Redirect to Add Email and Password Page [ACCOUNT SECURITY PAGE]: $valueToRedirect ");
    if (valueToRedirect) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => const AddEmailandPasswordPage(),
          ),
        );
      });
    }
  }

  Future redirectToChangeEmailandPasswordPage() async {
    var valueToRedirect1 = UserSimplePreferences.getRedirectToAddEmailPageValue() ?? false;
    debugPrint("Redirect to Add Email Page [ACCOUNT SECURITY PAGE]: $valueToRedirect1");
    if (valueToRedirect1) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => const ChangeEmailOrPasswordPage(),
          ),
        );
      });
    }

    //
    var valueToRedirect2 = UserSimplePreferences.getRedirectToUpdatePasswordPageValue() ?? false;
    debugPrint("Redirect to Update Password Page [ACCOUNT SECURITY PAGE]: $valueToRedirect2");
    if (valueToRedirect2) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => const ChangeEmailOrPasswordPage(),
          ),
        );
      });
    }
  }

  Future getDd() async {
    User user = FirebaseAuth.instance.currentUser!;
    List userSignInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(user.email!);

    debugPrint('User SignInMthods are: $userSignInMethods');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        heroTag: 'accountSecuritySettingsPageAppBar',
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
          'Sécurité',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: VisibilityDetector(
        key: const Key("security settings"),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction == 1.0) {
            //  Update UI
            fetchPasswordProviderInfo();
            debugPrint("${info.visibleFraction} of my widget is visible");
          }
        },
        child: SingleChildScrollView(
          child: StreamBuilder<usermodel.User?>(
              stream: FirestoreMethods.getUserById(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  // Update current user
                  currentUser.value = snapshot.data;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Login Activity
                      SettingCard(
                        onTap: () {
                          // Redirect to Login Activity Page
                          Navigator.push(
                              context,
                              SwipeablePageRoute(
                                builder: (context) => const LoginActivityPage(),
                              ));
                        },
                        trailing: Container(),
                        leading: CircleAvatar(
                          radius: 0.08.sw,
                          backgroundColor: kGreyColor,
                          child: Icon(
                            FontAwesomeIcons.locationDot,
                            color: Colors.black87.withOpacity(.7),
                            size: 20.sp,
                          ),
                        ),
                        settingTitle: 'Votre activité (Connexion)',
                        settingSubTitle: '',
                      ),

                      // Payment Activity
                      SettingCard(
                        onTap: () {
                          // Redirect to Payment Activity Page
                          Navigator.push(
                              context,
                              SwipeablePageRoute(
                                builder: (context) => const PaymentActivityPage(),
                              ));
                        },
                        trailing: Container(),
                        leading: CircleAvatar(
                          radius: 0.08.sw,
                          backgroundColor: kGreyColor,
                          child: Icon(
                            FontAwesomeIcons.moneyBill1Wave,
                            color: Colors.black87.withOpacity(.7),
                            size: 20.sp,
                          ),
                        ),
                        settingTitle: 'Vos paiements (et receptions)',
                        settingSubTitle: '',
                      ),

                      // Divider
                      const buildDivider(),

                      // Email && Password
                      SettingCard(
                        onTap: () async {
                          if (hasPasswordProvider) {
                            //  Redirect to : Change Email/Password
                            Navigator.push(
                                context,
                                SwipeablePageRoute(
                                  builder: (context) => const ChangeEmailOrPasswordPage(),
                                ));
                          } else {
                            // OR Redirect to : Add Email and Password
                            Navigator.push(
                                context,
                                SwipeablePageRoute(
                                  builder: (context) => const AddEmailandPasswordPage(),
                                ));
                          }
                        },
                        leading: CircleAvatar(
                          radius: 0.08.sw,
                          backgroundColor: kGreyColor,
                          child: Icon(
                            FontAwesomeIcons.key,
                            color: Colors.black87.withOpacity(.7),
                            size: 20.sp,
                          ),
                        ),
                        settingTitle: 'Email et mot de passe',
                        settingSubTitle: hasPasswordProvider
                            ? 'Modifier votre email ou mot de passe'
                            : 'Appuyer pour attacher votre email et mot de passe',
                        settingSubTitle2: hasPasswordProvider
                            ? RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  text: 'Votre email actuel : ',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black54,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: passwordProviderEmail ?? "",
                                        style: const TextStyle(color: kSecondColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            : Container(),
                        trailing: hasPasswordProvider
                            ? CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                                borderRadius: BorderRadius.circular(10),
                                child: const Icon(
                                  FontAwesomeIcons.linkSlash,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                onPressed: () async {
                                  // VIBRATE
                                  triggerVibration();

                                  // Unlink Password Provider

                                  // Show Modal Decision
                                  List deleteDecision = await showModalDecision(
                                    context: context,
                                    header: 'Détacher votre email',
                                    content:
                                        'Vous ne pourrez plus vous connecter à votre compte à partir de cette adresse email si vous la détachez. Êtes-vous sûr de vouloir continuer ?',
                                    firstButton: 'Annuler',
                                    secondButton: 'Détacher',
                                  );

                                  if (deleteDecision[0] == true) {
                                    // Detach Google account
                                    // ignore: use_build_context_synchronously
                                    bool result = await AuthMethods.unlinkSpecificProvider(context, 'password');

                                    fetchPasswordProviderInfo();
                                  }
                                },
                              )
                            : Container(),
                      ),

                      // Phone Number
                      SettingCard(
                        onTap: () {
                          //  Phone Update
                          Navigator.push(
                              context,
                              SwipeablePageRoute(
                                builder: (context) => const AddPhonePage(
                                  isUpdatingPhoneNumber: true,
                                ),
                              ));
                        },
                        leading: CircleAvatar(
                          radius: 0.08.sw,
                          backgroundColor: kGreyColor,
                          child: Icon(
                            FontAwesomeIcons.phone,
                            color: Colors.black87.withOpacity(.7),
                            size: 20.sp,
                          ),
                        ),
                        settingTitle: 'Numéro de téléphone',
                        settingSubTitle: currentUser.value!.phone.isNotEmpty
                            ? 'Appuyer pour changer de numéro de téléphone'
                            : 'Appuyer pour ajouter un numéro de téléphone',
                        settingSubTitle2: currentUser.value!.phone.isNotEmpty
                            ? RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  text: 'Votre numéro actuel : ',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black54,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: currentUser.value!.phone,
                                        style: const TextStyle(color: kSecondColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            : Container(),
                        trailing: currentUser.value!.phone.isNotEmpty
                            ? CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                                borderRadius: BorderRadius.circular(10),
                                child: const Icon(
                                  FontAwesomeIcons.linkSlash,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                onPressed: () async {
                                  // VIBRATE
                                  triggerVibration();

                                  // Unlink Phone Provider

                                  // Show Modal Decision
                                  List deleteDecision = await showModalDecision(
                                    context: context,
                                    header: 'Détacher votre numéro de téléphone',
                                    content:
                                        'Vous ne pourrez plus vous connecter à votre compte à partir de votre numéro de téléphone si vous le détachez. Êtes-vous sûr de vouloir continuer ?',
                                    firstButton: 'Annuler',
                                    secondButton: 'Détacher',
                                  );

                                  if (deleteDecision[0] == true) {
                                    // Detach Phone number
                                    // ignore: use_build_context_synchronously
                                    await AuthMethods.unlinkSpecificProvider(context, 'phone');
                                  }
                                },
                              )
                            : Container(),
                      ),

                      // Google Account
                      SettingCard(
                        onTap: () async {
                          // Redirect to
                          //
                          showFullPageLoader(context: context, color: Colors.white);
                          //

                          var isConnected = await InternetConnection.isConnected(context);
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                          if (isConnected) {
                            // ignore: use_build_context_synchronously
                            List result = await AuthMethods.linkCredentialsbyGoogleAccount(context);
                            setState(() {
                              googleAccountEmail = result[1];
                            });
                            debugPrint("Update googleID [isAllowedToContinue]: ${result[0]}");
                            debugPrint("Has connection : $isConnected");
                          } else {
                            debugPrint("Has connection : $isConnected");
                            // ignore: use_build_context_synchronously
                            showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
                          }
                        },
                        leading: CircleAvatar(
                          radius: 0.08.sw,
                          backgroundColor: kGreyColor,
                          child: Icon(
                            FontAwesomeIcons.google,
                            color: Colors.black87.withOpacity(.7),
                            size: 20.sp,
                          ),
                        ),
                        settingTitle: 'Compte Google associé',
                        settingSubTitle: currentUser.value!.googleID.isNotEmpty
                            ? 'Appuyer pour détacher votre compte Google'
                            : 'Appuyer pour attacher votre compte Google',
                        settingSubTitle2: currentUser.value!.googleID.isNotEmpty
                            ? RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  text: 'Votre compte Google : ',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black54,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: googleAccountEmail ?? "",
                                        style: const TextStyle(color: kSecondColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            : Container(),
                        trailing: currentUser.value!.googleID.isNotEmpty
                            ? CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                                borderRadius: BorderRadius.circular(10),
                                child: const Icon(
                                  FontAwesomeIcons.linkSlash,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                onPressed: () async {
                                  // VIBRATE
                                  triggerVibration();

                                  // Unlink Google Provider

                                  // Show Modal Decision
                                  List deleteDecision = await showModalDecision(
                                    context: context,
                                    header: 'Détacher votre compte Google',
                                    content:
                                        'Vous ne pourrez plus vous connecter à votre compte à partir de ce compte Google si vous le détachez. Êtes-vous sûr de vouloir continuer ?',
                                    firstButton: 'Annuler',
                                    secondButton: 'Détacher',
                                  );

                                  if (deleteDecision[0] == true) {
                                    // Detach Google account
                                    // ignore: use_build_context_synchronously
                                    await AuthMethods.unlinkSpecificProvider(context, 'google.com');
                                  }
                                },
                              )
                            : Container(),
                      ),

                      //  Facebook account
                      SettingCard(
                        onTap: () async {
                          // Redirect to
                          List result = await AuthMethods.linkCredentialsbyFacebookAccount(context);
                          setState(() {
                            facebookAccountName = result[1];
                          });
                          debugPrint("Update facebookID [isAllowedToContinue]: ${result[0]}");
                        },
                        leading: CircleAvatar(
                          radius: 0.08.sw,
                          backgroundColor: kGreyColor,
                          child: Icon(
                            FontAwesomeIcons.facebook,
                            color: Colors.black87.withOpacity(.7),
                            size: 20.sp,
                          ),
                        ),
                        settingTitle: 'Compte Facebook associé',
                        settingSubTitle: currentUser.value!.facebookID.isNotEmpty
                            ? 'Appuyer pour détacher votre compte Facebook'
                            : 'Appuyer pour attacher votre compte Facebook',
                        settingSubTitle2: currentUser.value!.facebookID.isNotEmpty
                            ? RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  text: 'Votre compte Facebook : ',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black54,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: facebookAccountName ?? "",
                                        style: const TextStyle(color: kSecondColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            : Container(),
                        trailing: currentUser.value!.facebookID.isNotEmpty
                            ? CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                                borderRadius: BorderRadius.circular(10),
                                child: const Icon(
                                  FontAwesomeIcons.linkSlash,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                onPressed: () async {
                                  // VIBRATE
                                  triggerVibration();

                                  // Unlink Facebook Provider

                                  // Show Modal Decision
                                  List deleteDecision = await showModalDecision(
                                    context: context,
                                    header: 'Détacher votre compte Facebook',
                                    content:
                                        'Vous ne pourrez plus vous connecter à votre compte à partir de ce compte Facebook si vous le détachez. Êtes-vous sûr de vouloir continuer ?',
                                    firstButton: 'Annuler',
                                    secondButton: 'Détacher',
                                  );

                                  if (deleteDecision[0] == true) {
                                    // Detach Facebook account
                                    // ignore: use_build_context_synchronously
                                    await AuthMethods.unlinkSpecificProvider(context, 'facebook.com');
                                  }
                                },
                              )
                            : Container(),
                      ),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  // Handle error
                  debugPrint('error: ${snapshot.error}');
                  return const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: Text('Une erreur s\'est produite', style: TextStyle(color: Colors.black)),
                    ),
                  );
                }

                // Display CircularProgressIndicator
                return Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Center(
                    child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

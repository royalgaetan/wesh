import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/services/sharedpreferences.service.dart';
import '../models/user.dart' as UserModel;
import '../pages/login.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  FirebaseAuth auth = FirebaseAuth.instance;

  //////////////////  CHECKERS
  //////////////////
  //////////////////

  // Check is User exist in DB
  Future<bool> checkUserExistenceInDb(uid) async {
    UserModel.User? isUserExisting = await FirestoreMethods().getUser(uid);

    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return true;
    }
    // User doesn't exist
    return false;
  }

  // Check is User with email exist in DB
  Future<bool> checkUserWithEmailExistenceInDb(email) async {
    try {
      var finalValue;
      // Fetch all email number in DB
      final QuerySnapshot result =
          await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();

      final List<DocumentSnapshot> documents = result.docs;

      if (documents.length > 0) {
        //exists
        finalValue = true;
      } else {
        //not exists
        finalValue = false;
      }

      if (finalValue) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      // Handle error
      // ...
      return true;
    }
  }

  // Check is User with email exist in DB
  Future<bool> checkUserWithPhoneExistenceInDb(phone) async {
    try {
      var finalValue;
      // Fetch all phone numbers in DB
      final QuerySnapshot result =
          await FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: phone).get();

      final List<DocumentSnapshot> documents = result.docs;

      if (documents.length > 0) {
        //exists
        finalValue = true;
      } else {
        //not exists
        finalValue = false;
      }

      if (finalValue) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      // Handle error
      // ...
      return true;
    }
  }

  // Check is User with GoogleID exist in DB
  Future<bool> checkUserWithGoogleIDExistenceInDb(googleID) async {
    try {
      var finalValue;
      // Fetch all email number in DB
      final QuerySnapshot result =
          await FirebaseFirestore.instance.collection('users').where('googleID', isEqualTo: googleID).get();

      final List<DocumentSnapshot> documents = result.docs;

      if (documents.length > 0) {
        //exists
        finalValue = true;
      } else {
        //not exists
        finalValue = false;
      }

      if (finalValue) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      // Handle error
      // ...
      return true;
    }
  }

  // Check is User with FacebookID exist in DB
  Future<bool> checkUserWithFacebookIDExistenceInDb(facebookID) async {
    try {
      var finalValue;
      // Fetch all email number in DB
      final QuerySnapshot result =
          await FirebaseFirestore.instance.collection('users').where('facebookID', isEqualTo: facebookID).get();

      final List<DocumentSnapshot> documents = result.docs;

      if (documents.length > 0) {
        //exists
        finalValue = true;
      } else {
        //not exists
        finalValue = false;
      }

      if (finalValue) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      // Handle error
      // ...
      return true;
    }
  }

  ////////////////// SIGN OUT | FREE SHARED PREFERENCES | UNLINK PROVIDERS
  //////////////////
  //////////////////

  // Sign out
  Future signout(context) async {
    debugPrint('Signing out...');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );
    try {
      if (GoogleSignIn().currentUser != null) {
        GoogleSignIn().disconnect();
      }

      GoogleSignIn().signOut();
      FacebookAuth.instance.logOut();
      await auth.signOut();
      freeingSharedPrefrences();

      Navigator.of(context).pop();

      Navigator.pushAndRemoveUntil(
          context,
          SwipeablePageRoute(
            builder: (context) => LoginPage(
              redirectToAddEmailandPasswordPage: false,
              redirectToAddEmailPage: false,
              redirectToUpdatePasswordPage: false,
            ),
          ),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      debugPrint('Une erreur s\'est produite: $e');
      showSnackbar(context, 'Une erreur s\'est produite !', null);
    }
  }

  // Free up SharedPreferences
  Future freeingSharedPrefrences() async {
    debugPrint('Freeing up Shared Preferences...');

    await UserSimplePreferences.setUsername('');
    await UserSimplePreferences.setEmail('');
    await UserSimplePreferences.setName('');
    await UserSimplePreferences.setPhone('');
    await UserSimplePreferences.setGoogleID('');
    await UserSimplePreferences.setFacebookId('');
    await UserSimplePreferences.setCountry('');
    await UserSimplePreferences.setBirthday('');
    await UserSimplePreferences.setPhoneCodeVerification('');

    debugPrint('Shared Preferences freed...');
  }

  // UNLINK SPECIFIC PROVIDER
  Future<bool> unlinkSpecificProvider(context, String providerID) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Check providersList length
    List providersList = FirebaseAuth.instance.currentUser!.providerData;

    // Allow to remove Provider
    if (providersList.length > 1) {
      //
      switch (providerID) {
        // LinkEmail case
        case 'emailLink':
          try {
            await FirebaseAuth.instance.currentUser?.unlink(EmailAuthProvider.EMAIL_LINK_SIGN_IN_METHOD);

            showSnackbar(context, 'Adresse email détachée', kSecondColor);
            return true;
          } catch (e) {
            debugPrint('Error while unlinking provider : $e');

            showSnackbar(context, 'Une erreur s\'est produite', null);
            Navigator.of(context).pop();
            return false;
          }
        // Password case
        case 'password':
          try {
            await FirebaseAuth.instance.currentUser?.unlink(EmailAuthProvider.PROVIDER_ID);

            bool result = false;

            // Update current user email [Firestore]
            Map<String, Object?> userFieldToUpdate = {
              'email': '',
            };

            // ignore: use_build_context_synchronously
            result = await FirestoreMethods()
                .updateUserWithSpecificFields(context, FirebaseAuth.instance.currentUser!.uid, userFieldToUpdate);
            Navigator.of(context).pop();
            debugPrint('Profile updated (with Empty Email)');

            showSnackbar(context, 'Adresse email détachée', kSecondColor);
            return true;
          } catch (e) {
            debugPrint('Error while unlinking provider : $e');

            showSnackbar(context, 'Une erreur s\'est produite', null);
            Navigator.of(context).pop();
            return false;
          }
        // Phone case
        case 'phone':
          try {
            await FirebaseAuth.instance.currentUser?.unlink(PhoneAuthProvider.PROVIDER_ID);

            bool result = false;
            UserSimplePreferences.setPhoneCodeVerification('');

            // Update current user phoneNumber [Firestore]
            Map<String, Object?> userFieldToUpdate = {
              'phone': '',
            };

            // ignore: use_build_context_synchronously
            result = await FirestoreMethods()
                .updateUserWithSpecificFields(context, FirebaseAuth.instance.currentUser!.uid, userFieldToUpdate);
            debugPrint('Profile updated (with Empty Phone Number)');

            showSnackbar(context, 'Numéro de téléphone détaché', kSecondColor);
            return result;
            //
            //
          } catch (e) {
            debugPrint('Error while unlinking provider : $e');

            showSnackbar(context, 'Une erreur s\'est produite', null);
            Navigator.of(context).pop();
            return false;
          }
        // Google case
        case 'google.com':
          try {
            await FirebaseAuth.instance.currentUser?.unlink(GoogleAuthProvider.PROVIDER_ID);

            GoogleSignIn().disconnect();

            bool result = false;

            // Update current user googleID [Firestore]
            Map<String, Object?> userFieldToUpdate = {
              'googleID': '',
            };

            // ignore: use_build_context_synchronously
            result = await FirestoreMethods()
                .updateUserWithSpecificFields(context, FirebaseAuth.instance.currentUser!.uid, userFieldToUpdate);
            Navigator.of(context).pop();
            debugPrint('Profile updated (with Empty googleID)');

            showSnackbar(context, 'Compte Google détaché', kSecondColor);
            return result;
            //
            //
          } catch (e) {
            debugPrint('Error while unlinking provider : $e');

            showSnackbar(context, 'Une erreur s\'est produite', null);
            Navigator.of(context).pop();
            return false;
          }
        // Facebook case
        case 'facebook.com':
          try {
            await FirebaseAuth.instance.currentUser?.unlink(FacebookAuthProvider.PROVIDER_ID);

            bool result = false;
            // Update current user facebookID [Firestore]
            Map<String, Object?> userFieldToUpdate = {
              'facebookID': '',
            };

            // ignore: use_build_context_synchronously
            result = await FirestoreMethods()
                .updateUserWithSpecificFields(context, FirebaseAuth.instance.currentUser!.uid, userFieldToUpdate);
            Navigator.of(context).pop();
            debugPrint('Profile updated (with Empty facebookID)');

            showSnackbar(context, 'Compte Facebook détaché', kSecondColor);
            return result;
          } catch (e) {
            debugPrint('Error while unlinking provider : $e');

            showSnackbar(context, 'Une erreur s\'est produite', null);
            Navigator.of(context).pop();

            return false;
          }
        // Default
        default:
          showSnackbar(context, 'Une erreur s\'est produite', null);
          Navigator.of(context).pop();
          return false;
      }
    }
    //
    else {
      showSnackbar(context, 'Vous devez garder au moins un moyen d\'accéder à votre compte', null);
      Navigator.of(context).pop();

      return false;
    }
  }

  ////////////////// SIGN IN | RESET PASSWORD | CREATE/MODELLING NEW USER
  //////////////////
  //////////////////

  // MODELING NEW USER
  Future modelingNewUser({required context}) async {
    debugPrint('MODELING NEW USER...');

    String? username = UserSimplePreferences.getUsername();
    String? name = UserSimplePreferences.getName();
    String? phone = UserSimplePreferences.getPhone();

    String? googleID = UserSimplePreferences.getGoogleID();
    String? facebookID = UserSimplePreferences.getFacebookId();

    String? country = UserSimplePreferences.getCountry();
    DateTime? birthday = DateTime.tryParse(UserSimplePreferences.getBirthday()!);
    var ref = FirebaseStorage.instance.ref('profilepictures/default_profile_picture.jpg');
    String downloadUrl = await ref.getDownloadURL();

    // Create a new user
    Map<String, Object?> newUser = UserModel.User(
      id: FirebaseAuth.instance.currentUser!.uid,
      email: FirebaseAuth.instance.currentUser!.email ?? '',
      phone: phone ?? '',
      googleID: googleID ?? '',
      facebookID: facebookID ?? '',
      country: country ?? '',
      username: username!,
      name: name!,
      bio: '',
      lastStoryUpdateDateTime: DateTime(0),
      profilePicture: downloadUrl,
      linkinbio: '',
      birthday: birthday!,
      events: [],
      stories: [],
      followers: [],
      following: [],
      reminders: [],
      forevers: [],
      settingShowEventsNotifications: true,
      settingShowRemindersNotifications: true,
      settingShowStoriesNotifications: true,
      settingShowMessagesNotifications: true,
    ).toJson();

    debugPrint('NEW USER: $newUser');

    //  Update Firestore
    await FirestoreMethods().createUser(context, FirebaseAuth.instance.currentUser!.uid, newUser);

    // ADD DEFAULT EVENT : BIRTHDAY

    // Create a default event : Birthday
    Map<String, Object?> defaultEventBirthday = Event(
      eventId: '',
      uid: FirebaseAuth.instance.currentUser!.uid,
      title: 'Anniversaire de $name',
      caption: '',
      trailing: '',
      type: 'birthday',
      color: 0,
      location: '',
      link: '',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      eventDurationType: '1DayEvent',
      eventDurations: [
        {'date': birthday, 'startTime': '00:00', 'endTime': '23:59', 'isAllTheDay': true}
      ],
      status: '',
    ).toJson();

    //  Update Firestore Event Table
    await FirestoreMethods().createEvent(context, FirebaseAuth.instance.currentUser!.uid, defaultEventBirthday);
    debugPrint('Default event created: birthday');
  }

  // LOGIN WITH EMAIL AND PASSWORD
  Future<bool> loginWithEmailAndPassword(context, email, psw) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    try {
      await auth.signInWithEmailAndPassword(email: email, password: psw);
      Navigator.of(context).pop();

      return true;
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      switch (e.code) {
        case 'invalid-email':
          showSnackbar(context, 'Votre email est invalide', null);
          break;
        case 'user-not-found':
          showSnackbar(context, 'Aucun utilisateur trouvé...', null);
          break;
        case 'wrong-password':
          showSnackbar(context, 'Mot de passe incorrect', null);
          break;
        default:
          showSnackbar(context, 'Une erreur s\'est produite', null);
          break;
      }
      return false;
    }
  }

  // RESET PASSWORD
  Future<bool> resetPassword(context, email) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    try {
      await auth.sendPasswordResetEmail(email: email);
      Navigator.of(context).pop();

      return true;
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      switch (e.code) {
        case 'invalid-email':
          showSnackbar(context, 'Votre email est invalide', null);
          break;
        default:
          showSnackbar(context, 'Une erreur s\'est produite', null);
          break;
      }
      return false;
    }
  }

  // CREATE USER WITH EMAIL AND PASSWORD
  Future<bool> createUserWithEmailAndPassword(context, email, psw) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    try {
      UserCredential credential = await auth.createUserWithEmailAndPassword(email: email, password: psw);

      modelingNewUser(
        context: context,
      );

      // Set ShowIntroductionPagesHandler to: true
      await UserSimplePreferences.setShowIntroductionPagesHandler(true);

      Navigator.of(context).pop();
      return true;
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      showSnackbar(context, 'Une erreur s\'est produite : $e', null);
      return false;
    }
  }

  // CONTINUE LOGIN WITH PHONE
  sendPhoneVerificationCode(phoneNumber) async {
    UserSimplePreferences.setPhoneCodeVerification('');

    String verificationCode = '';

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
            if (value.user != null) {
              debugPrint('Verif code: $verificationCode');
              // return verificationCode;
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint(e.message);
          throw Exception('Une erreur s\'est produite');
          // showSnackbar(context, 'Une erreur s\'est produite', null);
        },
        codeSent: (String? verficationID, int? resendToken) {
          verificationCode = verficationID ?? 'null';
          UserSimplePreferences.setPhoneCodeVerification(verificationCode);
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          verificationCode = verificationID;
          UserSimplePreferences.setPhoneCodeVerification(verificationCode);
        },
        timeout: const Duration(seconds: 120));
  }

  Future<bool> continueWithPhone(context, authType, phoneNumber, pin) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Check code availability and redirect to HomePage
    try {
      await FirebaseAuth.instance
          .signInWithCredential(
        PhoneAuthProvider.credential(verificationId: UserSimplePreferences.getPhoneCodeVerification()!, smsCode: pin),
      )
          .then(
        (value) async {
          if (value.user != null) {
            UserSimplePreferences.setPhoneCodeVerification('');

            if (authType == 'login') {
              // Login to existing user
              Navigator.of(context).pop();

              bool isUserExisting = await checkUserWithPhoneExistenceInDb(phoneNumber);
              if (isUserExisting == false) {
                showSnackbar(context, 'Aucun compte n\'existe avec numéro...', null);
                return false;
              }
              return true;
            } else if (authType == 'signup') {
              // Sign up : create new user

              // Check if any user exists with this phone number
              bool isUserExisting = await checkUserExistenceInDb(value.user!.uid);

              if (isUserExisting == false) {
                AuthMethods().modelingNewUser(
                  context: context,
                );

                // Set ShowIntroductionPagesHandler to: true
                await UserSimplePreferences.setShowIntroductionPagesHandler(true);

                Navigator.of(context).pop();
                return true;
              }
              return false;
            }

            return true;
          }
        },
      );

      return true;
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      switch (e.code) {
        case 'invalid-verification-code':
          showSnackbar(context, 'Code de vérification incorrect', null);
          break;
        case 'invalid-verification-id':
          showSnackbar(context, 'Une erreur s\'est produite lors de la vérification', null);
          break;
        default:
          showSnackbar(context, 'Une erreur s\'est produite ', null);
      }
      return false;
    }
  }

  // CONTINUE LOGIN WITH GOOGLE
  Future<List> continueWithGoogle(context, authType) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Check code availability and redirect to HomePage
    try {
      final googleSignIn = GoogleSignIn();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // handling the exception when cancel sign in
        Navigator.of(context).pop();
        return [false, 'La connexion avec Google a été annulée !'];
      }

      // Check if any user exists with this Google account
      if (authType == 'login') {
        bool isUserExisting = await checkUserWithGoogleIDExistenceInDb(googleUser.id);
        debugPrint('isUserExisting with this Google account : $isUserExisting');

        if (isUserExisting == false) {
          Navigator.of(context).pop();
          GoogleSignIn().disconnect();

          return [false, 'Aucun compte retrouvé, créez-en un...'];
        }
      } else if (authType == 'signup') {
        // Check if any user exists with this Google account
        bool isUserExisting = await checkUserWithGoogleIDExistenceInDb(googleUser.id);
        debugPrint('isUserExisting with this Google account : $isUserExisting');

        if (isUserExisting == true) {
          Navigator.of(context).pop();
          GoogleSignIn().disconnect();

          return [false, 'Ce compte Google est déjà pris !'];
        }
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance
          .signInWithCredential(
        credential,
      )
          .then(
        (value) async {
          if (value.user != null) {
            if (authType == 'login') {
              // Login to existing user
              Navigator.of(context).pop();

              bool isUserExisting = await checkUserExistenceInDb(value.user!.uid);
              if (isUserExisting == false) {
                return [false, 'Aucun compte n\'existe avec cette adresse Google...'];
              }
              return [true];
            } else if (authType == 'signup') {
              bool isUserExisting = await checkUserExistenceInDb(value.user!.uid);
              if (isUserExisting == false) {
                // Sign up : create new user

                // Set Google ID
                await UserSimplePreferences.setGoogleID(googleUser.id);

                // Create a new user
                AuthMethods().modelingNewUser(
                  context: context,
                );

                // Set ShowIntroductionPagesHandler to: true
                await UserSimplePreferences.setShowIntroductionPagesHandler(true);

                Navigator.of(context).pop();
                return [true];
              }
              // return [false, 'Cette adresse Google est déjà utilisée'];
            }
          }
        },
      );

      return [true];
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      return [false, 'Une erreur s\'est produite'];
    }
  }

  // CONTINUE LOGIN WITH FACEBOOK
  Future<List> continueWithFacebook(context, authType) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Check code availability and redirect to HomePage
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: [
          'public_profile',
          'email',
          'user_birthday',
        ],
      );
      if (result.status == LoginStatus.success) {
        // you are logged
        final AccessToken accessToken = result.accessToken!;

        final facebookAuthCredential = FacebookAuthProvider.credential(accessToken.token);

        // Check if any user exists with this Facebook account
        if (authType == 'login') {
          final userData = await FacebookAuth.i.getUserData(
            fields: "id",
          );

          bool isUserExisting = await checkUserWithFacebookIDExistenceInDb(userData['id']);
          debugPrint('isUserExisting with this Facebook account : $isUserExisting');

          if (isUserExisting == false) {
            Navigator.of(context).pop();

            return [false, 'Aucun compte retrouvé, créez-en un...'];
          }
        }

        if (authType == 'signup') {
          final userData = await FacebookAuth.i.getUserData(
            fields: "id",
          );

          bool isUserExisting = await checkUserWithFacebookIDExistenceInDb(userData['id']);
          debugPrint('isUserExisting with this Facebook account : $isUserExisting');

          if (isUserExisting == true) {
            Navigator.of(context).pop();

            return [false, 'Ce compte Facebook est déjà pris !'];
          }
        }

        await FirebaseAuth.instance
            .signInWithCredential(
          facebookAuthCredential,
        )
            .then(
          (value) async {
            if (value.user != null) {
              if (authType == 'login') {
                // Login to existing user
                Navigator.of(context).pop();

                bool isUserExisting = await checkUserExistenceInDb(value.user!.uid);
                if (isUserExisting == false) {
                  return [false, 'Aucun compte n\'existe avec cette adresse Facebook...'];
                }
                return [
                  true,
                ];
              } else if (authType == 'signup') {
                // Sign up : create new user
                bool isUserExisting = await checkUserExistenceInDb(value.user!.uid);
                if (isUserExisting == false) {
                  // Set Facebook ID
                  final userData = await FacebookAuth.i.getUserData(
                    fields: "id",
                  );
                  await UserSimplePreferences.setFacebookId(userData['id']);

                  // Create a new user
                  AuthMethods().modelingNewUser(
                    context: context,
                  );

                  // Set ShowIntroductionPagesHandler to: true
                  await UserSimplePreferences.setShowIntroductionPagesHandler(true);

                  Navigator.of(context).pop();
                  return [true];
                }
                // return [
                //   false,
                //   'Cette adresse Facebook est déjà utilisée...'
                // ];
              }
            }
          },
        );

        return [true];
      } else if (result.status == LoginStatus.cancelled || result.status == LoginStatus.failed) {
        // you cancelled or the operation fails
        Navigator.of(context).pop();
        return [false, 'La connexion avec Facebook a été annulée !'];
      } else {
        Navigator.of(context).pop();
        debugPrint('${result.status}');
        debugPrint(result.message);

        return [false, 'Une erreur s\'est produite...'];
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      return [false, 'Une erreur s\'est produite...'];
    }
  }

  //////////////////  LINK CREDENTIALS | UPDATE EMAIL/PASSWORD
  //////////////////
  //////////////////

  // UPDATE EMAIL :  [Password Provider]
  Future<List> updateCurrentUserEmail(context, email) async
  //
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Check email account linked and redirect to Settings Page
    try {
      String emailAccountEmail = '';
      bool result = false;

      await FirebaseAuth.instance.currentUser?.updateEmail(email).then(
        (value) async {
          // Update current user email [Firestore]
          Map<String, Object?> userFieldToUpdate = {
            'email': email,
          };

          // ignore: use_build_context_synchronously
          result = await FirestoreMethods()
              .updateUserWithSpecificFields(context, FirebaseAuth.instance.currentUser!.uid, userFieldToUpdate);
          if (result) {
            // ignore: use_build_context_synchronously
            showSnackbar(context, 'Votre email s\'est bien modifié !', kSuccessColor);
            debugPrint('Profile updated (with new email)');
          }
        },
      );

      List<UserInfo> passwordProvider =
          FirebaseAuth.instance.currentUser!.providerData.where((element) => element.providerId == 'password').toList();
      if (passwordProvider.length > 0) {
        emailAccountEmail = passwordProvider[0].email!;
      }

      Navigator.of(context).pop();
      return [result, emailAccountEmail];
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      // ignore: use_build_context_synchronously
      switch (e.code) {
        case "requires-recent-login":
          // Show Re-login Modal
          await showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Reconnectez-vous',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Vous devez vous reconnecter à votre compte pour mettre à jour votre adresse email',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          //
                          TextButton(
                            onPressed: () {
                              // Stay on the page
                              Navigator.pop(context, false);
                            },
                            child: const Text(
                              'Annuler',
                              style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 15),

                          // Pop the screen
                          TextButton(
                            onPressed: () {
                              // Redirect to Login Page [with 'redirectToAddEmail' parameter]
                              Navigator.push(
                                  context,
                                  SwipeablePageRoute(
                                    builder: (context) => LoginPage(
                                      redirectToAddEmailandPasswordPage: false,
                                      redirectToAddEmailPage: true,
                                      redirectToUpdatePasswordPage: false,
                                    ),
                                  ));
                            },
                            child: const Text('Me reconnecter'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
          debugPrint("Error while updating email account: $e");

          return [false, ''];
        case "provider-already-linked":
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("The provider has already been linked to the user.");

          return [false, ''];

        case "invalid-credential":
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("The provider's credential is not valid.");
          return [false, ''];
        case "credential-already-in-use":
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          return [false, ''];
        default:
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("Error while updating email account: $e");
          return [false, ''];
      }
    }
  }

  // UPDATE PASSWORD : [Password Provider]
  Future<List> updateCurrentUserPassword(context, psw) async
  //
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Check email account linked and redirect to Settings Page
    try {
      String emailAccountEmail = '';
      bool result = false;

      await FirebaseAuth.instance.currentUser?.updatePassword(psw).then(
        (value) async {
          // Update current user password [Firestore]
          //
          // Skip OPERATION : none
          //
          result = true;
          // ignore: use_build_context_synchronously
          showSnackbar(context, 'Votre mot de passe s\'est bien modifié !', kSuccessColor);
          debugPrint('Profile updated (with new password)');
        },
      );

      List<UserInfo> passwordProvider =
          FirebaseAuth.instance.currentUser!.providerData.where((element) => element.providerId == 'password').toList();
      if (passwordProvider.length > 0) {
        emailAccountEmail = passwordProvider[0].email!;
      }

      Navigator.of(context).pop();
      return [result, emailAccountEmail];
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      // ignore: use_build_context_synchronously
      switch (e.code) {
        case "requires-recent-login":
          // Show Re-login Modal
          await showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Reconnectez-vous',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Vous devez vous reconnecter à votre compte pour mettre à jour votre mot de passe',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          //
                          TextButton(
                            onPressed: () {
                              // Stay on the page
                              Navigator.pop(context, false);
                            },
                            child: const Text(
                              'Annuler',
                              style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 15),

                          // Pop the screen
                          TextButton(
                            onPressed: () {
                              // Redirect to Login Page [with 'redirectToAddEmail' parameter]
                              Navigator.push(
                                  context,
                                  SwipeablePageRoute(
                                    builder: (context) => LoginPage(
                                      redirectToAddEmailandPasswordPage: false,
                                      redirectToAddEmailPage: false,
                                      redirectToUpdatePasswordPage: true,
                                    ),
                                  ));
                            },
                            child: const Text('Me reconnecter'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
          debugPrint("Error while updating password account: $e");

          return [false, ''];
        case "provider-already-linked":
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("The provider has already been linked to the user.");

          return [false, ''];

        case "invalid-credential":
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("The provider's credential is not valid.");
          return [false, ''];
        case "credential-already-in-use":
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          return [false, ''];
        default:
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("Error while updating password account: $e");
          return [false, ''];
      }
    }
  }

  // LINK CREDENTIALS : by email account [+password]
  Future<List> linkCredentialsbyEmailAccount(context, email, psw) async
  //
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Check email account linked and redirect to Settings Page
    try {
      String emailAccountEmail = '';
      bool result = false;

      final emailCredential = EmailAuthProvider.credential(email: email, password: psw);

      try {
        await FirebaseAuth.instance.currentUser?.unlink(EmailAuthProvider.PROVIDER_ID);
        // ignore: empty_catches
      } catch (e) {}

      await FirebaseAuth.instance.currentUser?.linkWithCredential(emailCredential).then(
        (value) async {
          if (value.user != null) {
            // Update current user email [Firestore]
            Map<String, Object?> userFieldToUpdate = {
              'email': email,
            };

            // ignore: use_build_context_synchronously
            result = await FirestoreMethods()
                .updateUserWithSpecificFields(context, FirebaseAuth.instance.currentUser!.uid, userFieldToUpdate);
            if (result) {
              // ignore: use_build_context_synchronously
              showSnackbar(context, 'Votre email s\'est bien ajouté', kSuccessColor);
              debugPrint('Profile updated (with email)');
            }
          }
        },
      );

      List<UserInfo> passwordProvider =
          FirebaseAuth.instance.currentUser!.providerData.where((element) => element.providerId == 'password').toList();
      if (passwordProvider.length > 0) {
        emailAccountEmail = passwordProvider[0].email!;
      }

      Navigator.of(context).pop();
      return [result, emailAccountEmail];
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      // ignore: use_build_context_synchronously
      switch (e.code) {
        case "requires-recent-login":
          // Show Re-login Modal
          await showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Reconnectez-vous',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Vous devez vous reconnecter à votre compte pour associer cette adresse email',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          //
                          TextButton(
                            onPressed: () {
                              // Stay on the page
                              Navigator.pop(context, false);
                            },
                            child: const Text(
                              'Annuler',
                              style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 15),

                          // Pop the screen
                          TextButton(
                            onPressed: () {
                              // Redirect to Login Page [with 'redirectToAddEmailandPasswordPage' parameter]
                              Navigator.push(
                                  context,
                                  SwipeablePageRoute(
                                    builder: (context) => LoginPage(
                                      redirectToAddEmailPage: false,
                                      redirectToAddEmailandPasswordPage: true,
                                      redirectToUpdatePasswordPage: false,
                                    ),
                                  ));
                            },
                            child: const Text('Me reconnecter'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
          debugPrint("Error while updating email account: $e");

          return [false, ''];
        case "provider-already-linked":
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("The provider has already been linked to the user.");

          return [false, ''];

        case "invalid-credential":
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("The provider's credential is not valid.");
          return [false, ''];
        case "credential-already-in-use":
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          return [false, ''];
        default:
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("Error while updating email account: $e");
          return [false, ''];
      }
    }
  }

  // LINK CREDENTIALS : by phone number
  Future<bool> linkCredentialsbyPhoneNumber(context, authType, phoneNumber, pin) async
  //
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Check code availability and redirect to Settings Page
    try {
      try {
        await FirebaseAuth.instance.currentUser?.unlink(PhoneAuthProvider.PROVIDER_ID);
      } catch (e) {}
      await FirebaseAuth.instance.currentUser
          ?.linkWithCredential(PhoneAuthProvider.credential(
              verificationId: UserSimplePreferences.getPhoneCodeVerification()!, smsCode: pin))
          .then(
        (value) async {
          if (value.user != null) {
            bool result = false;
            UserSimplePreferences.setPhoneCodeVerification('');

            // Update current user phoneNumber [Firestore]
            Map<String, Object?> userFieldToUpdate = {
              'phone': phoneNumber,
            };

            // ignore: use_build_context_synchronously
            result = await FirestoreMethods()
                .updateUserWithSpecificFields(context, FirebaseAuth.instance.currentUser!.uid, userFieldToUpdate);
            debugPrint('Profile updated (with Phone Number)');
            return result;
          }
        },
      );

      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          debugPrint("The provider has already been linked to the user.");

          showSnackbar(context, 'Une erreur s\'est produite ', null);
          return false;

        case "invalid-credential":
          debugPrint("The provider's credential is not valid.");
          showSnackbar(context, 'Une erreur s\'est produite ', null);
          return false;
        case "credential-already-in-use":
          debugPrint("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          showSnackbar(context, 'Une erreur s\'est produite ', null);
          return false;
        default:
          debugPrint("Error while updating phone number: $e");
          showSnackbar(context, 'Une erreur s\'est produite', null);
          return false;
      }
    }
  }

  // LINK CREDENTIALS : by google account
  Future<List> linkCredentialsbyGoogleAccount(context) async
  //
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Check google account linked and redirect to Settings Page
    try {
      String googleAccountEmail = '';
      bool result = false;
      List<UserInfo> googleProvider = [];

      final googleSignIn = GoogleSignIn();

      final googleUser = await googleSignIn.signIn();

      // handling the exception when cancel sign in
      if (googleUser == null) {
        Navigator.of(context).pop();
        showSnackbar(context, 'La connexion avec Google a été annulée !', null);
        List<UserInfo> googleProvider = FirebaseAuth.instance.currentUser!.providerData
            .where((element) => element.providerId == 'google.com')
            .toList();
        if (googleProvider.length > 0) {
          googleAccountEmail = googleProvider[0].email!;
        }

        return [false, googleAccountEmail];
      }

      // Check if any user exists with this Google account
      bool isUserExisting = await checkUserWithGoogleIDExistenceInDb(googleUser.id);
      debugPrint('isUserExisting with this Google account : $isUserExisting');

      if (isUserExisting == true) {
        Navigator.of(context).pop();
        GoogleSignIn().disconnect();

        showSnackbar(context, 'Ce compte Google est déjà pris !', null);
        List<UserInfo> googleProvider = FirebaseAuth.instance.currentUser!.providerData
            .where((element) => element.providerId == 'google.com')
            .toList();
        if (googleProvider.length > 0) {
          googleAccountEmail = googleProvider[0].email!;
        }

        return [false, googleAccountEmail];
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Check if GoogleProvider exist
      googleProvider = FirebaseAuth.instance.currentUser!.providerData
          .where((element) => element.providerId == 'google.com')
          .toList();
      if (googleProvider.length > 0) {
        await FirebaseAuth.instance.currentUser?.unlink(GoogleAuthProvider.PROVIDER_ID);

        // Update current user googleID [Firestore]
        Map<String, Object?> userFieldToUpdate = {
          'googleID': '',
        };

        // ignore: use_build_context_synchronously
        result = await FirestoreMethods()
            .updateUserWithSpecificFields(context, FirebaseAuth.instance.currentUser!.uid, userFieldToUpdate);
      }

      await FirebaseAuth.instance.currentUser?.linkWithCredential(credential).then(
        (value) async {
          if (value.user != null) {
            // Update current user googleID [Firestore]
            Map<String, Object?> userFieldToUpdate = {
              'googleID': googleUser.id,
            };

            // ignore: use_build_context_synchronously
            result = await FirestoreMethods()
                .updateUserWithSpecificFields(context, FirebaseAuth.instance.currentUser!.uid, userFieldToUpdate);
            if (result) {
              // ignore: use_build_context_synchronously
              showSnackbar(context, 'Votre compte Google s\'est bien ajouté', kSuccessColor);
              debugPrint('Profile updated (with googleID)');
            }
          }
        },
      );

      googleProvider = FirebaseAuth.instance.currentUser!.providerData
          .where((element) => element.providerId == 'google.com')
          .toList();
      if (googleProvider.length > 0) {
        googleAccountEmail = googleProvider[0].email!;
      }

      Navigator.of(context).pop();
      await GoogleSignIn().disconnect();
      return [result, googleAccountEmail];
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      GoogleSignIn().disconnect();

      // ignore: use_build_context_synchronously
      switch (e.code) {
        case "provider-already-linked":
          debugPrint("The provider has already been linked to the user.");
          showSnackbar(context, 'Une erreur s\'est produite', null);

          return [false, ''];

        case "invalid-credential":
          debugPrint("The provider's credential is not valid.");
          showSnackbar(context, 'Une erreur s\'est produite', null);
          return [false, ''];
        case "credential-already-in-use":
          debugPrint("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          showSnackbar(context, 'Une erreur s\'est produite', null);
          return [false, ''];
        case "email-already-in-use":
          debugPrint("Error: $e");
          showSnackbar(context, 'Cette adresse email est déjà utilisée par un autre compte', null);
          return [false, ''];
        default:
          showSnackbar(context, 'Une erreur s\'est produite', null);
          debugPrint("Error while updating Google account: $e");
          return [false, ''];
      }
    }
  }

  // LINK CREDENTIALS : by facebook account
  Future<List> linkCredentialsbyFacebookAccount(context) async
  //
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Check facebook account linked and redirect to Settings Page
    try {
      String facebookAccountName = '';
      bool result = false;

      final LoginResult fbLoginResult = await FacebookAuth.instance.login(
        permissions: [
          'public_profile',
          'email',
          'user_birthday',
        ],
      );

      // handling the exception when cancel sign in
      if (fbLoginResult.status == LoginStatus.cancelled || fbLoginResult.status == LoginStatus.failed) {
        Navigator.of(context).pop();
        FacebookAuth.instance.logOut();

        showSnackbar(context, 'La connexion avec Facebook a été annulée !', null);

        List<UserInfo> facebookProvider = FirebaseAuth.instance.currentUser!.providerData
            .where((element) => element.providerId == 'facebook.com')
            .toList();
        if (facebookProvider.length > 0) {
          facebookAccountName = facebookProvider[0].displayName!;
        }

        return [false, facebookAccountName];
      }

      // Success : login
      if (fbLoginResult.status == LoginStatus.success) {
        // you are logged
        AccessToken? accessToken = fbLoginResult.accessToken!;

        final facebookAuthCredential = FacebookAuthProvider.credential(accessToken.token);

        final userData = await FacebookAuth.i.getUserData(
          fields: 'id',
        );

        // Check if any user exists with this Facebook account
        bool isUserExisting = await checkUserWithFacebookIDExistenceInDb(userData['id']);
        debugPrint('isUserExisting with this Facebook account : $isUserExisting');

        if (isUserExisting == true) {
          Navigator.of(context).pop();
          FacebookAuth.instance.logOut();
          accessToken = null;

          showSnackbar(context, 'Ce compte Facebook est déjà pris !', null);
          List<UserInfo> facebookProvider = FirebaseAuth.instance.currentUser!.providerData
              .where((element) => element.providerId == 'facebook.com')
              .toList();
          if (facebookProvider.length > 0) {
            facebookAccountName = facebookProvider[0].displayName!;
          }

          return [false, facebookAccountName];
        }

        // CONTINUE
        try {
          await FirebaseAuth.instance.currentUser?.unlink(FacebookAuthProvider.PROVIDER_ID);
        } catch (e) {}

        await FirebaseAuth.instance.currentUser?.linkWithCredential(facebookAuthCredential).then(
          (value) async {
            if (value.user != null) {
              // Update current user facebookID [Firestore]
              Map<String, Object?> userFieldToUpdate = {
                'facebookID': userData['id'],
              };

              // ignore: use_build_context_synchronously
              result = await FirestoreMethods()
                  .updateUserWithSpecificFields(context, FirebaseAuth.instance.currentUser!.uid, userFieldToUpdate);
              if (result) {
                // ignore: use_build_context_synchronously
                showSnackbar(context, 'Votre compte Facebook s\'est bien ajouté', kSuccessColor);
                debugPrint('Profile updated (with facebookID)');
              }
            }
          },
        );

        List<UserInfo> facebookProvider = FirebaseAuth.instance.currentUser!.providerData
            .where((element) => element.providerId == 'facebook.com')
            .toList();
        if (facebookProvider.length > 0) {
          facebookAccountName = facebookProvider[0].displayName!;
        }
      }

      Navigator.of(context).pop();
      FacebookAuth.instance.logOut();
      return [result, facebookAccountName];
      //
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      FacebookAuth.instance.logOut();
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Une erreur s\'est produite', null);
      switch (e.code) {
        case "provider-already-linked":
          debugPrint("The provider has already been linked to the user.");

          return [false, ''];

        case "invalid-credential":
          debugPrint("The provider's credential is not valid.");
          return [false, ''];
        case "credential-already-in-use":
          debugPrint("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          return [false, ''];
        default:
          debugPrint("Error : $e");
          return [false, ''];
      }
    }
  }
}

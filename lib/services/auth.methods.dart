import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/services/sharedpreferences.service.dart';
import '../models/user.dart' as UserModel;
import '../pages/login.dart';
import '../utils/functions.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  FirebaseAuth auth = FirebaseAuth.instance;

  // MODELING NEW USER
  Future modelingNewUser({required context}) async {
    debugPrint('MODELING NEW USER...');

    String? username = UserSimplePreferences.getUsername();
    String? name = UserSimplePreferences.getName();
    String? phone = UserSimplePreferences.getPhone();

    String? googleID = UserSimplePreferences.getGoogleID();
    String? facebookID = UserSimplePreferences.getFacebookId();

    String? country = UserSimplePreferences.getCountry();
    DateTime? birthday =
        DateTime.tryParse(UserSimplePreferences.getBirthday()!);
    var ref = FirebaseStorage.instance
        .ref('profilepictures/default_profile_picture.jpg');
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
      profilePicture: downloadUrl,
      linkinbio: '',
      birthday: birthday!,
      events: [],
      story: [],
      followers: [],
      following: [],
      reminders: [],
    ).toJson();

    print('NEW USER: $newUser');

    //  Update Firestore
    await FirestoreMethods()
        .createUser(context, FirebaseAuth.instance.currentUser!.uid, newUser);

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
      startDateTime: birthday,
      endDateTime: birthday,
      status: '',
    ).toJson();

    //  Update Firestore Event Table
    await FirestoreMethods().createEvent(
        context, FirebaseAuth.instance.currentUser!.uid, defaultEventBirthday);
    print('Default event created: birthday');
  }

  // Free up SharedPreferences
  Future freeingSharedPrefrences() async {
    print('Freeing up Shared Preferences...');

    await UserSimplePreferences.setUsername('');
    await UserSimplePreferences.setEmail('');
    await UserSimplePreferences.setName('');
    await UserSimplePreferences.setPhone('');
    await UserSimplePreferences.setGoogleID('');
    await UserSimplePreferences.setFacebookId('');
    await UserSimplePreferences.setCountry('');
    await UserSimplePreferences.setBirthday('');
    await UserSimplePreferences.setPhoneCodeVerification('');

    print('Shared Preferences freed...');
  }

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
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

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
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('googleID', isEqualTo: googleID)
          .get();

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
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('facebookID', isEqualTo: facebookID)
          .get();

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

  // SIGN OUT
  Future signout(context) async {
    print('Signing out...');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
      ),
    );
    try {
      GoogleSignIn().disconnect();
      GoogleSignIn().signOut();
      FacebookAuth.instance.logOut();
      await auth.signOut();
      freeingSharedPrefrences();

      Navigator.of(context).pop();

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      print('Une erreur s\'est produite: $e');
      showSnackbar(context, 'Une erreur s\'est produite !', null);
    }
  }

  // LOGIN WITH EMAIL AND PASSWORD
  Future<bool> loginWithEmailAndPassword(context, email, psw) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
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
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
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
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
      ),
    );

    try {
      UserCredential credential = await auth.createUserWithEmailAndPassword(
          email: email, password: psw);

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
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              print('Verif code: $verificationCode');
              // return verificationCode;
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
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
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
      ),
    );

    // Check code availability and redirect to HomePage
    try {
      await FirebaseAuth.instance
          .signInWithCredential(
        PhoneAuthProvider.credential(
            verificationId: UserSimplePreferences.getPhoneCodeVerification()!,
            smsCode: pin),
      )
          .then(
        (value) async {
          if (value.user != null) {
            UserSimplePreferences.setPhoneCodeVerification('');

            if (authType == 'login') {
              // Login to existing user
              Navigator.of(context).pop();

              bool isUserExisting =
                  await checkUserExistenceInDb(value.user!.uid);
              if (isUserExisting == false) {
                showSnackbar(
                    context, 'Aucun compte n\'existe avec numéro...', null);
                return false;
              }
              return true;
            } else if (authType == 'signup') {
              // Sign up : create new user

              // Check if any user exists with this phone number
              bool isUserExisting =
                  await checkUserExistenceInDb(value.user!.uid);

              if (isUserExisting == false) {
                AuthMethods().modelingNewUser(
                  context: context,
                );

                // Set ShowIntroductionPagesHandler to: true
                await UserSimplePreferences.setShowIntroductionPagesHandler(
                    true);

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
          showSnackbar(context,
              'Une erreur s\'est produite lors de la vérification', null);
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
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
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
        bool isUserExisting =
            await checkUserWithGoogleIDExistenceInDb(googleUser.id);
        print('isUserExisting with this Google account : $isUserExisting');

        if (isUserExisting == false) {
          Navigator.of(context).pop();

          return [false, 'Aucun compte retrouvé, creez-en un...'];
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

              bool isUserExisting =
                  await checkUserExistenceInDb(value.user!.uid);
              if (isUserExisting == false) {
                return [
                  false,
                  'Aucun compte n\'existe avec cette adresse Google...'
                ];
              }
              return [true];
            } else if (authType == 'signup') {
              bool isUserExisting =
                  await checkUserExistenceInDb(value.user!.uid);
              if (isUserExisting == false) {
                // Sign up : create new user

                // Set Google ID
                await UserSimplePreferences.setGoogleID(googleUser.id);

                // Create a new user
                AuthMethods().modelingNewUser(
                  context: context,
                );

                // Set ShowIntroductionPagesHandler to: true
                await UserSimplePreferences.setShowIntroductionPagesHandler(
                    true);

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
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
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

        final facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken.token);

        // Check if any user exists with this Facebook account
        if (authType == 'login') {
          final userData = await FacebookAuth.i.getUserData(
            fields: "id",
          );

          bool isUserExisting =
              await checkUserWithFacebookIDExistenceInDb(userData['id']);
          print('isUserExisting with this Facebook account : $isUserExisting');

          if (isUserExisting == false) {
            Navigator.of(context).pop();

            return [false, 'Aucun compte retrouvé, creez-en un...'];
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

                bool isUserExisting =
                    await checkUserExistenceInDb(value.user!.uid);
                if (isUserExisting == false) {
                  return [
                    false,
                    'Aucun compte n\'existe avec cette adresse Facebook...'
                  ];
                }
                return [
                  true,
                ];
              } else if (authType == 'signup') {
                // Sign up : create new user
                bool isUserExisting =
                    await checkUserExistenceInDb(value.user!.uid);
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
                  await UserSimplePreferences.setShowIntroductionPagesHandler(
                      true);

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
      } else if (result.status == LoginStatus.cancelled ||
          result.status == LoginStatus.failed) {
        // you cancelled or the operation fails
        Navigator.of(context).pop();
        return [false, 'La connexion avec Facebook a été annulée !'];
      } else {
        Navigator.of(context).pop();
        print(result.status);
        print(result.message);

        return [false, 'Une erreur s\'est produite...'];
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      return [false, 'Une erreur s\'est produite...'];
    }
  }
}

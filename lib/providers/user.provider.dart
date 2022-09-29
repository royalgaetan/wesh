import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../models/user.dart' as UserModel;
import 'package:wesh/services/firestore.methods.dart';

class UserProvider with ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;
  var userUid = FirebaseAuth.instance.currentUser!.uid;

  String phoneCodeVerification = '';

  get getUserUid => userUid;

  get getUser => user!;

  // Get current user Name
  Future<String> getCurrentUserName() async {
    UserModel.User? currentUser = await FirestoreMethods().getUser(userUid);
    return currentUser!.name;
  }

  // Get current user Name
  Future<DateTime> getCurrentUserBirthday() async {
    UserModel.User? currentUser = await FirestoreMethods().getUser(userUid);
    return currentUser!.birthday;
  }

  // Get other any user info
  // Get any user name
  // Get any user birthday
  // Get any user ...
  // TODO:
}

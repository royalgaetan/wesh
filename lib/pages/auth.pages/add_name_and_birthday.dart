import 'package:age_calculator/age_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/auth.pages/signupmethodspage.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/textfieldcontainer.dart';
import '../../services/sharedpreferences.service.dart';
import '../auth.pages/add_profile_picture.dart';

class AddNameAndBirthdayPage extends StatefulWidget {
  AddNameAndBirthdayPage({Key? key}) : super(key: key);

  @override
  State<AddNameAndBirthdayPage> createState() => _AddNameAndBirthdayPageState();
}

class _AddNameAndBirthdayPageState extends State<AddNameAndBirthdayPage> {
  TextEditingController nameController = TextEditingController();
  late DateTime birthday;

  bool isPageLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    birthday = DateTime(0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
  }

  // ignore: non_constant_identifier_names
  updateName_Birthday() async {
    setState(() {
      isPageLoading = true;
    });
    if (nameController.text.isNotEmpty) {
      if (birthday != DateTime(0)) {
        // DateDuration age = AgeCalculator.age(birthday);
        // if (age.years > 13) {
        // FirestoreMethods().updateCurrentUserName(context, nameController.text);
        // FirestoreMethods().updateCurrentUserBirthday(context, birthday);

        await UserSimplePreferences.setName(nameController.text);
        await UserSimplePreferences.setBirthday(birthday.toIso8601String());

        setState(() {
          isPageLoading = false;
        });
        // ignore: use_build_context_synchronously
        Navigator.push(
            context,
            SwipeablePageRoute(
              builder: (context) => SignUpMethodPage(),
            ));
        // }
        // else {
        //   setState(() {
        //     isPageLoading = false;
        //   });
        //   return showSnackbar(context,
        //       'Vous devez avoir plus de 13 ans pour continuer...', null);
        // }
      } else {
        setState(() {
          isPageLoading = false;
        });
        return showSnackbar(context, 'Veuillez entrer votre vraie date d\'anniversaire', null);
      }
    } else {
      setState(() {
        isPageLoading = false;
      });
      return showSnackbar(context, 'Veuillez entrer votre vrai nom', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 0.08.sh),
        child: MorphingAppBar(
          heroTag: 'addNameAndBirthdayPageAppBar',
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
                    Container(
                      height: 0.14.sh,
                      width: 0.14.sh,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/gift.png'),
                        ),
                      ),
                    ),
                    SizedBox(height: 0.07.sw),
                    Text(
                      'Ajoutez votre nom et votre date d\'anniversaire',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22.sp,
                      ),
                    ),
                    SizedBox(height: 0.04.sw),
                    Text(
                      'avant de continuer',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.12.sw),
                // Name Field Input
                TextformContainer(
                  child: TextField(
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.allow(RegExp("[a-z]")),
                    // ],
                    controller: nameController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                      contentPadding: EdgeInsets.all(0.04.sw),
                      hintText: 'Nom',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 0.07.sw),

                // Birthday Field Input
                TextformContainer(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        splashRadius: 0.06.sw,
                        onPressed: () async {
                          // Pick Date
                          DateTime? pickedDate = await pickDate(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate == null) {
                            setState(() {
                              birthday = DateTime(0);
                            });
                          } else {
                            setState(() {
                              birthday = pickedDate;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_month_rounded),
                      ),
                      hintText: birthday != DateTime(0)
                          ? DateFormat('dd MMMM yyyy').format(birthday)
                          : 'Ajouter une date d\'anniversaire',
                      hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                      contentPadding: EdgeInsets.all(0.04.sw),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 0.07.sw),
                // Button Action : Update Name and Birthday
                Button(
                  height: 0.12.sw,
                  width: double.infinity,
                  text: 'Suivant',
                  color: kSecondColor,
                  onTap: () {
                    // Update data & Redirect to Add_Profile_Picture_Page
                    updateName_Birthday();
                  },
                ),
                SizedBox(height: 0.07.sw),
              ].reversed.toList(),
            ),
          ),
        ],
      ),
    );
  }
}

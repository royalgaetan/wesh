import 'package:age_calculator/age_calculator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        Navigator.push(
            context,
            MaterialPageRoute(
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
        return showSnackbar(
            context, 'Veuillez entrer votre vraie date d\'anniversaire', null);
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/gift.png'),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      const Text(
                        'Ajoutez votre nom et votre date d\'anniversaire',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Text('avant de continuer',
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),

                  // Name Field Input
                  TextformContainer(
                    child: TextField(
                      // inputFormatters: [
                      //   FilteringTextInputFormatter.allow(RegExp("[a-z]")),
                      // ],
                      controller: nameController,
                      decoration: const InputDecoration(
                          hintText: 'Nom',
                          contentPadding: EdgeInsets.all(20),
                          border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    height: 27,
                  ),

                  // Birthday Field Input
                  TextformContainer(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            splashRadius: 22,
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
                              ? DateFormat('d MMMM yyyy').format(birthday)
                              : 'Ajouter une date d\'anniversaire',
                          contentPadding: const EdgeInsets.all(20),
                          border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    height: 27,
                  ),

                  // Button Action : Update Name and Birthday
                  Button(
                    height: 50,
                    width: double.infinity,
                    text: 'Suivant',
                    color: kSecondColor,
                    onTap: () {
                      // Update data & Redirect to Add_Profile_Picture_Page
                      updateName_Birthday();
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/auth.pages/signupmethodspage.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/textfieldcontainer.dart';
import '../../services/sharedpreferences.service.dart';

class AddNameAndBirthdayPage extends StatefulWidget {
  const AddNameAndBirthdayPage({super.key});

  @override
  State<AddNameAndBirthdayPage> createState() => _AddNameAndBirthdayPageState();
}

class _AddNameAndBirthdayPageState extends State<AddNameAndBirthdayPage> {
  TextEditingController nameController = TextEditingController();
  late DateTime birthday;

  bool isPageLoading = false;

  @override
  void initState() {
    //
    super.initState();
    birthday = DateTime(0);
  }

  @override
  void dispose() {
    //
    super.dispose();
    nameController.dispose();
  }

  // ignore: non_constant_identifier_names
  updateName_Birthday() async {
    setState(() {
      isPageLoading = true;
    });

    if (nameController.text.isNotEmpty && nameController.text.length < 46) {
      if (birthday != DateTime(0)) {
        // DateDuration age = AgeCalculator.age(birthday);
        // if (age.years > 13) {
        // FirestoreMethods.updateCurrentUserName(context, nameController.text);
        // FirestoreMethods.updateCurrentUserBirthday(context, birthday);

        await UserSimplePreferences.setName(nameController.text);
        await UserSimplePreferences.setBirthday(birthday.toIso8601String());

        setState(() {
          isPageLoading = false;
        });
        if (!mounted) return;
        Navigator.push(
            context,
            SwipeablePageRoute(
              builder: (context) => const SignUpMethodPage(),
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
        if (mounted) {
          showSnackbar(context, 'Please enter your real date of birth', null);
        }
      }
    } else {
      if (mounted) {
        showSnackbar(context, 'Please enter your real name (less than 45 characters)', null);
      }
    }

    setState(() {
      isPageLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 0.08.sh),
        child: MorphingAppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
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
              padding: EdgeInsets.fromLTRB(0.1.sw, 0.03.sw, 0.1.sw, 0.1.sw),
              shrinkWrap: true,
              reverse: true,
              children: [
                Column(
                  children: [
                    Container(
                      height: 0.10.sh,
                      width: 0.10.sh,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(gift),
                        ),
                      ),
                    ),
                    SizedBox(height: 0.07.sw),
                    Text(
                      'Add your name \nand date of birth',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.1.sw),
                // Name Field Input
                TextformContainer(
                  child: TextField(
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.allow(RegExp("[a-z]")),
                    // ],
                    controller: nameController,
                    maxLength: 45,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                      contentPadding: EdgeInsets.all(0.04.sw),
                      counterText: '',
                      hintText: 'Name',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 0.07.sw),

                // Birthday Field Input
                TextformContainer(
                  padding: EdgeInsets.all(0.04.sw),
                  onTap: () async {
                    // Pick Date
                    DateTime? pickedDate = await pickDate(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        birthday = pickedDate;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          birthday != DateTime(0)
                              ? DateFormat('dd MMMM yyyy').format(birthday)
                              : 'Add your date of birth',
                          style: TextStyle(
                              color: birthday == DateTime(0) ? Colors.grey.shade600 : Colors.black87, fontSize: 14.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.black87,
                      )
                    ],
                  ),
                ),

                Center(
                  child: Wrap(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 0.1.sw),
                        child: Text(
                          'Your date of birth cannot be changed later',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11.sp),
                        ),
                      )
                    ],
                  ),
                ),
                // Button Action : Update Name and Birthday
                Button(
                  height: 0.12.sw,
                  width: double.infinity,
                  text: 'Next',
                  color: isPageLoading ? kSecondColor.withOpacity(.5) : kSecondColor,
                  onTap: isPageLoading
                      ? () {}
                      : () {
                          // Update data & Redirect to Add_Profile_Picture_Page
                          updateName_Birthday();
                        },
                ),
                SizedBox(height: 0.09.sw),
              ].reversed.toList(),
            ),
          ),
        ],
      ),
    );
  }
}

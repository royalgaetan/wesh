import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';

class ReminderSelector extends StatefulWidget {
  Duration? reminderDelay;

  ReminderSelector({Key? key, this.reminderDelay}) : super(key: key);

  @override
  State<ReminderSelector> createState() => _ReminderSelectorState();
}

class _ReminderSelectorState extends State<ReminderSelector> {
  int? selectedValue = 0;
  Duration? selectedDuration;

  @override
  void initState() {
    super.initState();

    selectedDuration = getDurationFromIndex(selectedValue!);
  }

  Duration? getDurationFromIndex(int index) {
    switch (index) {
      case 0:
        return const Duration();

      case 1:
        return const Duration(minutes: 10);

      case 2:
        return const Duration(hours: 1);

      case 3:
        return const Duration(days: 1);

      case 4:
        return const Duration(days: 3);

      case 5:
        return const Duration(days: 7);

      case 6:
        return const Duration(days: 30);

      default:
        return selectedDuration = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: Text(
              selectedDuration == null
                  ? 'Ne pas me rappeler'
                  : 'Me rappeler ${remindersList[selectedValue as int].data}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Center(
              child: CupertinoPicker(
                  itemExtent: 30,
                  scrollController: FixedExtentScrollController(initialItem: 0),
                  onSelectedItemChanged: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                    selectedDuration = getDurationFromIndex(selectedValue!);
                  },
                  children: remindersList),
            ),
          ),

          // Reminder Action Buttons

          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Button(
                  text: 'Annuler',
                  height: 0.12.sw,
                  width: double.infinity,
                  fontsize: 13.sp,
                  fontColor: Colors.black,
                  color: Colors.white,
                  isBordered: true,
                  onTap: () {
                    // Pop Reminder Selector Modal
                    Navigator.pop(context, null);
                  },
                ),
                const SizedBox(
                  width: 13,
                ),
                Button(
                    onTap: () {
                      // Pop the Reminder Selector Modal
                      // Send back the Selected Reminder

                      Navigator.pop(context, selectedDuration);
                    },
                    text: 'Ajouter le rappel',
                    height: 0.12.sw,
                    width: double.infinity,
                    fontsize: 13.sp,
                    fontColor: Colors.white,
                    color: kSecondColor),
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    // TODO: implement initState
    super.initState();

    selectedDuration = getDurationFromIndex(selectedValue!);
  }

  Duration? getDurationFromIndex(int index) {
    switch (index) {
      case 0:
        return const Duration();

      case 1:
        return const Duration(hours: 1);

      case 2:
        return const Duration(days: 1);

      case 3:
        return const Duration(days: 7);

      case 4:
        return const Duration(days: 30);

      default:
        return selectedDuration = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 100),
            child: Text(
              selectedDuration == null
                  ? 'Ne pas me rappeler'
                  : 'Me rappeler ${remindersList[selectedValue as int].data}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
                  height: 45,
                  width: 150,
                  fontsize: 16,
                  fontColor: Colors.black,
                  color: Colors.white,
                  isBordered: true,
                  onTap: () {
                    // Pop Reminder Selector Modal
                    Navigator.pop(context, null);
                  },
                ),
                SizedBox(
                  width: 13,
                ),
                Button(
                    onTap: () {
                      // Pop the Reminder Selector Modal
                      // Send back the Selected Reminder

                      Navigator.pop(context, selectedDuration);
                    },
                    text: 'Ajouter le rappel',
                    height: 45,
                    width: 150,
                    fontsize: 16,
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

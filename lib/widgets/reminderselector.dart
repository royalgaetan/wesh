import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';

class ReminderSelector extends StatefulWidget {
  Duration? duration = Duration(hours: 1);
  int? selectedValue = 0;

  ReminderSelector({this.duration});

  @override
  State<ReminderSelector> createState() => _ReminderSelectorState();
}

class _ReminderSelectorState extends State<ReminderSelector> {
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
              widget.duration == null
                  ? 'Ne pas me rappeler'
                  : 'Me rappeler ${remindersList[widget.selectedValue as int].data}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Center(
              child: CupertinoPicker(
                  itemExtent: 30,
                  scrollController: FixedExtentScrollController(initialItem: 1),
                  onSelectedItemChanged: (value) {
                    setState(() {
                      widget.selectedValue = value;
                    });
                    switch (value) {
                      case 0:
                        setState(() {
                          widget.duration = null;
                        });
                        break;
                      case 1:
                        setState(() {
                          widget.duration = Duration(hours: 1);
                        });

                        break;
                      case 2:
                        setState(() {
                          widget.duration = Duration(days: 1);
                        });

                        break;
                      case 3:
                        setState(() {
                          widget.duration = Duration(days: 7);
                        });
                        break;
                      case 4:
                        setState(() {
                          widget.duration = Duration(days: 30);
                        });
                        break;

                      default:
                        setState(() {
                          widget.duration = null;
                        });
                    }
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
                    Navigator.pop(context, widget.duration);
                  },
                ),
                SizedBox(
                  width: 13,
                ),
                Button(
                    onTap: () {
                      // Pop the Reminder Selector Modal
                      // Send back the Selected Reminder

                      Navigator.pop(context, widget.duration);
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

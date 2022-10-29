import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';

class RecurrenceSelector extends StatefulWidget {
  Duration? RecurrenceDelay;

  RecurrenceSelector({Key? key, this.RecurrenceDelay}) : super(key: key);

  @override
  State<RecurrenceSelector> createState() => _RecurrenceSelectorState();
}

class _RecurrenceSelectorState extends State<RecurrenceSelector> {
  int selectedValue = 0;

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
              selectedValue == 0
                  ? 'Ne pas me rappeler'
                  : 'Me rappeler ${recurrencesList[selectedValue as int].data!.toLowerCase()}',
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
                  },
                  children: recurrencesList),
            ),
          ),

          // Recurrence Action Buttons

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
                    // Pop Recurrence Selector Modal
                    Navigator.pop(context, null);
                  },
                ),
                SizedBox(
                  width: 13,
                ),
                Button(
                    onTap: () {
                      // Pop the Recurrence Selector Modal
                      // Send back the Selected Recurrence

                      Navigator.pop(context, selectedValue);
                    },
                    text: 'Ajouter la récurrence',
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

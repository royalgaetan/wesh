import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';

class RecurrenceSelector extends StatefulWidget {
  Duration? recurrenceDelay;

  RecurrenceSelector({Key? key, this.recurrenceDelay}) : super(key: key);

  @override
  State<RecurrenceSelector> createState() => _RecurrenceSelectorState();
}

class _RecurrenceSelectorState extends State<RecurrenceSelector> {
  int selectedValue = 0;

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
              selectedValue == 0
                  ? 'Ne pas me rappeler'
                  : 'Me rappeler ${recurrencesList[selectedValue].data!.toLowerCase()}',
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
                  height: 0.12.sw,
                  width: double.infinity,
                  fontsize: 13.sp,
                  fontColor: Colors.black,
                  color: Colors.white,
                  isBordered: true,
                  onTap: () {
                    // Pop Recurrence Selector Modal
                    Navigator.pop(context, null);
                  },
                ),
                const SizedBox(
                  width: 13,
                ),
                Button(
                    onTap: () {
                      // Pop the Recurrence Selector Modal
                      // Send back the Selected Recurrence

                      Navigator.pop(context, selectedValue);
                    },
                    text: 'Ajouter la récurrence',
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

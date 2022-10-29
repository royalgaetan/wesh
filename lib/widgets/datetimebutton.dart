import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/functions.dart';

class DateTimeButton extends StatelessWidget {
  final DateTime? date;
  final TimeOfDay? timeOfDay;
  final String type;
  final VoidCallback onTap;

  const DateTimeButton({
    this.date,
    this.timeOfDay,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          type == "time"
              ? DateFormat('HH:mm', 'fr').format(
                  formatTimeOfDay(
                    timeOfDay!,
                  ),
                )
              : DateFormat('EEE, d MMM yyyy', 'fr_FR').format(date!),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
    ;
  }
}

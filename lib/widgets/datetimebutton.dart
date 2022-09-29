import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeButton extends StatelessWidget {
  final DateTime date;
  final String type;
  final VoidCallback onTap;

  const DateTimeButton({
    required this.date,
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
              ? '${DateFormat('hh:mm', 'fr_FR').format(date)}'
              : '${DateFormat('EEE, d MMM yyyy', 'fr_FR').format(date)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
    ;
  }
}
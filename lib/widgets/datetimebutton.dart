import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../utils/functions.dart';

class DateTimeButton extends StatelessWidget {
  final DateTime? date;
  final TimeOfDay? timeOfDay;
  final String type;
  final bool? hasBorder;
  final Color? borderColor;
  final Color? fontColor;
  final double? fontSize;
  final VoidCallback onTap;

  const DateTimeButton({
    this.date,
    this.timeOfDay,
    required this.type,
    required this.onTap,
    this.borderColor,
    this.fontColor,
    this.fontSize,
    this.hasBorder,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: hasBorder == false ? null : Border.all(color: borderColor ?? Colors.grey.shade600),
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
          style:
              TextStyle(fontSize: fontSize ?? 13.sp, color: fontColor ?? Colors.black87, fontWeight: FontWeight.w500),
        ),
      ),
    );
    ;
  }
}

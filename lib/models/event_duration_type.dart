import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventDurationType {
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool isAllTheDay;

  EventDurationType({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAllTheDay,
  });

  // Copy
  EventDurationType copy({
    DateTime? newDate,
    TimeOfDay? newStartTime,
    TimeOfDay? newEndTime,
    bool? newIsAllTheDay,
  }) =>
      EventDurationType(
        date: newDate ?? date,
        startTime: newStartTime ?? startTime,
        endTime: newEndTime ?? endTime,
        isAllTheDay: newIsAllTheDay ?? isAllTheDay,
      );

  // ToJson
  Map<String, dynamic> toJson() => {
        'date': date,
        'startTime': '${startTime.hour}:${startTime.minute}',
        'endTime': '${endTime.hour}:${endTime.minute}',
        'isAllTheDay': isAllTheDay,
      };

  // From Json
  static EventDurationType fromJson(Map<String, dynamic> json) => EventDurationType(
        date: json['date'] != null && json['date'] != ''
            ? (json['date'] as Timestamp).toDate().toLocal()
            : DateTime.now(),
        //
        startTime: TimeOfDay(
            hour: int.parse((json['startTime'] as String).split(':')[0]),
            minute: int.parse((json['startTime'] as String).split(':')[1])),
        //
        endTime: TimeOfDay(
            hour: int.parse((json['endTime'] as String).split(':')[0]),
            minute: int.parse((json['endTime'] as String).split(':')[1])),
        //
        isAllTheDay: json['isAllTheDay'] ?? true,
      );
}

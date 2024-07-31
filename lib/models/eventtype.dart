class EventType {
  final String key;
  final String name;
  final String iconPath;
  final String description;
  final bool recurrence;

  EventType(
      {required this.key,
      required this.name,
      required this.recurrence,
      required this.iconPath,
      required this.description});
}

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String facebookID;
  final String googleID;
  final String phone;
  final String country;
  final String username;
  final String name;
  final String bio;
  final String profilePicture;
  final String linkinbio;
  final DateTime birthday;
  final List<dynamic>? events;
  final List<dynamic>? stories;
  final List<dynamic>? followers;
  final List<dynamic>? followings;
  final List<dynamic>? reminders;
  final List<dynamic>? forevers;
  final List<dynamic>? discussions;
  final bool settingShowEventsNotifications;
  final bool settingShowRemindersNotifications;
  final bool settingShowStoriesNotifications;
  final bool settingShowMessagesNotifications;
  // Constructor
  User({
    required this.id,
    required this.email,
    required this.googleID,
    required this.facebookID,
    required this.phone,
    required this.country,
    required this.username,
    required this.name,
    required this.bio,
    required this.profilePicture,
    required this.linkinbio,
    required this.birthday,
    this.events,
    this.stories,
    this.followers,
    this.followings,
    this.reminders,
    this.forevers,
    this.discussions,
    required this.settingShowEventsNotifications,
    required this.settingShowRemindersNotifications,
    required this.settingShowStoriesNotifications,
    required this.settingShowMessagesNotifications,
  });

  // ToJson

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'facebookID': facebookID,
        'googleID': googleID,
        'phone': phone,
        'country': country,
        'username': username,
        'name': name,
        'bio': bio,
        'profilePicture': profilePicture,
        'linkinbio': linkinbio,
        'birthday': birthday,
        'events': events,
        'stories': stories,
        'followers': followers,
        'followings': followings,
        'reminders': reminders,
        'forevers': forevers,
        'discussions': discussions,
        'settingShowEventsNotifications': settingShowEventsNotifications,
        'settingShowRemindersNotifications': settingShowRemindersNotifications,
        'settingShowStoriesNotifications': settingShowStoriesNotifications,
        'settingShowMessagesNotifications': settingShowMessagesNotifications,
      };

  // From Json
  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'] ?? '',
        email: json['email'] ?? '',
        facebookID: json['facebookID'] ?? '',
        googleID: json['googleID'] ?? '',
        phone: json['phone'] ?? '',
        country: json['country'] ?? '',
        username: json['username'] ?? '',
        name: json['name'] ?? '',
        bio: json['bio'] ?? '',
        profilePicture: json['profilePicture'] ?? '',
        linkinbio: json['linkinbio'] ?? '',
        //
        birthday: json['birthday'] != null && json['birthday'] != ''
            ? (json['birthday'] as Timestamp).toDate().toLocal()
            : DateTime.now(),
        //
        events: json['events'] ?? [],
        stories: json['stories'] ?? [],
        followers: json['followers'] ?? [],
        followings: json['followings'] ?? [],
        reminders: json['reminders'] ?? [],
        forevers: json['forevers'] ?? [],
        discussions: json['discussions'] ?? [],
        //
        settingShowEventsNotifications: json['settingShowEventsNotifications'] ?? true,
        settingShowRemindersNotifications: json['settingShowRemindersNotifications'] ?? true,
        settingShowStoriesNotifications: json['settingShowStoriesNotifications'] ?? true,
        settingShowMessagesNotifications: json['settingShowMessagesNotifications'] ?? true,
      );
}

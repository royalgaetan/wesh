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
  final List<dynamic>? story;
  final List<dynamic>? followers;
  final List<dynamic>? following;
  final List<dynamic>? reminders;
// final String List<Contacts>;
// final String Reminders<List<eventId, status, remindAt;

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
    this.story,
    this.followers,
    this.following,
    this.reminders,
  });

  // Copy
  User copy({
    String? id,
    String? email,
    String? facebookID,
    String? googleID,
    String? phone,
    String? country,
    String? username,
    String? name,
    String? bio,
    String? profilePicture,
    String? linkinbio,
    DateTime? birthday,
    List<String>? events,
    List<String>? story,
    List<String>? followers,
    List<String>? following,
    List<dynamic>? reminders,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        facebookID: email ?? this.facebookID,
        googleID: email ?? this.googleID,
        phone: phone ?? this.phone,
        country: country ?? this.country,
        username: username ?? this.username,
        name: name ?? this.name,
        bio: bio ?? this.bio,
        profilePicture: profilePicture ?? this.profilePicture,
        linkinbio: linkinbio ?? this.linkinbio,
        birthday: birthday ?? this.birthday,
        events: events ?? this.events,
        story: story ?? this.story,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        reminders: reminders ?? this.reminders,
      );

  // ToJson

  Map<String, Object?> toJson() => {
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
        'birthday': birthday.toIso8601String(),
        'events': events,
        'story': story,
        'followers': followers,
        'following': following,
        'reminders': reminders,
      };

  // From Json
  static User fromJson(Map<String, Object?> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        facebookID: json['facebookID'] as String,
        googleID: json['googleID'] as String,
        phone: json['phone'] as String,
        country: json['country'] as String,
        username: json['username'] as String,
        name: json['name'] as String,
        bio: json['bio'] as String,
        profilePicture: json['profilePicture'] as String,
        linkinbio: json['linkinbio'] as String,
        birthday: DateTime.parse(json['birthday'] as String),
        events: json['events'] as List<dynamic>,
        story: json['story'] as List<dynamic>,
        followers: json['followers'] as List<dynamic>,
        following: json['following'] as List<dynamic>,
        reminders: json['reminders'] as List<dynamic>,
      );
}

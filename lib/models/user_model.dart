class User {

  final String id;
  final String username;
  final String email;
  final String? city;
  final String? profilePhoto;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.city,
    this.profilePhoto,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:           json["_id"],
      username:     json["username"],
      email:        json["email"],
      city:         json["city"],
      profilePhoto: json["profilePhoto"],
      createdAt:    DateTime.parse(json["createdAt"]),
    );
  }

}
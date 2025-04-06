class UserModel {
  String uid;
  String email;
  String role;
  String name;
  String phone;
  String address;
  String city;
  String state;
  String country;
  String locationTag; // For precise location tags (e.g., GPS coordinates)
  String profileImageUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name = "Anonymous",
    this.phone = "Not Provided",
    this.address = "Not Provided",
    this.city = "Not Provided",
    this.state = "Not Provided",
    this.country = "Not Provided",
    this.locationTag = "Unknown",
    this.profileImageUrl = "https://example.com/default_profile_image.png",
  });

  // Convert UserModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'locationTag': locationTag,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'User',
      name: map['name'] ?? 'Anonymous',
      phone: map['phone'] ?? 'Not Provided',
      address: map['address'] ?? 'Not Provided',
      city: map['city'] ?? 'Not Provided',
      state: map['state'] ?? 'Not Provided',
      country: map['country'] ?? 'Not Provided',
      locationTag: map['locationTag'] ?? 'Unknown',
      profileImageUrl: map['profileImageUrl'] ?? 'https://example.com/default_profile_image.png',
    );
  }
}

class NGOModel {
  String uid;
  String name;
  String email;
  String phone;
  String address;
  String city;
  String state;
  String country;
  double latitude;
  double longitude;
  String profileImageUrl;
  int totalFoodSaved;
  int totalEventsHosted;
  String role;
  int pendingOrders;
  dynamic agent;
  dynamic event;

  NGOModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = "Not Provided",
    this.address = "Not Provided",
    this.city = "Not Provided",
    this.state = "Not Provided",
    this.country = "Not Provided",
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.profileImageUrl = "https://example.com/default_profile_image.png",
    required this.totalFoodSaved,
    required this.totalEventsHosted,
    this.role = "NGO",
    this.pendingOrders = 0,
    this.agent = "",
    this.event = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'agent': agent,
      'event': event,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'profileImageUrl': profileImageUrl,
      'totalFoodSaved': totalFoodSaved,
      'totalEventsHosted': totalEventsHosted,
      'role': role,
      'pendingOrders' : pendingOrders,
    };
  }

  factory NGOModel.fromMap(Map<String, dynamic> map) {
    return NGOModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'Anonymous NGO',
      email: map['email'] ?? '',
      phone: map['phone'] ?? 'Not Provided',
      address: map['address'] ?? 'Not Provided',
      city: map['city'] ?? 'Not Provided',
      agent: map['agent'] ?? 'Not Provided',
      event: map['event'] ?? 'Not Provided',
      state: map['state'] ?? 'Not Provided',
      country: map['country'] ?? 'Not Provided',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      profileImageUrl: map['profileImageUrl'] ?? 'https://example.com/default_profile_image.png',
      totalFoodSaved: map['totalFoodSaved'] ?? 0,
      totalEventsHosted: map['totalEventsHosted'] ?? 0,
      role: map['role'] ?? 'NGO',
    );
  }
}
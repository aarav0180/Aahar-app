class NGOAgentModel {
  String uid;
  String name;
  String email;
  String phone;
  String assignedNGO;
  int successfulDeliveries;
  double latitude;
  double longitude;
  String role;

  NGOAgentModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = "Not Provided",
    this.assignedNGO = "Not Assigned",
    this.successfulDeliveries = 0,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.role = "NGO Agent",
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'assignedNGO': assignedNGO,
      'successfulDeliveries': successfulDeliveries,
      'latitude': latitude,
      'longitude': longitude,
      'role': role,
    };
  }

  factory NGOAgentModel.fromMap(Map<String, dynamic> map) {
    return NGOAgentModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'Anonymous Agent',
      email: map['email'] ?? '',
      phone: map['phone'] ?? 'Not Provided',
      assignedNGO: map['assignedNGO'] ?? 'Not Assigned',
      successfulDeliveries: map['successfulDeliveries'] ?? 0,
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      role: map['role'] ?? 'NGO Agent',
    );
  }
}
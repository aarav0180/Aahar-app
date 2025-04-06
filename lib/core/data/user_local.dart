import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../utils/functions/firebase_user.dart';
import '../Models/agentModel.dart';
import '../Models/ngoModel.dart';
import '../Models/userModel.dart';

class UserLocalStorage {
  static const String _userKey = 'user_data';

  // 🔹 Save user to local storage
  static Future<void> saveUser(dynamic user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }

  // 🔹 Retrieve user from local storage, else fetch from Firebase
  static Future<dynamic> getUser(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_userKey);

    if (userJson != null) {
      return _decodeUser(userJson);
    } else {
      // If not found locally, fetch from Firebase
      var userData = await FirebaseServices().getUserByEmail(email);

      if (userData != null) {
        dynamic user = _mapUser(userData);
        await saveUser(user);
        return user;
      }
    }
    return null;
  }

  static Future<dynamic> checkUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = prefs.getString(_userKey) ?? '0';
    if(userJson == '0'){
      return null;
    }
    return _decodeUser(userJson);
  }

  // 🔹 Decode user JSON and determine role
  static dynamic _decodeUser(String userJson) {
    Map<String, dynamic> userMap = jsonDecode(userJson);
    return _mapUser(userMap);
  }

  // 🔹 Map user based on role
  static dynamic _mapUser(Map<String, dynamic> userMap) {
    String? role = userMap['role'];

    if (role == 'NGO') {
      return NGOModel.fromMap(userMap);
    } else if (role == 'NGO Agent') {
      return NGOAgentModel.fromMap(userMap);
    } else {
      return UserModel.fromMap(userMap);
    }
  }

  // 🔹 Clear user data (Logout)
  static Future<void> clearUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}

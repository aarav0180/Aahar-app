import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/agentModel.dart';
import '../Models/ngoModel.dart';
import '../Models/userModel.dart';
import '../data/user_local.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern to ensure a single instance of AuthService
  static final AuthService _instance = AuthService._internal();
  AuthService._internal();
  factory AuthService() => _instance;

  // 🔹 Sign Up with Role & Save to Local Storage
  Future<String?> signUp(String email, String password, String role) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      dynamic userData;

      if (role == 'NGO') {
        userData = NGOModel(
          uid: uid,
          name: "New NGO",
          email: email,
          totalFoodSaved: 0,
          totalEventsHosted: 0,
        );
      } else if (role == 'NGO Agent') {
        userData = NGOAgentModel(
          uid: uid,
          name: "New Agent",
          email: email,
        );
      } else {
        userData = UserModel(
          uid: uid,
          email: email,
          role: "User",
        );
      }

      // Save user data to Firestore
      await _firestore.collection('users').doc(uid).set(userData.toMap());

      // 🔥 Save user data locally
      await UserLocalStorage.saveUser(userData);

      return 'Sign up successful';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // 🔹 Login with Role Check & Save to Local Storage
  Future<String?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userMap = userDoc.data() as Map<String, dynamic>;
        String? role = userMap['role'];
        dynamic userData;

        // 🔥 Identify user type & store locally
        if (role == 'NGO') {
          userData = NGOModel.fromMap(userMap);
        } else if (role == 'NGO Agent') {
          userData = NGOAgentModel.fromMap(userMap);
        } else {
          userData = UserModel.fromMap(userMap);
        }

        // Save to local storage
        await UserLocalStorage.saveUser(userData);

        return 'Login successful';
      }
      return 'User not found';
    } catch (e) {
      print('Login failed: ${e.toString()}');
      return null;
    }
  }

  // 🔹 Get Current User from Local Storage
  Future<dynamic> getCurrentUser(String email) async {
    return await UserLocalStorage.getUser(email);
  }

  // 🔹 Logout (Clear Local Storage)
  Future<void> logout() async {
    await _auth.signOut();
    await UserLocalStorage.clearUser();
  }

  // 🔹 Get User Role from Local Storage
  Future<String?> getUserRole(String email) async {
    var user = await UserLocalStorage.getUser(email);
    return user?.role;
  }

  // 🔹 Check if User is Logged In
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}

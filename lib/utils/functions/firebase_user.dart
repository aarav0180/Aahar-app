import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add User Details
  Future<void> addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await _firestore.collection("users").doc(id).set(userInfoMap);
  }

  // Fetch User Data by Email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // Add Products
  Future<DocumentReference<Map<String, dynamic>>> addProduct(Map<String, dynamic> productData, String categoryName) async {
    return await _firestore.collection(categoryName).add(productData);
  }

  // Get Products Stream
  Stream<QuerySnapshot> getProducts(String category) {
    return _firestore.collection(category).snapshots();
  }

  // Get Orders Stream
  Stream<QuerySnapshot> getOrders(String email) {
    return _firestore.collection("Orders").where("Email", isEqualTo: email).snapshots();
  }

  // Authenticate User Login
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }
}

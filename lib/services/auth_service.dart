import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> isAdmin() async {
    if (currentUser == null) return false;

    final doc =
        await _firestore.collection('users').doc(currentUser!.uid).get();

    return doc.data()?['isAdmin'] ?? false;
  }
}

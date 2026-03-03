import 'package:ai_life_organizer/features/auth/domain/entities/user_profile.dart';
import 'package:ai_life_organizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase implementation of [AuthRepository].
/// Handles Auth state and Firestore user profile.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';

  @override
  Stream<UserProfile?> get currentUser {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return null;
      return await _getProfile(user.uid);
    });
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user?.uid;
    if (uid == null) throw Exception('User creation failed');

    final profile = UserProfile(
      id: uid,
      email: email,
      displayName: displayName ?? '',
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .set(profile.toFirestore());
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _getProfile(user.uid);
  }

  Future<UserProfile?> _getProfile(String uid) async {
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    if (doc.data() == null) return null;
    return UserProfile.fromFirestore(doc.data()!, doc.id);
  }
}

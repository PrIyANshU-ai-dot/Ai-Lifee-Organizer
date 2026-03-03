import 'package:ai_life_organizer/features/auth/domain/entities/user_profile.dart';
import 'package:ai_life_organizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase implementation of [AuthRepository].
/// Handles Auth state and Firestore user profile.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  bool _googleInitialized = false;

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
  Future<void> signInWithGoogle() async {
    try {
      // google_sign_in v7+ uses a singleton instance with a one-time
      // initialization step. The previous `GoogleSignIn().signIn()` API is no
      // longer available; calling it would fail at compile time.
      if (!_googleInitialized) {
        await GoogleSignIn.instance.initialize();
        _googleInitialized = true;
      }

      // Start an interactive sign-in flow.
      final googleAccount = await GoogleSignIn.instance.authenticate(
        scopeHint: const <String>['email', 'profile'],
      );

      final googleAuth = googleAccount.authentication;
      // Access tokens are exposed via the authorization client. Since this is
      // triggered from a user gesture, it's safe to prompt if necessary.
      final authz = await googleAccount.authorizationClient.authorizeScopes(
        const <String>['email', 'profile'],
      );
      final credential = GoogleAuthProvider.credential(
        accessToken: authz.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final uid = userCred.user?.uid;
      if (uid == null) throw Exception('Google sign-in failed.');

      // Create a Firestore user profile if it doesn't exist yet. This keeps
      // the app's user profile data model consistent across email and Google
      // sign-in methods.
      await _ensureUserProfile(
        uid: uid,
        email: userCred.user?.email ?? '',
        displayName: userCred.user?.displayName ?? '',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
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
    // Ensure we sign out of both FirebaseAuth and the Google session so the
    // next login can prompt for account selection if desired.
    try {
      if (_googleInitialized) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (_) {}
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

  Future<void> _ensureUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    final ref = _firestore.collection(_usersCollection).doc(uid);
    final existing = await ref.get();
    if (existing.data() != null) return;

    final profile = UserProfile(
      id: uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    await ref.set(profile.toFirestore());
  }
}

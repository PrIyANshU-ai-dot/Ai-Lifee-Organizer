import 'package:ai_life_organizer/features/auth/domain/entities/user_profile.dart';

/// Repository contract for authentication (domain layer).
/// Implementation lives in data layer.
abstract class AuthRepository {
  /// Current user stream; null when signed out.
  Stream<UserProfile?> get currentUser;

  /// Sign in with email and password.
  Future<void> signInWithEmailAndPassword(String email, String password);

  /// Sign in with Google using Firebase Auth.
  ///
  /// Design note: this lives on the same repository contract to keep
  /// presentation code unaware of Firebase/GoogleSignIn details while still
  /// supporting multiple auth methods under one abstraction.
  Future<void> signInWithGoogle();

  /// Create account with email and password and store profile in Firestore.
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign out.
  Future<void> signOut();

  /// Get current user profile once (for initial load).
  Future<UserProfile?> getCurrentUser();
}

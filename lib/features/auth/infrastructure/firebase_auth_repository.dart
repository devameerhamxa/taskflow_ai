import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskflow_ai/features/auth/domain/auth_repository.dart';
import 'package:taskflow_ai/features/auth/domain/user_profile_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<UserProfile?> watchUserProfile(String userId) {
    log('[AuthRepo] Setting up user profile stream for ID: $userId');

    final docRef = _firestore.collection('users').doc(userId);

    return docRef.snapshots().asyncMap((snapshot) async {
      try {
        if (snapshot.exists && snapshot.data() != null) {
          // log('[AuthRepo] User profile data received from stream');
          return UserProfile.fromSnapshotGeneric(snapshot);
        } else {
          log('[AuthRepo] Profile document missing for ID: $userId');
          // log(
          //   '[AuthRepo] 📊 Snapshot exists: ${snapshot.exists}, Data: ${snapshot.data()}',
          // );

          // Try to create the missing profile if current user matches
          if (_firebaseAuth.currentUser?.uid == userId) {
            log(
              '[AuthRepo] Attempting to create missing profile for current user',
            );
            final profile = await ensureUserProfileExists();
            return profile;
          } else {
            log(
              '[AuthRepo] Cannot create profile - user ID mismatch or no current user',
            );
            return null;
          }
        }
      } catch (e, stackTrace) {
        log(
          '[AuthRepo] Error in profile stream',
          error: e,
          stackTrace: stackTrace,
        );
        return null;
      }
    });
  }

  // method to check if user profile exists and create if needed
  Future<UserProfile?> ensureUserProfileExists() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      // log('[AuthRepo] Cannot ensure profile - no current user');
      return null;
    }

    try {
      log('[AuthRepo] Checking if profile exists for user: ${currentUser.uid}');
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        // log('[AuthRepo] Profile already exists');
        return UserProfile.fromSnapshotGeneric(doc);
      } else {
        log(
          '[AuthRepo] Profile missing. Creating now for user: ${currentUser.uid}',
        );
        log(
          '[AuthRepo] User info - Name: ${currentUser.displayName}, Email: ${currentUser.email}',
        );

        final userProfile = UserProfile(
          id: currentUser.uid,
          name:
              currentUser.displayName ??
              currentUser.email?.split('@').first ??
              'User',
          email: currentUser.email ?? '',
          createdAt: DateTime.now(),
        );

        // log('[AuthRepo] Attempting to create profile document...');
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .set(userProfile.toJsonWithDateTime());

        log('[AuthRepo] Profile document created successfully');

        // Verify creation
        final verifyDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (verifyDoc.exists) {
          // log('[AuthRepo] Profile creation verified');
          return UserProfile.fromSnapshotGeneric(verifyDoc);
        } else {
          // log('[AuthRepo] Profile creation verification FAILED');
          return null;
        }
      }
    } catch (e, stackTrace) {
      log(
        '[AuthRepo] Error ensuring profile exists',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // log('[AuthRepo] Starting email signup process for: $email');

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      log(
        '[AuthRepo] Firebase Auth user created. UID: ${userCredential.user?.uid}',
      );
      log(
        '[AuthRepo] 📋 User details - Email: ${userCredential.user?.email}, EmailVerified: ${userCredential.user?.emailVerified}',
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;

        // Update the display name first
        await user.updateDisplayName(name);
        await user.reload();

        final userProfile = UserProfile(
          id: user.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );

        // log('[AuthRepo] Creating Firestore profile document...');
        // log('[AuthRepo] Profile data: ${userProfile.toString()}');

        final docRef = _firestore.collection('users').doc(user.uid);
        await docRef.set(userProfile.toJsonWithDateTime());

        // log('[AuthRepo] Firestore document set operation completed');

        // Immediate verification
        final verifyDoc = await docRef.get();
        if (verifyDoc.exists) {
        } else {
          log(
            '[AuthRepo] Document creation verification FAILED - document does not exist',
          );
          throw Exception('Failed to create user profile document');
        }
      } else {
        log('[AuthRepo] User credential is null after signup');
        throw Exception('User credential is null after signup');
      }
    } on FirebaseAuthException catch (e) {
      log(
        '[AuthRepo] FIREBASE AUTH ERROR during Email Sign Up: ${e.code} - ${e.message}',
        error: e,
      );
      rethrow;
    } on FirebaseException catch (e) {
      log(
        '[AuthRepo] FIRESTORE ERROR during Email Sign Up: ${e.code} - ${e.message}',
        error: e,
      );
      log(
        '[AuthRepo] Firestore error details - Plugin: ${e.plugin}, StackTrace: ${e.stackTrace}',
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        '[AuthRepo] UNKNOWN ERROR during Email Sign Up',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      log('[AuthRepo] Starting Google Sign-In process...');

      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      log('[AuthRepo] Google account selected: ${googleUser.email}');

      try {
        // Get the authentication details
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        // Create credential with idToken
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          // Remove accessToken if it doesn't exist in your version
          // accessToken: googleAuth.accessToken,
        );

        final userCredential = await _firebaseAuth.signInWithCredential(
          credential,
        );

        // Handle new user creation
        if (userCredential.additionalUserInfo?.isNewUser == true &&
            userCredential.user != null) {
          await _createUserProfile(userCredential.user!);
        } else if (userCredential.user != null) {
          await _ensureUserProfileExists(userCredential.user!);
        }
      } on FirebaseAuthException catch (e) {
        log(
          '[AuthRepo] Firebase Auth error during Google authentication',
          error: e,
        );
        rethrow;
      }
    } catch (e) {
      log('[AuthRepo] Error during Google sign in', error: e);
      rethrow;
    }
  }

  // Helper method to create user profile
  Future<void> _createUserProfile(User user) async {
    final userProfile = UserProfile(
      id: user.uid,
      name: user.displayName ?? 'Google User',
      email: user.email ?? '',
      createdAt: DateTime.now(),
    );

    final docRef = _firestore.collection('users').doc(user.uid);
    await docRef.set(userProfile.toJsonWithDateTime());

    // Verify creation
    final verifyDoc = await docRef.get();
    if (!verifyDoc.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'profile-creation-failed',
        message: 'Failed to create user profile document',
      );
    }
  }

  // Helper method to ensure profile exists
  Future<void> _ensureUserProfileExists(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      log('[AuthRepo] Creating missing profile for existing user');
      await _createUserProfile(user);
    }
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _ensureUserProfileExists(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      log('[AuthRepo] Firebase Auth error during email sign in', error: e);
      rethrow;
    } catch (e) {
      log('[AuthRepo] Unknown error during email sign in', error: e);
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google (this is safe to call even if not signed in)
      await _googleSignIn.signOut();
      // Then sign out from Firebase
      await _firebaseAuth.signOut();
    } catch (e) {
      log('[AuthRepo] Error during sign out', error: e);
      rethrow;
    }
  }
}

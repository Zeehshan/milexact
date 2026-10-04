import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:milexact/domain/auth/auth.dart';

class FirestoreUserProfileDataSource {
  FirestoreUserProfileDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db {
    if (Firebase.apps.isEmpty) {
      throw const AuthException(
        'Firebase auth is not configured for this platform yet.',
      );
    }
    return _firestore ?? FirebaseFirestore.instance;
  }

  Future<void> upsertUser(AppUser user) async {
    final docRef = _db.collection('users').doc(user.id);
    final snapshot = await docRef.get();

    await docRef.set(<String, dynamic>{
      'uid': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'emailVerified': user.emailVerified,
      'providerIds': user.providerIds,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastSignInAt': FieldValue.serverTimestamp(),
      if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

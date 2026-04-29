import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:milexact/domain/auth/exceptions/auth_exception.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;
  bool _googleInitialized = false;

  FirebaseAuth _auth() {
    _ensureFirebaseInitialized();
    return FirebaseAuth.instance;
  }

  User? get currentUser =>
      _isFirebaseReady ? FirebaseAuth.instance.currentUser : null;

  Stream<User?> userChanges() {
    if (!_isFirebaseReady) {
      return const Stream<User?>.empty();
    }
    return FirebaseAuth.instance.userChanges();
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth().createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth().signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleInitialized();
    await _googleSignIn.signOut();

    final account = await _googleSignIn.authenticate();
    final authentication = account.authentication;
    final idToken = authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw const AuthException(
        'Google sign-in did not return a valid ID token.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    return _auth().signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');

    return _auth().signInWithProvider(provider);
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth().sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    final user = _auth().currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user is available.');
    }
    await user.sendEmailVerification();
  }

  Future<User?> reloadCurrentUser() async {
    final user = _auth().currentUser;
    await user?.reload();
    return _auth().currentUser;
  }

  Future<void> signOut() async {
    if (_isFirebaseReady) {
      await _auth().signOut();
    }
    await _googleSignIn.signOut();
  }

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  void _ensureFirebaseInitialized() {
    if (!_isFirebaseReady) {
      throw const AuthException(
        'Firebase auth is not configured for this platform yet.',
      );
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) {
      return;
    }
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }
}

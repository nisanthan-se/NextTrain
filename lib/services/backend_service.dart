import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUserProfile {
  final String name;
  final String email;
  final String location;
  final String role;
  final int predictions;

  const AppUserProfile({
    required this.name,
    required this.email,
    required this.location,
    required this.role,
    required this.predictions,
  });

  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': name,
      'email': email,
      'location': location,
      'role': role,
      'predictions': predictions,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppUserProfile.fromFirestoreMap(Map<String, dynamic> data) {
    return AppUserProfile(
      name: data['name']?.toString() ?? 'User',
      email: data['email']?.toString() ?? '',
      location: data['location']?.toString() ?? 'Sri Lanka',
      role: data['role']?.toString() ?? 'NextTrain Premium User',
      predictions: int.tryParse(data['predictions']?.toString() ?? '0') ?? 0,
    );
  }
}

class BackendService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    final profile = AppUserProfile(
      name: name,
      email: email,
      location: 'Sri Lanka',
      role: 'NextTrain Premium User',
      predictions: 0,
    );

    await _firestore.collection('users').doc(uid).set(profile.toFirestoreMap());
  }

  static Future<AppUserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists) return null;

    return AppUserProfile.fromFirestoreMap(snapshot.data()!);
  }

  static Stream<AppUserProfile?> watchCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore.collection('users').doc(user.uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return AppUserProfile.fromFirestoreMap(snapshot.data()!);
    });
  }

  static Future<void> updateProfile({
    required String name,
    required String email,
    required String location,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'name': name,
      'email': email,
      'location': location,
    });
  }

  static Future<void> incrementPredictionCount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'predictions': FieldValue.increment(1),
    });
  }
}

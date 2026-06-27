import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BackendException implements Exception {
  final String message;
  BackendException(this.message);

  @override
  String toString() => message;
}

class AppUserProfile {
  final String name;
  final String email;
  final String location;
  final String role;
  final int predictions;
  final bool notificationsEnabled;

  const AppUserProfile({
    required this.name,
    required this.email,
    required this.location,
    required this.role,
    required this.predictions,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': name,
      'email': email,
      'location': location,
      'role': role,
      'predictions': predictions,
      'notificationsEnabled': notificationsEnabled,
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
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
    );
  }

  AppUserProfile copyWith({
    String? name,
    String? email,
    String? location,
    String? role,
    int? predictions,
    bool? notificationsEnabled,
  }) {
    return AppUserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      location: location ?? this.location,
      role: role ?? this.role,
      predictions: predictions ?? this.predictions,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class PredictionRecord {
  final String id;
  final String trainName;
  final String route;
  final int delayMinutes;
  final String date;
  final String accuracy;

  const PredictionRecord({
    this.id = '',
    required this.trainName,
    required this.route,
    required this.delayMinutes,
    required this.date,
    required this.accuracy,
  });

  Map<String, dynamic> toFirestoreMap() {
    return {
      'trainName': trainName,
      'route': route,
      'delayMinutes': delayMinutes,
      'accuracy': accuracy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory PredictionRecord.fromFirestoreMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final timestamp = data['createdAt'];
    String dateLabel = 'Just now';

    if (timestamp is Timestamp) {
      final value = timestamp.toDate();
      dateLabel = '${value.day}/${value.month}/${value.year}';
    }

    return PredictionRecord(
      id: id,
      trainName: data['trainName']?.toString() ?? 'Unknown Train',
      route: data['route']?.toString() ?? '',
      delayMinutes:
          int.tryParse(data['delayMinutes']?.toString() ?? '0') ?? 0,
      date: dateLabel,
      accuracy: data['accuracy']?.toString() ?? '90%',
    );
  }
}

class DashboardStats {
  final String accuracyLabel;
  final String predictionsLabel;
  final String avgDelayLabel;

  const DashboardStats({
    required this.accuracyLabel,
    required this.predictionsLabel,
    required this.avgDelayLabel,
  });

  static DashboardStats fromRecords(List<PredictionRecord> records, {int profilePredictions = 0}) {
    if (records.isEmpty) {
      return DashboardStats(
        accuracyLabel: '—',
        predictionsLabel: '$profilePredictions',
        avgDelayLabel: '—',
      );
    }

    final accuracies = records
        .map((r) => int.tryParse(r.accuracy.replaceAll('%', '')) ?? 90)
        .toList();
    final avgAccuracy = accuracies.reduce((a, b) => a + b) ~/ accuracies.length;
    final avgDelay = records.map((r) => r.delayMinutes).reduce((a, b) => a + b) ~/ records.length;

    return DashboardStats(
      accuracyLabel: '$avgAccuracy%',
      predictionsLabel: '${records.length > profilePredictions ? records.length : profilePredictions}',
      avgDelayLabel: '${avgDelay}m',
    );
  }
}

class BackendService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static void _requireAuth() {
    if (_auth.currentUser == null) {
      throw BackendException('Please sign in to use this feature.');
    }
  }

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
    _requireAuth();
    final user = _auth.currentUser!;

    await _firestore.collection('users').doc(user.uid).update({
      'name': name,
      'email': email,
      'location': location,
    });
  }

  static Future<void> updateNotificationPreference(bool enabled) async {
    _requireAuth();
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'notificationsEnabled': enabled,
    });
  }

  static Future<void> incrementPredictionCount() async {
    _requireAuth();
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'predictions': FieldValue.increment(1),
    });
  }

  static CollectionReference<Map<String, dynamic>> _predictionsCollection() {
    _requireAuth();
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('predictions');
  }

  static Future<void> savePrediction(PredictionRecord record) async {
    await _predictionsCollection().add(record.toFirestoreMap());
  }

  static Future<void> savePredictionAndIncrement(PredictionRecord record) async {
    _requireAuth();
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(_auth.currentUser!.uid);
    final predictionRef = _predictionsCollection().doc();

    batch.set(predictionRef, record.toFirestoreMap());
    batch.update(userRef, {'predictions': FieldValue.increment(1)});
    await batch.commit();
  }

  static Future<void> deletePrediction(String id) async {
    if (id.isEmpty) return;
    await _predictionsCollection().doc(id).delete();
  }

  static Stream<List<PredictionRecord>> watchPredictions() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('predictions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => PredictionRecord.fromFirestoreMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();
    });
  }
}

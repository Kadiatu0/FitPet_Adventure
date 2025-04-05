import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  DocumentReference<Map<String, dynamic>> get userDoc => FirebaseFirestore
      .instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid);

  /// Returns documents accessed by the date format YYYY-MM-DD.
  CollectionReference<Map<String, dynamic>> get dailyCollection =>
      userDoc.collection('Daily');

  /// Returns documents accessed by the date format YYYY-MM.
  CollectionReference<Map<String, dynamic>> get monthlyCollection =>
      userDoc.collection('Monthly');

  /// Returns documents accessed by the date format YYYY.
  CollectionReference<Map<String, dynamic>> get yearlyCollection =>
      userDoc.collection('Yearly');

  /// Returns documents accessed by a uniquely generated key for each cosmetic.
  CollectionReference<Map<String, dynamic>> get cosmeticsCollection =>
      userDoc.collection('Cosmetics');

  /// Creates and increments a [key] value in a [doc].
  Future<void> increment(
    DocumentReference<Map<String, dynamic>> doc,
    String key,
    int amount,
  ) async {
    await doc.set({key: FieldValue.increment(amount)}, SetOptions(merge: true));
  }

  /// Creates and resets a [key] value in a [doc].
  Future<void> reset(
    DocumentReference<Map<String, dynamic>> doc,
    String key,
  ) async {
    await doc.set({key: 0}, SetOptions(merge: true));
  }

  /// Deletes all documents in a [collection].
  Future<void> clearCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await collection.get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Adds a batch of documents to a [collection] containing a [value].
  Future<void> batchAdd(
    CollectionReference<Map<String, dynamic>> collection,
    value,
  ) async {
    final batch = FirebaseFirestore.instance.batch();
    final doc = collection.doc();
    batch.set(doc, value);
    await batch.commit();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  User? get user => FirebaseAuth.instance.currentUser;

  DocumentReference<Map<String, dynamic>> get userDoc =>
      FirebaseFirestore.instance.collection('users').doc(user?.uid);

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

  /// Creates and increments a [key] value in a [Map] in a [doc].
  Future<void> incrementMapValue(
    DocumentReference<Map<String, dynamic>> doc,
    String map,
    String key,
    int amount,
  ) async {
    await doc.set({
      map: {key: FieldValue.increment(amount)},
    }, SetOptions(merge: true));
  }

  /// Creates and updates a [key] value with a [String] in a [Map] in a [doc].
  Future<void> updateMapValue(
    DocumentReference<Map<String, dynamic>> doc,
    String map,
    String key,
    String value,
  ) async {
    await doc.set({
      map: {key: value},
    }, SetOptions(merge: true));
  }

  /// Creates and resets a [key] value in a [doc].
  Future<void> reset(
    DocumentReference<Map<String, dynamic>> doc,
    String key,
  ) async {
    await doc.set({key: 0}, SetOptions(merge: true));
  }

  /// Deletes a document with a [docName] from a [collection].
  Future<void> deleteDoc(
    CollectionReference<Map<String, dynamic>> collection,
    String docName,
  ) async {
    await collection.doc(docName).delete();
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

  /// Adds a [doc] to a [collection].
  /// Optionally provide a [uuid] to avoid duplicates.
  Future<void> addDoc(
    CollectionReference<Map<String, dynamic>> collection,
    Map<String, dynamic> doc, [
    String? uuid,
  ]) async {
    final docRef = collection.doc(uuid);
    await docRef.set(doc, SetOptions(merge: true));
  }

  /// Adds a batch of [docs] to a [collection].
  /// Optionally provide a [uuid] to avoid duplicates.
  Future<void> addDocBatch(
    CollectionReference<Map<String, dynamic>> collection,
    List<Map<String, dynamic>> docs, [
    String? uuid,
  ]) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in docs) {
      final docRef = collection.doc(uuid);
      batch.set(docRef, doc, SetOptions(merge: true));
    }

    await batch.commit();
  }
}

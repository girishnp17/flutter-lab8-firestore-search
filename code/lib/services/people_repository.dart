import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/person.dart';

/// Thin wrapper around the `people` Firestore collection used for the
/// prefix-search demo. Any Firestore error (e.g. no project configured)
/// is surfaced to the caller instead of crashing the UI.
class PeopleRepository {
  // A getter (not a field initializer) so FirebaseFirestore.instance is only
  // touched when a search actually runs, not when this class is constructed.
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('people');

  Future<List<Person>> searchByName(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final snapshot = await _collection
        .orderBy('name')
        .startAt([trimmed])
        .endAt(['$trimmed'])
        .limit(20)
        .get()
        .timeout(const Duration(seconds: 8));

    return snapshot.docs.map((doc) => Person.fromMap(doc.id, doc.data())).toList();
  }
}

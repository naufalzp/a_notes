import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Get Collection
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // CREATE: Create a note
  Future<void> createNote({
    required String title,
    required String description,
  }) async {
    await notes.add({
      'title': title,
      'description': description,
      'createdAt': Timestamp.now(),
    });
  }

  // READ: Get all notes
  Stream<QuerySnapshot> getNotes() {
    return notes.orderBy('createdAt', descending: true).snapshots();
  }

  // READ: Get a note
  Stream<DocumentSnapshot> getNote({
    required String documentId,
  }) {
    return notes.doc(documentId).snapshots();
  }

  // UPDATE: Update a note
  Future<void> updateNote({
    required String documentId,
    required String title,
    required String description,
  }) async {
    await notes.doc(documentId).update({
      'title': title,
      'description': description,
    });
  }

  // DELETE: Delete a note
  Future<void> deleteNote({
    required String documentId,
  }) async {
    await notes.doc(documentId).delete();
  }
}

import 'package:a_notes/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore service
  final FirestoreService firestoreService = FirestoreService();

  // Text controller
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Open dialog to add note
  void openNoteBox(String? documentId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
            future: _loadNote(documentId),
            builder: (futureContext, snapshot) {
              return AlertDialog(
                title: snapshot.data == null
                    ? const Text('Add Note')
                    : const Text('Edit Note'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController
                          ..text = snapshot.data?['title'] ?? '',
                        decoration: const InputDecoration(
                          hintText: 'Title',
                        ),
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Description',
                        ),
                        minLines: 6,
                        maxLines: 6,
                        maxLength: 1000,
                        keyboardType: TextInputType.multiline,
                        controller: descriptionController
                          ..text = snapshot.data?['description'] ?? '',
                      ),
                      snapshot.data == null
                          ? Container()
                          : ElevatedButton.icon(
                              onPressed: () {
                                firestoreService.deleteNote(
                                  documentId: documentId!,
                                );

                                titleController.clear();
                                descriptionController.clear();

                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete Notes'),
                            )
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (documentId == null) {
                        firestoreService.createNote(
                          title: titleController.text,
                          description: descriptionController.text,
                        );
                      } else {
                        firestoreService.updateNote(
                          documentId: documentId,
                          title: titleController.text,
                          description: descriptionController.text,
                        );
                      }
                      titleController.clear();
                      descriptionController.clear();

                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                  TextButton(
                    onPressed: () {
                      titleController.clear();
                      descriptionController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            });
      },
    );
  }

  Future<Map<String, dynamic>?> _loadNote(String? id) async {
    if (id != null) {
      final doc = await firestoreService.getNote(documentId: id).first;

      // Cast to Map<String, dynamic>
      return doc.data() as Map<String, dynamic>?;
    }

    // Return null if no document
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Notes')),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Note',
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () => openNoteBox(null),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotes(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                return Card(
                  elevation: 4, // Add elevation for a shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Set border radius
                  ),
                  color: Colors.white, // Set background color

                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.all(16), // Adjust content padding
                    title: Text(
                      data['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      data['description'],
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () => openNoteBox(document.id),
                      icon: const Icon(Icons.edit),
                      color: Colors.blue, // Set icon color
                    ),
                  ),
                );
              }).toList(),
            );
          } else {
            return const Center(child: Text('No notes...'));
          }
        },
      ),
    );
  }
}

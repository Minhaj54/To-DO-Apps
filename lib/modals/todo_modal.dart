import 'package:cloud_firestore/cloud_firestore.dart';

class ToDo {
  String? id;
  String? title;
  String? description;
  bool? isCompleted;
  Timestamp? createdAt;

  ToDo({
     this.id,
     this.title,
     this.description,
    this.isCompleted = false,
     Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  // Factory constructor to create a ToDo object from Firestore DocumentSnapshot
  factory ToDo.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ToDo(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      isCompleted: data['isCompleted'],
      createdAt: data['createdAt'],
    );
  }

  // Convert ToDo object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
    };
  }

  // Write a new ToDo to Firestore
  Future<void> saveToFirestore() async {
    CollectionReference todos = FirebaseFirestore.instance.collection('todos');
    if (id == null) {
      DocumentReference docRef = await todos.add(toMap());
      id = docRef.id;
    } else {
      await todos.doc(id).set(toMap());
    }
  }

  // Update an existing ToDo in Firestore
  Future<void> updateInFirestore() async {
    CollectionReference todos = FirebaseFirestore.instance.collection('todos');
    await todos.doc(id).update(toMap());
  }

  // Delete a ToDo from Firestore
  Future<void> deleteFromFirestore() async {
    CollectionReference todos = FirebaseFirestore.instance.collection('todos');
    await todos.doc(id).delete();
  }
}

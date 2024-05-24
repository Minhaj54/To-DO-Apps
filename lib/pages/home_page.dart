import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../modals/todo_modal.dart';

class ToDoHome extends StatefulWidget {
  const ToDoHome({super.key});

  @override
  State<ToDoHome> createState() => _ToDoHomeState();
}

class _ToDoHomeState extends State<ToDoHome> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Min To-Dos',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),centerTitle: true,backgroundColor: Colors.deepPurpleAccent,),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () =>_showAlertDialog(context),
        child: const Icon(Icons.add,color: Colors.white,),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('todos').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<ToDo>? todos = snapshot.data?.docs
                    .map((doc) => ToDo.fromDocumentSnapshot(doc))
                    .toList();

                return ListView.builder(
                  itemCount: todos?.length,
                  itemBuilder: (context, index) {
                    final todo = todos![index];
                    return
                      Card(
                        child: ListTile(
                          tileColor: Colors.yellowAccent,
                          title: Text(todo.title as String),
                          subtitle: Text(todo.description as String),
                          trailing: Checkbox(
                              value: todo.isCompleted,
                              onChanged: (bool? value) async {
                                setState(() {
                                  todo.isCompleted = value!;
                                });

                                await todo.updateInFirestore();
                              }),
                          onLongPress: () async {
                            await todo.deleteFromFirestore();
                          },
                        ),
                      );
                  }
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a task !!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String title = titleController.text;
                String description = descriptionController.text;

                ToDo newToDo = ToDo(
                  title: title,
                  description: description,
                );
                await newToDo.saveToFirestore();

                // Clear the text fields
                titleController.clear();
                descriptionController.clear();

                Navigator.pop(context);
              },
              child: const Text('Add ToDo'),
            ),
          ],
        );
      },
    );
  }
}

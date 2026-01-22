import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final taskController = TextEditingController();

  final CollectionReference tasks =
      FirebaseFirestore.instance.collection('tasks');

  void addTask() {
    if (taskController.text.isEmpty) return;
    tasks.add({
      'title': taskController.text,
      'createdAt': Timestamp.now(),
      'user': FirebaseAuth.instance.currentUser!.email,
    });
    taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(hintText: 'Enter task'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addTask,
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasks
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['title']),
                      subtitle: Text(doc['user']),
                    );
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

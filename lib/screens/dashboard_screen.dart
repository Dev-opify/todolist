import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _taskController = TextEditingController();

  late final CollectionReference _tasksCollection;

  @override
  void initState() {
    super.initState();
    final userId = _auth.currentUser!.uid;
    _tasksCollection = _firestore.collection('users').doc(userId).collection('tasks');
  }

  void _addTask() {
    if (_taskController.text.isEmpty) return;

    _tasksCollection.add({
      'content': _taskController.text,
      'isDone': false,
      'createdAt': Timestamp.now(),
    });
    _taskController.clear();
    Navigator.of(context).pop();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(
          controller: _taskController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'What do you need to do?'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: _addTask, child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _tasksCollection.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No tasks yet. Add one! ✨", style: TextStyle(fontSize: 18)),
            );
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskData = task.data() as Map<String, dynamic>;

              return ListTile(
                leading: Checkbox(
                  value: taskData['isDone'],
                  onChanged: (value) => _tasksCollection.doc(task.id).update({'isDone': value}),
                ),
                title: Text(
                  taskData['content'],
                  style: TextStyle(
                    decoration: taskData['isDone'] ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _tasksCollection.doc(task.id).delete(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
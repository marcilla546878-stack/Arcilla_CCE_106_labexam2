import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FoodListApp());
}

class FoodListApp extends StatelessWidget {
  const FoodListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food List',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const FoodListPage(),
    );
  }
}

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  final TextEditingController _taskController = TextEditingController();
  final CollectionReference _foodCollection =
  FirebaseFirestore.instance.collection('foods');

  /// ✅ CREATE
  void _addTask() {
    final task = _taskController.text.trim();
    if (task.isNotEmpty) {
      _foodCollection.add({'name': task});
      _taskController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task cannot be empty")),
      );
    }
  }

  /// ✅ UPDATE
  void _editTask(String id, String currentName) {
    final editController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Task"),
        content: TextField(controller: editController),
        actions: [
          TextButton(
            onPressed: () {
              final newName = editController.text.trim();
              if (newName.isNotEmpty) {
                _foodCollection.doc(id).update({'name': newName});
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// ✅ DELETE
  void _deleteTask(String id) {
    _foodCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Food List")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: "Add a new task...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
          Expanded(
            /// ✅ READ (auto-updates with StreamBuilder)
            child: StreamBuilder<QuerySnapshot>(
              stream: _foodCollection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tasks = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final doc = tasks[index];
                    final taskName = doc['name'];
                    return ListTile(
                      title: Text(taskName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _editTask(doc.id, taskName),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(doc.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

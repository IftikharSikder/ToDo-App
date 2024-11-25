import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/screens/search_page.dart';

import '../api_client/api_req.dart';

class TodoHomePage extends ConsumerWidget {
  const TodoHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newTaskController = TextEditingController();
    final taskUpdateController = TextEditingController();
    final searchController = TextEditingController();

    final providedTask = ref.watch(taskProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Todo App"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                  label: const Text("Search"),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                      onPressed: () async {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SearchPage(searchText: searchController.text)));
                      },
                      icon: const Icon(Icons.search))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: TextFormField(
              controller: newTaskController,
              decoration: InputDecoration(
                  label: const Text("New Task"),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                      onPressed: () async {
                        await addNewTask(newTaskController.text,context);
                        ref.invalidate(taskProvider);
                      },
                      icon: const Icon(Icons.add))),
            ),
          ),
          Expanded(
            child: providedTask.when(
              data: (taskData) {
                return ListView.builder(
                    itemCount: taskData.length,
                    itemBuilder: (context, index) {
                      final task = taskData[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(task.id.toString()),
                        ),
                        title: Text(
                          task.description.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(task.status.toString()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                taskUpdateController.text = task.description.toString();
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Delete Task"),
                                        content: TextFormField(
                                          controller: taskUpdateController,
                                          decoration: const InputDecoration(),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                "Cancel",
                                              )),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape:
                                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  backgroundColor: Colors.blue),
                                              onPressed: () async {
                                                await updateTask(task.id.toString(), taskUpdateController.text,context);
                                                ref.invalidate(taskProvider);
                                                if(!context.mounted)return;
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Update")),
                                        ],
                                      );
                                    });
                              },
                              icon: const Icon(Icons.update),
                              color: Colors.green,
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Delete Task"),
                                        content: const Text("Do you want to delete?"),
                                        actions: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape:
                                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  backgroundColor: Colors.blue),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("No", style: TextStyle(color: Colors.white))),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape:
                                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  backgroundColor: Colors.red),
                                              onPressed: () async {
                                                await deleteTask(task.id);
                                                ref.invalidate(taskProvider);
                                                if(!context.mounted)return;
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                "Yes",
                                                style: TextStyle(color: Colors.white),
                                              )),
                                        ],
                                      );
                                    });
                              },
                              icon: const Icon(Icons.delete),
                              color: Colors.redAccent,
                            ),
                          ],
                        ),
                      );
                    });
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              error: (error, stack) => Center(child: Text("Error: $error")),
            ),
          ),
        ],
      ),
    );
  }
}

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
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Todo App",
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("New Task"),
                content: TextFormField(
                  controller: newTaskController,
                  decoration: const InputDecoration(),
                ),
                actions: [
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width*.57,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: Colors.green),
                            onPressed: () async{
                              await addNewTask(newTaskController.text, context);
                              ref.invalidate(taskProvider);
                              if(!context.mounted)return;
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "Add",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                    ],
                  )
                ],
              );
            });
      },child: const Icon(Icons.add),),
      body: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12,20,12,20),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white12,
                      label: const Text(
                        "Search",
                        style: TextStyle(color: Colors.black),
                      ),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage(searchText: searchController.text)));
                          },
                          icon: const Icon(Icons.search))),
                ),
              ),
            ],
          ),
          Expanded(
            child: providedTask.when(
              data: (taskData) {
                return ListView.builder(
                    itemCount: taskData.length,
                    itemBuilder: (context, index) {
                      final task = taskData[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple,
                            child: Text(
                              task.id.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
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
                                          title: const Text("Update Task"),
                                          content: TextFormField(
                                            controller: taskUpdateController,
                                            decoration: const InputDecoration(),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10)),
                                                        backgroundColor: Colors.green),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text(
                                                      "Cancel",
                                                      style: TextStyle(color: Colors.white),
                                                    )),
                                                ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10)),
                                                        backgroundColor: Colors.blue),
                                                    onPressed: () async {
                                                      await updateTask(
                                                          task.id.toString(), taskUpdateController.text, context);
                                                      ref.invalidate(taskProvider);
                                                      if (!context.mounted) return;
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text(
                                                      "Update",
                                                      style: TextStyle(color: Colors.white),
                                                    )),
                                              ],
                                            )
                                          ],
                                        );
                                      });
                                },
                                icon: const Icon(Icons.edit),
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
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10)),
                                                        backgroundColor: Colors.blue),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text("No ", style: TextStyle(color: Colors.white))),
                                                ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10)),
                                                        backgroundColor: Colors.red),
                                                    onPressed: () async {
                                                      await deleteTask(task.id);
                                                      ref.invalidate(taskProvider);
                                                      if (!context.mounted) return;
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text(
                                                      "Yes",
                                                      style: TextStyle(color: Colors.white),
                                                    )),
                                              ],
                                            )
                                          ],
                                        );
                                      });
                                },
                                icon: const Icon(Icons.delete),
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              error: (error, stack) => const Center(
                  child: Card(
                color: Colors.white,
                child: Center(
                  child: SizedBox(
                    height: 200,
                    width: 250,
                    child: Text(
                      "Sorry No Data Found! Check Your connection",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/api_client/api_req.dart';
import 'package:todo_app/providers/task_provider.dart';
class SearchPage extends ConsumerWidget {
  final String searchText;

  const SearchPage({super.key, required this.searchText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchOutput = ref.watch(searchTaskProvider(searchText));

    final taskUpdateController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Search Page",style: TextStyle(color: Colors.white),),
      ),
      body: searchOutput.when(
        data: (searchResult) {
          return (searchResult.isEmpty)
              ? const Center(child: Text("No Result Found", style: TextStyle(fontSize: 25),),)
              : ListView.builder(
              itemCount: searchResult.length,
              itemBuilder: (context, index) {
                final r = searchResult[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text(
                        r.id.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      r.description.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(r.status.toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            taskUpdateController.text = r.description.toString();
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
                                        mainAxisAlignment : MainAxisAlignment. spaceAround,
                                        children: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape:
                                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  backgroundColor: Colors.green
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                "Cancel",style: TextStyle(color: Colors.white),
                                              )),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape:
                                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  backgroundColor: Colors.blue),
                                              onPressed: () async {
                                                await updateTask(
                                                    r.id.toString(), taskUpdateController.text, context);
                                                ref.invalidate(searchTaskProvider);
                                                ref.invalidate(taskProvider);
                                                if (!context.mounted) return;
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Update",style: TextStyle(color: Colors.white),)),
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
                                        mainAxisAlignment:MainAxisAlignment.spaceAround,
                                        children: [
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
                                                await deleteTask(r.id);
                                                ref.invalidate(searchTaskProvider);
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
        error: (error, stack) => Center(child: Text("Error: $error")),
      ),
    );
  }
}

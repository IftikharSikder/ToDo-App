import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/providers/task_provider.dart';
class SearchPage extends ConsumerWidget {
  final String searchText;

  const SearchPage({super.key, required this.searchText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchOutput = ref.watch(searchTaskProvider(searchText));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Search Page",style: TextStyle(color: Colors.white),),
      ),
      body: searchOutput.when(
        data: (searchResult) {
          return ListView.builder(
            itemCount: searchResult.length,
            itemBuilder: (context, index) {
              final r = searchResult[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(r.id.toString()),
                ),
                title: Text(r.description.toString()),
                subtitle: Text(r.status.toString()),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text("Error: $error"),
        ),
      ),
    );
  }
}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/api_client/api_req.dart';
import 'package:todo_app/models/task_model.dart';


final taskProvider = FutureProvider<List<Task>>((ref) async {
   return await taskGetReq();
});

final searchTaskProvider = FutureProvider.family<List<Task>, String>((ref, searchText) async {
   return await searchTask(searchText);
});
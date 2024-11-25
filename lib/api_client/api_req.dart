import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/models/task_model.dart';

var rootUrl = "http://192.168.0.172:8080/task/";

Future<List<Task>> fetchTask({String? reqTypeIndicator}) async {
  var url = reqTypeIndicator == null
      ? Uri.parse("${rootUrl}all")
      : Uri.parse("${rootUrl}search?keyword=$reqTypeIndicator");

  var headers = {"Content-Type": "application/json"};
  var response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    var responseResult = json.decode(response.body) as List;
    return responseResult.map((json) => Task.fromJson(json)).toList();
  } else {
    throw Exception("Fetch Incomplete");
  }
}

Future deleteTask(var deleteItemIndex) async {
  String link = "$rootUrl$deleteItemIndex/delete";
  var url = Uri.parse(link);
  var response = await http.delete(url);
  if (response.statusCode != 200) {
    throw Exception("Failed to delete task");
  }
}

Future addNewTask(taskDescription, context) async {
  var url = Uri.parse("${rootUrl}create");
  var postHeader = {"Content-Type": "application/json"};
  Map taskMap = {"description": taskDescription};
  var postBody = json.encode(taskMap);
  var response = await http.post(url, headers: postHeader, body: postBody);
  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Task Added Successfully")));
  }
}

Future updateTask(taskId, updatedTaskText, context) async {
  var url = Uri.parse("${rootUrl + taskId}/update");
  var updatedPostHeader = {"Content-Type": "application/json"};
  Map updatedTaskMap = {"description": updatedTaskText};

  var response = await http.put(url, headers: updatedPostHeader, body: json.encode(updatedTaskMap));
  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update Successfully")));
  } else {
    throw Exception('Failed to updated');
  }
}

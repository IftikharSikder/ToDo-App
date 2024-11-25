class Task {
  int? id;
  String? description;
  String? status;

  Task({this.id, this.description, this.status});

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['description'] = description;
    data['status'] = status;
    return data;
  }
}

class ReminderModel {
  String? title;
  String? description;
  String? date;
  String? time;
  String? priority;

  ReminderModel(
      {this.title, this.description, this.date, this.time, this.priority});

  ReminderModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    date = json['date'];
    time = json['time'];
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['date'] = date;
    data['time'] = time;
    data['priority'] = priority;
    return data;
  }
}

class Task {
  final String name;
  final String event;
  final String dueDate;

  Task(this.name, this.event, this.dueDate);

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'event': event,
      'dueDate': dueDate,
    };
  }

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      json['name'] as String,
      json['event'] as String,
      json['dueDate'] as String,
    );
  }
}
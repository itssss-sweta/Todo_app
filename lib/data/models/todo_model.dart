class Todo {
  final int? id;
  final String? title;
  final String? description;
  final bool? isCompleted;
  final DateTime? deadline;
  final DateTime? createdAt;

  const Todo({
    this.id,
    this.title,
    this.description,
    this.isCompleted,
    this.deadline,
    this.createdAt,
  });

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? deadline,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

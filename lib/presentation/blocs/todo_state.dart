import 'package:equatable/equatable.dart';
import 'package:todo_app/data/models/todo_model.dart';

abstract class TodoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> pendingTodos;
  final List<Todo> completedTodos;

  TodoLoaded({
    required this.pendingTodos,
    required this.completedTodos,
  });

  @override
  List<Object?> get props => [pendingTodos, completedTodos];
}

class TodoError extends TodoState {
  final String message;

  TodoError(this.message);

  @override
  List<Object?> get props => [message];
}

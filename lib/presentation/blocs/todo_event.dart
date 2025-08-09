import 'package:equatable/equatable.dart';
import 'package:todo_app/data/models/todo_model.dart';

abstract class TodoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTodos extends TodoEvent {
  final String query;

  FetchTodos({this.query = ''});

  @override
  List<Object?> get props => [query];
}

class AddTodo extends TodoEvent {
  final Todo todo;

  AddTodo(this.todo);

  @override
  List<Object?> get props => [todo];
}

class UpdateTodo extends TodoEvent {
  final Todo todo;

  UpdateTodo(this.todo);

  @override
  List<Object?> get props => [todo];
}

class DeleteTodo extends TodoEvent {
  final int id;

  DeleteTodo(this.id);

  @override
  List<Object?> get props => [id];
}

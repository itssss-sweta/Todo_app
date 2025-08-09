import 'package:dartz/dartz.dart';
import 'package:todo_app/core/error/failure.dart';
import 'package:todo_app/data/models/todo_model.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<Todo>>> getTodos(int page, int limit);
  Future<Either<Failure, void>> addTodo(Todo todo);
  Future<Either<Failure, void>> updateTodo(Todo todo);
  Future<Either<Failure, void>> deleteTodo(int id);
}

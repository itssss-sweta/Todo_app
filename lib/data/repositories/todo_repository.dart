import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:todo_app/core/error/failure.dart';
import 'package:todo_app/data/data_sources/local/database.dart' as db;
import 'package:todo_app/data/models/todo_model.dart';
import 'package:todo_app/domain/repositories/todo_repository.dart';

class TodoDriftRepository implements TodoRepository {
  final db.AppDatabase database;

  TodoDriftRepository(this.database);

  @override
  Future<Either<Failure, List<Todo>>> getTodos(int page, int limit) async {
    try {
      final todoData = await database.getTodos(page, limit);
      final todos = todoData
          .map((data) => Todo(
                id: data.id,
                title: data.title,
                description: data.description,
                isCompleted: data.isCompleted,
                deadline: data.deadline,
                createdAt: data.createdAt,
              ))
          .toList();
      return Right(todos);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTodo(Todo todo) async {
    try {
      final existingTodo = await database.getTodoByTitle(todo.title ?? '');
      if (existingTodo != null) {
        return Left(DatabaseFailure(
            'A task with the title "${todo.title}" already exists'));
      }
      await database.insertTodo(db.TodosCompanion(
        title: Value(todo.title ?? ''),
        description: Value(todo.description ?? ''),
        isCompleted: Value(todo.isCompleted ?? false),
        deadline: Value(todo.deadline ?? DateTime.now()),
        createdAt: Value(todo.createdAt ?? DateTime.now()),
      ));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTodo(Todo todo) async {
    try {
      final existingTodo = await database.getTodoByTitle(todo.title ?? '');
      if (existingTodo != null && existingTodo.id != todo.id) {
        return Left(DatabaseFailure(
            'A task with the title "${todo.title}" already exists'));
      }
      await database.updateTodo(db.Todo(
        id: todo.id ?? 0,
        title: todo.title ?? '',
        description: todo.description ?? '',
        isCompleted: todo.isCompleted ?? false,
        deadline: todo.deadline ?? DateTime.now(),
        createdAt: todo.createdAt ?? DateTime.now(),
      ));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodo(int id) async {
    try {
      await database.deleteTodo(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

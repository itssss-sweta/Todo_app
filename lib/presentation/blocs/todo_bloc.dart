import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/data/data_sources/local/database.dart' as db;
import 'package:todo_app/data/models/todo_model.dart';
import 'package:todo_app/data/repositories/todo_repository.dart';
import 'package:todo_app/presentation/blocs/todo_event.dart';
import 'package:todo_app/presentation/blocs/todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoDriftRepository repository = TodoDriftRepository(db.AppDatabase());
  List<Todo> allTodos = [];

  TodoBloc() : super(TodoInitial()) {
    on<FetchTodos>(_onFetchTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
  }

  Future<void> _onFetchTodos(FetchTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final result = await repository.getTodos(1, 10);
      final todos = result.fold(
        (failure) => throw Exception(failure.message),
        (todos) => todos,
      );
      allTodos = todos;
      final filteredTodos = event.query.isEmpty
          ? todos
          : todos
              .where((todo) =>
                  todo.title!
                      .toLowerCase()
                      .contains(event.query.toLowerCase()) ||
                  todo.description!
                      .toLowerCase()
                      .contains(event.query.toLowerCase()))
              .toList();
      emit(TodoLoaded(
        pendingTodos: filteredTodos
            .where((todo) => !(todo.isCompleted ?? false))
            .toList(),
        completedTodos:
            filteredTodos.where((todo) => todo.isCompleted ?? false).toList(),
      ));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      final result = await repository.addTodo(event.todo);
      result.fold(
        (failure) => emit(TodoError(failure.message)),
        (_) => add(FetchTodos(query: '')),
      );
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      final result = await repository.updateTodo(event.todo);
      result.fold(
        (failure) => emit(TodoError(failure.message)),
        (_) => add(FetchTodos(query: '')),
      );
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      final result = await repository.deleteTodo(event.id);
      result.fold(
        (failure) => emit(TodoError(failure.message)),
        (_) => add(FetchTodos(query: '')),
      );
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }
}

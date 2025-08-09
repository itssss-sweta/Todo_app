import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/constants/app_colors.dart';
import 'package:todo_app/data/models/todo_model.dart';
import 'package:todo_app/presentation/blocs/todo_bloc.dart';
import 'package:todo_app/presentation/blocs/todo_event.dart';
import 'package:todo_app/presentation/blocs/todo_state.dart';
import 'package:todo_app/presentation/widgets/todo_error_state.dart';
import 'package:todo_app/presentation/widgets/todo_list_items.dart';

class TodoListView extends StatelessWidget {
  final bool isCompleted;
  final bool isLoading;
  final String searchQuery;
  final Function(Todo) onEdit;
  final Function(int) onDelete;

  const TodoListView({
    super.key,
    required this.isCompleted,
    required this.isLoading,
    required this.searchQuery,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoBloc, TodoState>(
      listener: (context, state) {
        if (state is TodoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TodoLoading) {
          return _buildLoadingTodos(context);
        }

        if (state is TodoError) {
          return TodoErrorState(
            message: state.message,
            onRetry: () =>
                context.read<TodoBloc>().add(FetchTodos(query: searchQuery)),
          );
        }

        if (state is TodoLoaded) {
          final todos = isCompleted ? state.completedTodos : state.pendingTodos;
          if (todos.isEmpty) {
            return _buildEmptyState(context);
          }

          return TodoListItems(
            todos: todos,
            isLoading: isLoading,
            onEdit: onEdit,
            onDelete: onDelete,
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildLoadingTodos(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading todos...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isCompleted ? AppColors.secondary : AppColors.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.celebration_outlined
                      : Icons.task_alt_outlined,
                  size: 48,
                  color: isCompleted ? AppColors.secondary : AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isCompleted ? 'No completed tasks yet' : 'No pending tasks',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                isCompleted
                    ? 'Complete some tasks to see them here'
                    : 'Add a new task to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

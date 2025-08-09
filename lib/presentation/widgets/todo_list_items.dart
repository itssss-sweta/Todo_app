import 'package:flutter/material.dart';
import 'package:todo_app/core/constants/app_colors.dart';
import 'package:todo_app/data/models/todo_model.dart';
import 'package:todo_app/presentation/widgets/todo_item.dart';

class TodoListItems extends StatelessWidget {
  final List<Todo> todos;
  final bool isLoading;
  final Function(Todo) onEdit;
  final Function(int) onDelete;

  const TodoListItems(
      {super.key,
      required this.todos,
      required this.isLoading,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: todos.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == todos.length) {
            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading more...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TodoItem(
              todo: todos[index],
              onEdit: () => onEdit(todos[index]),
              onDelete: () => onDelete(todos[index].id ?? 0),
            ),
          );
        },
      ),
    );
  }
}

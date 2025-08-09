import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/constants/app_colors.dart';
import 'package:todo_app/data/models/todo_model.dart';
import 'package:todo_app/presentation/blocs/todo_bloc.dart';
import 'package:todo_app/presentation/blocs/todo_event.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onEdit,
    required this.onDelete,
  });

  void _toggleCompletion(BuildContext context) {
    final updatedTodo = Todo(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isCompleted: !(todo.isCompleted ?? false),
      deadline: todo.deadline,
      createdAt: todo.createdAt,
    );
    context.read<TodoBloc>().add(UpdateTodo(updatedTodo));
  }

  bool get _isOverdue {
    if (todo.deadline == null || (todo.isCompleted ?? false)) return false;
    return todo.deadline!.isBefore(DateTime.now());
  }

  bool get _isDueSoon {
    if (todo.deadline == null || (todo.isCompleted ?? false)) return false;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return todo.deadline!.isBefore(tomorrow) && todo.deadline!.isAfter(now);
  }

  Color _getPriorityColor() {
    if (todo.isCompleted ?? false) return AppColors.secondary;
    if (_isOverdue) return AppColors.error;
    if (_isDueSoon) return AppColors.warning;
    return AppColors.primary;
  }

  String _getDeadlineText() {
    if (todo.deadline == null) return '';

    final now = DateTime.now();
    final deadline = todo.deadline!;
    final difference = deadline.difference(now).inDays;

    if (_isOverdue) {
      final overdueDays = now.difference(deadline).inDays;
      return overdueDays == 0
          ? 'Due today'
          : 'Overdue by $overdueDays day${overdueDays > 1 ? 's' : ''}';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $difference days';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isCompleted = todo.isCompleted ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppColors.secondary.withOpacity(0.3)
              : _getPriorityColor().withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleCompletion(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Custom Checkbox
                    GestureDetector(
                      onTap: () => _toggleCompletion(context),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? _getPriorityColor()
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getPriorityColor(),
                            width: 2,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title and Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  todo.title ?? '',
                                  style: textTheme.titleMedium?.copyWith(
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isCompleted
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              // Priority/Status Badge
                              if (!isCompleted && (_isOverdue || _isDueSoon))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor().withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isOverdue
                                            ? Icons.warning_rounded
                                            : Icons.schedule_rounded,
                                        size: 12,
                                        color: _getPriorityColor(),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isOverdue ? 'Overdue' : 'Due Soon',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: _getPriorityColor(),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 12,
                                        color: AppColors.secondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Completed',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Description
                if ((todo.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Text(
                      todo.description ?? '',
                      style: textTheme.bodyMedium?.copyWith(
                        color: isCompleted
                            ? colorScheme.onSurfaceVariant.withOpacity(0.7)
                            : colorScheme.onSurfaceVariant,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],

                // Footer with deadline and actions
                if (todo.deadline != null || !isCompleted) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Row(
                      children: [
                        // Deadline info
                        if (todo.deadline != null)
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: _getPriorityColor(),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getDeadlineText(),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: _getPriorityColor(),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit button
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                color: AppColors.primary,
                                onPressed: onEdit,
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Delete button
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete_rounded, size: 18),
                                color: AppColors.error,
                                onPressed: onDelete,
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

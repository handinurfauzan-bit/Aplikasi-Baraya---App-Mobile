import 'package:flutter/material.dart';
import '../models/models.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final String? eventTitle;
  final List<User> assignees;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.eventTitle,
    this.assignees = const [],
    required this.onToggle,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDone = task.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isDone ? 0 : 1,
      color: isDone
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDone
              ? Colors.transparent
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? onToggle,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: const EdgeInsets.only(top: 2, right: 12),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: isDone ? Colors.green : colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),


              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eventTitle != null && eventTitle!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          eventTitle!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      task.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone
                            ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                    if (assignees.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: assignees.map((user) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                                  : colorScheme.secondaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                                  child: Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  user.name.split(' ').first,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),


              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: colorScheme.outline),
                  tooltip: 'Hapus Tugas',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

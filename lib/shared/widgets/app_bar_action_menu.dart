import 'package:flutter/material.dart';

class AppBarMenuAction {
  const AppBarMenuAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.onSelected,
    this.isDestructive = false,
  });

  final String id;
  final String label;
  final IconData icon;
  final VoidCallback onSelected;
  final bool isDestructive;
}

class AppBarActionMenu extends StatelessWidget {
  const AppBarActionMenu({
    super.key,
    required this.actions,
    this.tooltip = 'More actions',
  });

  final List<AppBarMenuAction> actions;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      tooltip: tooltip,
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (selectedId) {
        for (final action in actions) {
          if (action.id == selectedId) {
            action.onSelected();
            return;
          }
        }
      },
      itemBuilder: (_) => actions
          .map(
            (action) => PopupMenuItem<String>(
              value: action.id,
              child: Row(
                children: [
                  Icon(
                    action.icon,
                    size: 20,
                    color: action.isDestructive
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      action.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: action.isDestructive
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

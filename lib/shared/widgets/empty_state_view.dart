import 'package:flutter/material.dart';
import 'package:milexact/shared/constants/app_spacing.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useCompactLayout =
            constraints.hasBoundedHeight && constraints.maxHeight < 180;
        final iconSize = useCompactLayout ? 32.0 : 44.0;
        final outerPadding = useCompactLayout ? AppSpacing.md : AppSpacing.lg;
        final blockSpacing = useCompactLayout ? AppSpacing.sm : AppSpacing.md;
        final bodySpacing = useCompactLayout ? 6.0 : AppSpacing.xs;

        final content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize),
            SizedBox(height: blockSpacing),
            Text(
              title,
              style: useCompactLayout
                  ? theme.textTheme.titleMedium
                  : theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: bodySpacing),
            Text(
              description,
              style: useCompactLayout
                  ? theme.textTheme.bodySmall
                  : theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: blockSpacing),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        );

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.hasBoundedWidth ? constraints.maxWidth : 0,
              minHeight: constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : 0,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(outerPadding),
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/shared/constants/app_spacing.dart';

class ReticleProfilePicker extends StatelessWidget {
  const ReticleProfilePicker({
    super.key,
    required this.selectedProfile,
    required this.reticleType,
    required this.referenceDimension,
    required this.onSelected,
  });

  final ReticleProfile selectedProfile;
  final ReticleType reticleType;
  final TargetDimensionType referenceDimension;
  final ValueChanged<ReticleProfile> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _showPickerSheet(context),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerTheme.color ?? Colors.white10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedProfile.label,
                          style: theme.textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          selectedProfile.description,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    ),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: AppSpacing.sm),
              // _GuideLine(
              //   leading: '↕ Height hashes',
              //   value: '${selectedProfile.heightGuide} ${reticleType.label}',
              //   isActive: referenceDimension == TargetDimensionType.height,
              // ),
              // const SizedBox(height: AppSpacing.xs),
              // _GuideLine(
              //   leading: '↔ Width hashes',
              //   value: '${selectedProfile.widthGuide} ${reticleType.label}',
              //   isActive: referenceDimension == TargetDimensionType.width,
              // ),
              // const SizedBox(height: AppSpacing.sm),
              // Text(
              //   'Reference dimension: ${referenceDimension.label}',
              //   style: theme.textTheme.bodySmall,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPickerSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<ReticleProfile>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerTheme.color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Select Reticle Format', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Pick the reticle style that best matches what you see in the scope. MIL and MRAD stay separate above.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: ReticleProfile.values.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final profile = ReticleProfile.values[index];
                    return _ReticleProfileOptionTile(
                      profile: profile,
                      reticleType: reticleType,
                      isSelected: profile == selectedProfile,
                      onTap: () => Navigator.of(context).pop(profile),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      onSelected(selected);
    }
  }
}

class _ReticleProfileOptionTile extends StatelessWidget {
  const _ReticleProfileOptionTile({
    required this.profile,
    required this.reticleType,
    required this.isSelected,
    required this.onTap,
  });

  final ReticleProfile profile;
  final ReticleType reticleType;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.14)
                : theme.inputDecorationTheme.fillColor,
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : theme.dividerTheme.color ?? Colors.white10,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.label, style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        profile.description,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        profile.guideLabel(
                          dimension: TargetDimensionType.height,
                          reticleType: reticleType,
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        profile.guideLabel(
                          dimension: TargetDimensionType.width,
                          reticleType: reticleType,
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? colorScheme.primary
                      : theme.textTheme.bodySmall?.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

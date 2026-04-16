import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/dope_profile.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/modules/dope/controllers/dope_profiles_controller.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/formatters.dart';
import 'package:milexact/shared/widgets/empty_state_view.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

class DopeProfilesScreen extends GetView<DopeProfilesController> {
  const DopeProfilesScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return TacticalScaffold(
      title: 'DOPE Profiles',
      currentRoute: AppRoutes.dopeProfiles,
      showBottomNav: showBottomNav,
      actions: [
        IconButton(
          tooltip: 'Add Profile',
          onPressed: _openEditor,
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ],
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            LabeledTextField(
              label: 'Search Profiles',
              hint: 'Search rifle or caliber',
              onChanged: controller.setSearchQuery,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Obx(() {
                final profiles = controller.filteredProfiles;
                if (profiles.isEmpty) {
                  return EmptyStateView(
                    title: 'No DOPE profiles',
                    description:
                        'Create a manual DOPE library for your rifles. Nothing here is calculated automatically.',
                    icon: Icons.straighten_outlined,
                    actionLabel: 'Add Profile',
                    onAction: _openEditor,
                  );
                }

                return ListView.separated(
                  itemCount: profiles.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    return _DopeProfileTile(
                      profile: profile,
                      onEdit: () => _openEditor(profile: profile),
                      onDelete: () => _confirmDelete(profile),
                      onSetActive: () =>
                          controller.setActiveProfile(profile.id),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor({DopeProfile? profile}) async {
    await Get.toNamed(AppRoutes.dopeProfileEdit, arguments: profile);
  }

  Future<void> _confirmDelete(DopeProfile profile) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Delete "${profile.rifleName}" and all its saved rows?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await controller.deleteProfile(profile.id);
      Get.snackbar('Deleted', 'DOPE profile removed.');
    }
  }
}

class _DopeProfileTile extends StatelessWidget {
  const _DopeProfileTile({
    required this.profile,
    required this.onEdit,
    required this.onDelete,
    required this.onSetActive,
  });

  final DopeProfile profile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(side: BorderSide.none),
            collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
            tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    profile.rifleName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (profile.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    ),
                    child: Text('ACTIVE', style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
            subtitle: Text(
              '${profile.caliber} • ${AppFormatters.number(profile.bulletGrain)} gr • ${AppFormatters.number(profile.velocityFps)} fps',
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: profile.entries
                      .map(
                        (entry) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.08,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.18,
                              ),
                            ),
                          ),
                          child: Text(
                            '${AppFormatters.number(entry.distanceValue)} ${entry.distanceUnit.shortLabel} • ${entry.dropValue}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSetActive,
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Set Active'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

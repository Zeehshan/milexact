import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/range_card_entry.dart';
import 'package:milexact/modules/range_card/controllers/range_card_list_controller.dart';
import 'package:milexact/modules/range_card/widgets/range_card_tile.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/widgets/empty_state_view.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

class RangeCardListScreen extends GetView<RangeCardListController> {
  const RangeCardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TacticalScaffold(
      title: 'Range Card',
      currentRoute: AppRoutes.rangeCardList,
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            LabeledTextField(
              label: 'Search Entries',
              hint: 'Search target, DOPE, wind, or notes',
              onChanged: controller.setSearchQuery,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Obx(() {
                final entries = controller.filteredEntries;
                if (entries.isEmpty) {
                  return const EmptyStateView(
                    title: 'No range card entries',
                    description:
                        'Calculate distance on the main screen and save the result here for field reference.',
                    icon: Icons.view_agenda_outlined,
                  );
                }

                return ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return RangeCardTile(
                      entry: entry,
                      onTap: () => controller.openEntry(entry),
                      onDelete: () => _confirmDelete(entry),
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

  Future<void> _confirmDelete(RangeCardEntry entry) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Delete "${entry.targetName}" from the range card?'),
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
      await controller.deleteEntry(entry.id);
    }
  }
}

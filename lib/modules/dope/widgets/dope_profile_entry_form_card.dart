import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/modules/dope/controllers/dope_profile_edit_controller.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';
import 'package:milexact/shared/widgets/selector_chips.dart';

class DopeProfileEntryFormCard extends StatelessWidget {
  const DopeProfileEntryFormCard({
    super.key,
    required this.index,
    required this.item,
    required this.onDelete,
    required this.onUnitChanged,
  });

  final int index;
  final DopeEntryFormItem item;
  final VoidCallback onDelete;
  final ValueChanged<UnitType> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Profile Row ${index + 1}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Remove'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 420;

                if (stacked) {
                  return Column(
                    children: [
                      LabeledTextField(
                        controller: item.distanceController,
                        label: 'Distance',
                        hint: '500',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LabeledTextField(
                        controller: item.dropController,
                        label: 'Drop',
                        hint: '3.2 MIL',
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: LabeledTextField(
                        controller: item.distanceController,
                        label: 'Distance',
                        hint: '500',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: LabeledTextField(
                        controller: item.dropController,
                        label: 'Drop',
                        hint: '3.2 MIL',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Distance Unit', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            SelectorChips<UnitType>(
              options: const [UnitType.meter, UnitType.yard],
              selectedValue: item.distanceUnit,
              labelBuilder: (unit) => unit.shortLabel.toUpperCase(),
              onSelected: onUnitChanged,
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledTextField(
              controller: item.notesController,
              label: 'Notes',
              hint: 'Optional note',
            ),
          ],
        ),
      ),
    );
  }
}

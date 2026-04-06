import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';
import 'package:milexact/shared/widgets/selector_chips.dart';

class PresetEditorDialog extends StatefulWidget {
  const PresetEditorDialog({
    super.key,
    this.initialName,
    this.initialSizeValue,
    this.initialUnit,
    required this.onSave,
  });

  final String? initialName;
  final double? initialSizeValue;
  final MeasurementUnit? initialUnit;
  final Future<void> Function(
    String name,
    String sizeValue,
    MeasurementUnit unit,
  )
  onSave;

  @override
  State<PresetEditorDialog> createState() => _PresetEditorDialogState();
}

class _PresetEditorDialogState extends State<PresetEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _sizeController;
  late MeasurementUnit _selectedUnit;
  String? _errorText;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _sizeController = TextEditingController(
      text: widget.initialSizeValue?.toString() ?? '',
    );
    _selectedUnit = widget.initialUnit ?? MeasurementUnit.meter;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await widget.onSave(
        _nameController.text,
        _sizeController.text,
        _selectedUnit,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } on ArgumentError catch (error) {
      setState(() {
        _errorText = error.message.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Preset' : 'Add Preset'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledTextField(
                controller: _nameController,
                label: 'Target Name',
                hint: '10 in Plate, Sedan Width...',
              ),
              const SizedBox(height: AppSpacing.md),
              LabeledTextField(
                controller: _sizeController,
                label: 'Target Size',
                hint: 'Enter size',
                errorText: _errorText,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Default Unit',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              SelectorChips<MeasurementUnit>(
                options: MeasurementUnit.values,
                selectedValue: _selectedUnit,
                labelBuilder: (unit) => unit.shortLabel.toUpperCase(),
                onSelected: (unit) {
                  setState(() {
                    _selectedUnit = unit;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
    );
  }
}

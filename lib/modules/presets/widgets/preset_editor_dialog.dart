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
    this.initialHeightValue,
    this.initialHeightUnit,
    this.initialWidthValue,
    this.initialWidthUnit,
    this.initialSupportsMetric,
    this.initialSupportsImperial,
    required this.onSave,
  });

  final String? initialName;
  final double? initialHeightValue;
  final UnitType? initialHeightUnit;
  final double? initialWidthValue;
  final UnitType? initialWidthUnit;
  final bool? initialSupportsMetric;
  final bool? initialSupportsImperial;
  final Future<void> Function({
    required String name,
    required String heightValue,
    required UnitType heightUnit,
    required String widthValue,
    required UnitType widthUnit,
    required bool supportsMetric,
    required bool supportsImperial,
  })
  onSave;

  @override
  State<PresetEditorDialog> createState() => _PresetEditorDialogState();
}

class _PresetEditorDialogState extends State<PresetEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late final TextEditingController _widthController;
  late UnitType _heightUnit;
  late UnitType _widthUnit;
  late bool _supportsMetric;
  late bool _supportsImperial;
  String? _errorText;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _heightController = TextEditingController(
      text: widget.initialHeightValue?.toString() ?? '',
    );
    _widthController = TextEditingController(
      text: widget.initialWidthValue?.toString() ?? '',
    );
    _heightUnit = widget.initialHeightUnit ?? UnitType.meter;
    _widthUnit = widget.initialWidthUnit ?? UnitType.meter;
    _supportsMetric = widget.initialSupportsMetric ?? true;
    _supportsImperial = widget.initialSupportsImperial ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _widthController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await widget.onSave(
        name: _nameController.text,
        heightValue: _heightController.text,
        heightUnit: _heightUnit,
        widthValue: _widthController.text,
        widthUnit: _widthUnit,
        supportsMetric: _supportsMetric,
        supportsImperial: _supportsImperial,
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
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LabeledTextField(
                controller: _nameController,
                label: 'Preset Name',
                hint: 'IPSC A-Zone, 18 inch Steel...',
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: LabeledTextField(
                      controller: _heightController,
                      label: 'Height',
                      hint: 'Height',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                      errorText: _errorText,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: LabeledTextField(
                      controller: _widthController,
                      label: 'Width',
                      hint: 'Width',
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
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Height Unit',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              SelectorChips<UnitType>(
                options: UnitType.values,
                selectedValue: _heightUnit,
                labelBuilder: (unit) => unit.shortLabel.toUpperCase(),
                onSelected: (unit) {
                  setState(() {
                    _heightUnit = unit;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Width Unit',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              SelectorChips<UnitType>(
                options: UnitType.values,
                selectedValue: _widthUnit,
                labelBuilder: (unit) => unit.shortLabel.toUpperCase(),
                onSelected: (unit) {
                  setState(() {
                    _widthUnit = unit;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Supports Metric'),
                value: _supportsMetric,
                onChanged: (value) {
                  setState(() {
                    _supportsMetric = value;
                  });
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Supports Imperial'),
                value: _supportsImperial,
                onChanged: (value) {
                  setState(() {
                    _supportsImperial = value;
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

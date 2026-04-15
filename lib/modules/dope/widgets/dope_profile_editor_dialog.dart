import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:milexact/data/models/dope_profile_entry.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/id_generator.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';
import 'package:milexact/shared/widgets/selector_chips.dart';

class DopeProfileEditorDialog extends StatefulWidget {
  const DopeProfileEditorDialog({
    super.key,
    this.initialRifleName,
    this.initialCaliber,
    this.initialBulletGrain,
    this.initialVelocityFps,
    this.initialEntries,
    this.initialIsActive,
    required this.onSave,
  });

  final String? initialRifleName;
  final String? initialCaliber;
  final double? initialBulletGrain;
  final double? initialVelocityFps;
  final List<DopeProfileEntry>? initialEntries;
  final bool? initialIsActive;
  final Future<void> Function({
    required String rifleName,
    required String caliber,
    required String bulletGrain,
    required String velocityFps,
    required List<DopeProfileEntry> entries,
    required bool isActive,
  })
  onSave;

  @override
  State<DopeProfileEditorDialog> createState() =>
      _DopeProfileEditorDialogState();
}

class _DopeProfileEditorDialogState extends State<DopeProfileEditorDialog> {
  late final TextEditingController _rifleNameController;
  late final TextEditingController _caliberController;
  late final TextEditingController _bulletGrainController;
  late final TextEditingController _velocityFpsController;
  late final List<_EntryFormModel> _entryForms;
  late bool _isActive;
  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _rifleNameController = TextEditingController(
      text: widget.initialRifleName ?? '',
    );
    _caliberController = TextEditingController(
      text: widget.initialCaliber ?? '',
    );
    _bulletGrainController = TextEditingController(
      text: widget.initialBulletGrain?.toString() ?? '',
    );
    _velocityFpsController = TextEditingController(
      text: widget.initialVelocityFps?.toString() ?? '',
    );
    _entryForms = (widget.initialEntries ?? const <DopeProfileEntry>[])
        .map(_EntryFormModel.fromEntry)
        .toList(growable: true);
    if (_entryForms.isEmpty) {
      _entryForms.add(_EntryFormModel.empty());
    }
    _isActive = widget.initialIsActive ?? false;
  }

  @override
  void dispose() {
    _rifleNameController.dispose();
    _caliberController.dispose();
    _bulletGrainController.dispose();
    _velocityFpsController.dispose();
    for (final form in _entryForms) {
      form.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      final entries = _entryForms
          .map((form) => form.toEntry())
          .toList(growable: false);
      await widget.onSave(
        rifleName: _rifleNameController.text,
        caliber: _caliberController.text,
        bulletGrain: _bulletGrainController.text,
        velocityFps: _velocityFpsController.text,
        entries: entries,
        isActive: _isActive,
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

  void _addRow() {
    setState(() {
      _entryForms.add(_EntryFormModel.empty());
    });
  }

  void _removeRow(_EntryFormModel form) {
    setState(() {
      form.dispose();
      _entryForms.remove(form);
      if (_entryForms.isEmpty) {
        _entryForms.add(_EntryFormModel.empty());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialRifleName != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit DOPE Profile' : 'Add DOPE Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: LabeledTextField(
                              controller: _rifleNameController,
                              label: 'Rifle Name',
                              hint: 'Primary rifle',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: LabeledTextField(
                              controller: _caliberController,
                              label: 'Caliber',
                              hint: '.308 Win',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: LabeledTextField(
                              controller: _bulletGrainController,
                              label: 'Bullet Grain',
                              hint: '168',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
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
                              controller: _velocityFpsController,
                              label: 'Velocity FPS',
                              hint: '2650',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
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
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Set As Active Profile'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Profile Rows',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _addRow,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add Row'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ..._entryForms.map(
                        (form) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _DopeEntryCard(
                            model: form,
                            onDelete: () => _removeRow(form),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: Text(isEditing ? 'Save' : 'Add'),
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

class _DopeEntryCard extends StatefulWidget {
  const _DopeEntryCard({required this.model, required this.onDelete});

  final _EntryFormModel model;
  final VoidCallback onDelete;

  @override
  State<_DopeEntryCard> createState() => _DopeEntryCardState();
}

class _DopeEntryCardState extends State<_DopeEntryCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: LabeledTextField(
                    controller: widget.model.distanceController,
                    label: 'Distance',
                    hint: '500',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: LabeledTextField(
                    controller: widget.model.dropController,
                    label: 'Drop',
                    hint: '3.2 MIL',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Distance Unit',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            SelectorChips<UnitType>(
              options: const [UnitType.meter, UnitType.yard],
              selectedValue: widget.model.distanceUnit,
              labelBuilder: (unit) => unit.shortLabel.toUpperCase(),
              onSelected: (unit) {
                setState(() {
                  widget.model.distanceUnit = unit;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledTextField(
              controller: widget.model.notesController,
              label: 'Notes',
              hint: 'Optional note',
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Remove Row'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryFormModel {
  _EntryFormModel({
    required this.id,
    required this.distanceController,
    required this.dropController,
    required this.notesController,
    required this.distanceUnit,
  });

  factory _EntryFormModel.empty() {
    return _EntryFormModel(
      id: '',
      distanceController: TextEditingController(),
      dropController: TextEditingController(),
      notesController: TextEditingController(),
      distanceUnit: UnitType.yard,
    );
  }

  factory _EntryFormModel.fromEntry(DopeProfileEntry entry) {
    return _EntryFormModel(
      id: entry.id,
      distanceController: TextEditingController(
        text: entry.distanceValue.toString(),
      ),
      dropController: TextEditingController(text: entry.dropValue),
      notesController: TextEditingController(text: entry.notes),
      distanceUnit: entry.distanceUnit,
    );
  }

  final String id;
  final TextEditingController distanceController;
  final TextEditingController dropController;
  final TextEditingController notesController;
  UnitType distanceUnit;

  DopeProfileEntry toEntry() {
    final distanceValue = double.tryParse(distanceController.text.trim());
    final dropValue = dropController.text.trim();

    if (distanceValue == null || distanceValue <= 0) {
      throw ArgumentError('Enter a valid distance in every DOPE row.');
    }
    if (dropValue.isEmpty) {
      throw ArgumentError('Enter a drop value in every DOPE row.');
    }

    return DopeProfileEntry(
      id: id.isEmpty ? IdGenerator.generate(prefix: 'dope-row') : id,
      profileId: '',
      distanceValue: distanceValue,
      distanceUnit: distanceUnit,
      dropValue: dropValue,
      notes: notesController.text.trim(),
    );
  }

  void dispose() {
    distanceController.dispose();
    dropController.dispose();
    notesController.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';

class CategoryEditorDialog extends StatefulWidget {
  const CategoryEditorDialog({
    super.key,
    this.initialName,
    required this.onSave,
  });

  final String? initialName;
  final Future<void> Function(String name) onSave;

  @override
  State<CategoryEditorDialog> createState() => _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends State<CategoryEditorDialog> {
  late final TextEditingController _nameController;
  String? _errorText;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await widget.onSave(_nameController.text);
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
      title: Text(isEditing ? 'Edit Category' : 'Add Category'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LabeledTextField(
              controller: _nameController,
              label: 'Category Name',
              hint: 'Human, Steel Target, Vehicle...',
              errorText: _errorText,
              textInputAction: TextInputAction.done,
            ),
          ],
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

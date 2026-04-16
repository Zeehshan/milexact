import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/data/models/dope_profile.dart';
import 'package:milexact/data/models/dope_profile_entry.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/repositories/dope_profiles_repository.dart';
import 'package:milexact/shared/utils/id_generator.dart';

class DopeProfileEditController extends GetxController {
  DopeProfileEditController(this._repository, {DopeProfile? initialProfile})
    : _initialProfile = initialProfile;

  final DopeProfilesRepository _repository;
  final DopeProfile? _initialProfile;

  late final TextEditingController rifleNameController;
  late final TextEditingController caliberController;
  late final TextEditingController bulletGrainController;
  late final TextEditingController velocityFpsController;

  final entryForms = <DopeEntryFormItem>[].obs;
  final isActive = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  bool get isEditing => _initialProfile != null;
  String get screenTitle =>
      isEditing ? 'Edit DOPE Profile' : 'Add DOPE Profile';
  String get submitLabel => isEditing ? 'Save Profile' : 'Add Profile';

  @override
  void onInit() {
    super.onInit();
    rifleNameController = TextEditingController(
      text: _initialProfile?.rifleName ?? '',
    );
    caliberController = TextEditingController(
      text: _initialProfile?.caliber ?? '',
    );
    bulletGrainController = TextEditingController(
      text: _initialProfile?.bulletGrain.toString() ?? '',
    );
    velocityFpsController = TextEditingController(
      text: _initialProfile?.velocityFps.toString() ?? '',
    );
    isActive.value = _initialProfile?.isActive ?? false;

    final initialEntries =
        _initialProfile?.entries ?? const <DopeProfileEntry>[];
    if (initialEntries.isEmpty) {
      entryForms.add(DopeEntryFormItem.empty());
    } else {
      entryForms.assignAll(
        initialEntries.map(DopeEntryFormItem.fromEntry).toList(growable: false),
      );
    }
  }

  @override
  void onClose() {
    rifleNameController.dispose();
    caliberController.dispose();
    bulletGrainController.dispose();
    velocityFpsController.dispose();
    for (final entry in entryForms) {
      entry.dispose();
    }
    super.onClose();
  }

  void addRow() {
    entryForms.add(DopeEntryFormItem.empty());
    errorMessage.value = '';
  }

  void removeRow(DopeEntryFormItem item) {
    item.dispose();
    entryForms.remove(item);
    if (entryForms.isEmpty) {
      entryForms.add(DopeEntryFormItem.empty());
    }
    errorMessage.value = '';
  }

  void updateRowUnit(DopeEntryFormItem item, UnitType unit) {
    item.distanceUnit = unit;
    entryForms.refresh();
  }

  void updateActive(bool value) {
    isActive.value = value;
  }

  Future<void> saveProfile() async {
    final trimmedRifleName = rifleNameController.text.trim();
    final trimmedCaliber = caliberController.text.trim();
    final parsedBulletGrain = double.tryParse(
      bulletGrainController.text.trim(),
    );
    final parsedVelocityFps = double.tryParse(
      velocityFpsController.text.trim(),
    );

    if (trimmedRifleName.isEmpty) {
      errorMessage.value = 'Rifle name is required.';
      return;
    }
    if (parsedBulletGrain == null || parsedBulletGrain <= 0) {
      errorMessage.value = 'Enter a valid bullet grain.';
      return;
    }
    if (parsedVelocityFps == null || parsedVelocityFps <= 0) {
      errorMessage.value = 'Enter a valid velocity FPS.';
      return;
    }

    final resolvedEntries = <DopeProfileEntry>[];
    for (final form in entryForms) {
      final distanceValue = double.tryParse(
        form.distanceController.text.trim(),
      );
      final dropValue = form.dropController.text.trim();

      if (distanceValue == null || distanceValue <= 0) {
        errorMessage.value = 'Each row needs a valid distance value.';
        return;
      }
      if (dropValue.isEmpty) {
        errorMessage.value = 'Each row needs a drop value.';
        return;
      }

      resolvedEntries.add(
        DopeProfileEntry(
          id: form.id.isEmpty
              ? IdGenerator.generate(prefix: 'dope-row')
              : form.id,
          profileId: '',
          distanceValue: distanceValue,
          distanceUnit: form.distanceUnit,
          dropValue: dropValue,
          notes: form.notesController.text.trim(),
        ),
      );
    }

    isSaving.value = true;
    errorMessage.value = '';

    try {
      final existing = _initialProfile == null
          ? null
          : _repository.profileById(_initialProfile.id);
      final now = DateTime.now();
      final resolvedProfileId =
          existing?.id ?? IdGenerator.generate(prefix: 'dope');
      final normalizedEntries = resolvedEntries
          .map(
            (entry) => entry.copyWith(
              id: entry.id.isEmpty
                  ? IdGenerator.generate(prefix: 'dope-row')
                  : entry.id,
              profileId: resolvedProfileId,
            ),
          )
          .toList(growable: false);

      final profile =
          existing?.copyWith(
            rifleName: trimmedRifleName,
            caliber: trimmedCaliber,
            bulletGrain: parsedBulletGrain,
            velocityFps: parsedVelocityFps,
            entries: normalizedEntries,
            isActive: isActive.value,
            updatedAt: now,
          ) ??
          DopeProfile(
            id: resolvedProfileId,
            rifleName: trimmedRifleName,
            caliber: trimmedCaliber,
            bulletGrain: parsedBulletGrain,
            velocityFps: parsedVelocityFps,
            entries: normalizedEntries,
            isActive: isActive.value,
            createdAt: now,
            updatedAt: now,
          );

      await _repository.upsert(profile);
      if (isActive.value) {
        await _repository.setActive(profile.id);
      }

      Get.back<void>();
      Get.snackbar(
        isEditing ? 'Profile updated' : 'Profile added',
        '${profile.rifleName} is saved to the DOPE library.',
      );
    } finally {
      isSaving.value = false;
    }
  }
}

class DopeEntryFormItem {
  DopeEntryFormItem({
    required this.id,
    required this.distanceController,
    required this.dropController,
    required this.notesController,
    required this.distanceUnit,
  });

  factory DopeEntryFormItem.empty() {
    return DopeEntryFormItem(
      id: '',
      distanceController: TextEditingController(),
      dropController: TextEditingController(),
      notesController: TextEditingController(),
      distanceUnit: UnitType.meter,
    );
  }

  factory DopeEntryFormItem.fromEntry(DopeProfileEntry entry) {
    return DopeEntryFormItem(
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

  void dispose() {
    distanceController.dispose();
    dropController.dispose();
    notesController.dispose();
  }
}

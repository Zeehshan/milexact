import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/dope_profile.dart';
import 'package:milexact/data/models/dope_profile_entry.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/range_card_entry.dart';
import 'package:milexact/data/repositories/dope_profiles_repository.dart';
import 'package:milexact/data/repositories/range_card_repository.dart';
import 'package:milexact/shared/utils/id_generator.dart';

class RangeCardEditController extends GetxController {
  RangeCardEditController(
    this._rangeCardRepository,
    this._dopeProfilesRepository,
  );

  final RangeCardRepository _rangeCardRepository;
  final DopeProfilesRepository _dopeProfilesRepository;

  final targetLabelController = TextEditingController();
  final dopeValueController = TextEditingController();
  final windDirectionClockController = TextEditingController();
  final targetPlacementLabelController = TextEditingController();
  final terrainNotesController = TextEditingController();

  final selectedDopeProfileId = RxnString();
  final selectedDopeEntryId = RxnString();
  final selectedWindValueType = WindValueType.none.obs;
  final targetPlacementAngle = 90.0.obs;
  final errorMessage = ''.obs;

  late final RangeCardEntry entry;
  late final bool isExistingEntry;

  RxList<DopeProfile> get profiles => _dopeProfilesRepository.profiles;

  DopeProfile? get selectedProfile {
    final id = selectedDopeProfileId.value;
    if (id == null) {
      return null;
    }
    return _dopeProfilesRepository.profileById(id);
  }

  List<DopeProfileEntry> get selectedProfileEntries {
    return selectedProfile?.entries ?? const <DopeProfileEntry>[];
  }

  @override
  void onInit() {
    super.onInit();
    entry = Get.arguments is RangeCardEntry
        ? Get.arguments as RangeCardEntry
        : _fallbackEntry();
    isExistingEntry = _rangeCardRepository.entryById(entry.id) != null;

    targetLabelController.text = entry.targetName;
    dopeValueController.text = entry.dopeValue;
    windDirectionClockController.text = entry.windDirectionClock;
    targetPlacementLabelController.text = entry.targetPlacementLabel;
    terrainNotesController.text = entry.terrainNotes;
    selectedWindValueType.value = entry.windValueType;
    targetPlacementAngle.value = entry.targetPlacementAngle;
    selectedDopeProfileId.value = entry.selectedDopeProfileId;
    _selectMatchingDopeEntry();
  }

  @override
  void onClose() {
    targetLabelController.dispose();
    dopeValueController.dispose();
    windDirectionClockController.dispose();
    targetPlacementLabelController.dispose();
    terrainNotesController.dispose();
    super.onClose();
  }

  void setWindValueType(WindValueType windValueType) {
    selectedWindValueType.value = windValueType;
  }

  void setTargetPlacementAngle(double value) {
    targetPlacementAngle.value = value;
  }

  void setDopeProfile(String? profileId) {
    selectedDopeProfileId.value = profileId;
    if (profileId == null) {
      selectedDopeEntryId.value = null;
      return;
    }

    final profile = _dopeProfilesRepository.profileById(profileId);
    if (profile != null && profile.entries.isNotEmpty) {
      final firstEntry = profile.entries.first;
      selectedDopeEntryId.value = firstEntry.id;
      dopeValueController.text = firstEntry.dropValue;
    }
  }

  void setDopeEntry(String? entryId) {
    selectedDopeEntryId.value = entryId;
    if (entryId == null) {
      return;
    }

    for (final entry in selectedProfileEntries) {
      if (entry.id == entryId) {
        dopeValueController.text = entry.dropValue;
        return;
      }
    }
  }

  Future<void> save() async {
    final targetName = targetLabelController.text.trim();
    if (targetName.isEmpty) {
      errorMessage.value = 'Target label is required.';
      return;
    }

    final updated = entry.copyWith(
      targetName: targetName,
      dopeValue: dopeValueController.text.trim(),
      selectedDopeProfileId: selectedDopeProfileId.value,
      windValueType: selectedWindValueType.value,
      windDirectionClock: windDirectionClockController.text.trim().isEmpty
          ? '12'
          : windDirectionClockController.text.trim(),
      targetPlacementAngle: targetPlacementAngle.value,
      targetPlacementLabel: targetPlacementLabelController.text.trim(),
      terrainNotes: terrainNotesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    await _rangeCardRepository.upsert(updated);
    errorMessage.value = '';
    Get.offNamed(AppRoutes.rangeCardList);
    Get.snackbar('Saved', 'Range card entry stored locally.');
  }

  Future<void> deleteEntry() async {
    await _rangeCardRepository.delete(entry.id);
    Get.offNamed(AppRoutes.rangeCardList);
    Get.snackbar('Deleted', 'Range card entry removed.');
  }

  void openVisualRangeCard() {
    Get.toNamed(AppRoutes.visualRangeCard, arguments: entry);
  }

  void _selectMatchingDopeEntry() {
    final currentProfile = selectedProfile;
    if (currentProfile == null) {
      return;
    }

    for (final row in currentProfile.entries) {
      if (row.dropValue == entry.dopeValue) {
        selectedDopeEntryId.value = row.id;
        return;
      }
    }

    if (currentProfile.entries.isNotEmpty) {
      selectedDopeEntryId.value = currentProfile.entries.first.id;
    }
  }

  RangeCardEntry _fallbackEntry() {
    final now = DateTime.now();
    return RangeCardEntry(
      id: IdGenerator.generate(prefix: 'range'),
      targetName: 'New Entry',
      targetHeightValue: 0,
      targetHeightUnit: UnitType.meter,
      targetWidthValue: 0,
      targetWidthUnit: UnitType.meter,
      reticleReading: 0,
      reticleType: ReticleType.mil,
      displayPreference: DistanceDisplayPreference.both,
      distanceMeters: 0,
      distanceYards: 0,
      dopeValue: '',
      selectedDopeProfileId: null,
      windValueType: WindValueType.none,
      windDirectionClock: '12',
      targetPlacementAngle: 90,
      targetPlacementLabel: '',
      terrainNotes: '',
      createdAt: now,
      updatedAt: now,
    );
  }
}

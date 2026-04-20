import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/dope_profile.dart';
import 'package:milexact/data/models/dope_profile_entry.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/range_card_entry.dart';
import 'package:milexact/data/repositories/dope_profiles_repository.dart';
import 'package:milexact/data/repositories/range_card_repository.dart';
import 'package:milexact/modules/app_shell/controllers/app_shell_controller.dart';
import 'package:milexact/services/unit_conversion_service.dart';
import 'package:milexact/shared/utils/id_generator.dart';

class RangeCardEditController extends GetxController {
  RangeCardEditController(
    this._rangeCardRepository,
    this._dopeProfilesRepository,
    this._unitConversionService,
  );

  final RangeCardRepository _rangeCardRepository;
  final DopeProfilesRepository _dopeProfilesRepository;
  final UnitConversionService _unitConversionService;

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

  DopeProfile? get resolvedProfile {
    final activeProfile = profiles.firstWhereOrNull(
      (profile) => profile.isActive,
    );
    if (activeProfile != null) {
      return activeProfile;
    }

    final persistedProfileId = entry.selectedDopeProfileId;
    if (persistedProfileId != null) {
      final persisted = _dopeProfilesRepository.profileById(persistedProfileId);
      if (persisted != null) {
        return persisted;
      }
    }

    if (profiles.length == 1) {
      return profiles.first;
    }

    return null;
  }

  DopeProfileEntry? get matchedProfileEntry {
    final profile = resolvedProfile;
    if (profile == null || profile.entries.isEmpty) {
      return null;
    }

    final targetDistanceMeters = entry.distanceMeters;
    DopeProfileEntry? bestEntry;
    var bestDelta = double.infinity;

    for (final profileEntry in profile.entries) {
      final entryDistanceMeters = _unitConversionService.toMeters(
        profileEntry.distanceValue,
        profileEntry.distanceUnit,
      );
      final delta = (entryDistanceMeters - targetDistanceMeters).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        bestEntry = profileEntry;
      }
    }

    return bestEntry;
  }

  bool get hasManualDopeOverride {
    final matchedEntry = matchedProfileEntry;
    if (matchedEntry == null) {
      return dopeValueController.text.trim().isNotEmpty;
    }
    final currentDope = dopeValueController.text.trim();
    return currentDope.isNotEmpty &&
        currentDope != matchedEntry.dropValue.trim();
  }

  String get autoDopeStatusText {
    final profile = resolvedProfile;
    final matchedEntry = matchedProfileEntry;
    if (profile == null) {
      return profiles.isEmpty
          ? 'No saved DOPE profiles found.'
          : 'No active DOPE profile found. Mark one profile active in DOPE Profiles.';
    }
    if (matchedEntry == null) {
      return 'The active profile has no saved distance rows.';
    }
    return 'Auto-matched from ${profile.rifleName} based on ${entry.distanceMeters.round()}m target distance.';
  }

  String get autoDopeProfileLabel {
    final profile = resolvedProfile;
    if (profile == null) {
      return '--';
    }
    final details = <String>[
      profile.rifleName,
      if (profile.caliber.trim().isNotEmpty) profile.caliber.trim(),
    ];
    return details.join(' • ');
  }

  String get autoDopeRowLabel {
    final matchedEntry = matchedProfileEntry;
    if (matchedEntry == null) {
      return '--';
    }
    return '${matchedEntry.distanceValue.toStringAsFixed(matchedEntry.distanceValue % 1 == 0 ? 0 : 1)} ${matchedEntry.distanceUnit.shortLabel} • ${matchedEntry.dropValue}';
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
    _syncAutoDope();
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

  void applyAutoMatchedDope() {
    _applyMatchedDope(force: true);
  }

  Future<void> save() async {
    final targetName = entry.targetName.trim();
    if (targetName.isEmpty) {
      errorMessage.value = 'Target label is required.';
      return;
    }

    final updated = entry.copyWith(
      targetName: targetName,
      dopeValue: dopeValueController.text.trim(),
      selectedDopeProfileId: resolvedProfile?.id,
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
    _returnToRangeCardList();
    Get.snackbar('Saved', 'Range card entry stored locally.');
  }

  Future<void> deleteEntry() async {
    await _rangeCardRepository.delete(entry.id);
    _returnToRangeCardList();
    Get.snackbar('Deleted', 'Range card entry removed.');
  }

  void openVisualRangeCard() {
    Get.toNamed(AppRoutes.visualRangeCard, arguments: entry);
  }

  void _syncAutoDope() {
    selectedDopeProfileId.value = resolvedProfile?.id;
    selectedDopeEntryId.value = matchedProfileEntry?.id;
    _applyMatchedDope(force: _shouldAutoApplyMatchedDope());
  }

  bool _shouldAutoApplyMatchedDope() {
    final currentValue = entry.dopeValue.trim();
    if (currentValue.isEmpty) {
      return true;
    }

    final profile = resolvedProfile;
    if (profile == null) {
      return false;
    }

    final matchesSavedProfileRow = profile.entries.any(
      (row) => row.dropValue.trim() == currentValue,
    );
    return entry.selectedDopeProfileId == profile.id && matchesSavedProfileRow;
  }

  void _applyMatchedDope({required bool force}) {
    final matchedEntry = matchedProfileEntry;
    if (matchedEntry == null) {
      if (force) {
        dopeValueController.clear();
      }
      return;
    }

    final nextValue = matchedEntry.dropValue.trim();
    if (force || dopeValueController.text.trim().isEmpty) {
      dopeValueController.text = nextValue;
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

  void _returnToRangeCardList() {
    if (Get.isRegistered<AppShellController>()) {
      Get.find<AppShellController>().selectRoute(AppRoutes.rangeCardList);
      if ((Get.key.currentState?.canPop() ?? false) &&
          Get.currentRoute != AppRoutes.home) {
        Get.back<void>();
        return;
      }
      Get.offNamed(AppRoutes.home, arguments: AppRoutes.rangeCardList);
      return;
    }

    Get.offNamed(AppRoutes.rangeCardList);
  }
}

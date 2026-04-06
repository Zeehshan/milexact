import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/range_card_entry.dart';
import 'package:milexact/data/repositories/range_card_repository.dart';
import 'package:milexact/shared/utils/id_generator.dart';

class RangeCardEditController extends GetxController {
  RangeCardEditController(this._repository);

  final RangeCardRepository _repository;

  final targetLabelController = TextEditingController();
  final dopeController = TextEditingController();
  final windFullController = TextEditingController();
  final windHalfController = TextEditingController();
  final windQuarterController = TextEditingController();
  final notesController = TextEditingController();

  final errorMessage = ''.obs;
  late final RangeCardEntry entry;
  late final bool isExistingEntry;

  @override
  void onInit() {
    super.onInit();
    entry = Get.arguments is RangeCardEntry
        ? Get.arguments as RangeCardEntry
        : _fallbackEntry();
    isExistingEntry = _repository.entryById(entry.id) != null;

    targetLabelController.text = entry.targetName;
    dopeController.text = entry.dope;
    windFullController.text = entry.windFull;
    windHalfController.text = entry.windHalf;
    windQuarterController.text = entry.windQuarter;
    notesController.text = entry.notes;
  }

  @override
  void onClose() {
    targetLabelController.dispose();
    dopeController.dispose();
    windFullController.dispose();
    windHalfController.dispose();
    windQuarterController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> save() async {
    final targetName = targetLabelController.text.trim();
    if (targetName.isEmpty) {
      errorMessage.value = 'Target label is required.';
      return;
    }

    final updated = entry.copyWith(
      targetName: targetName,
      dope: dopeController.text.trim(),
      windFull: windFullController.text.trim(),
      windHalf: windHalfController.text.trim(),
      windQuarter: windQuarterController.text.trim(),
      notes: notesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    await _repository.upsert(updated);
    errorMessage.value = '';
    Get.back<void>();
    Get.snackbar('Saved', 'Range card entry stored locally.');
  }

  Future<void> deleteEntry() async {
    await _repository.delete(entry.id);
    Get.until(
      (route) =>
          route.settings.name == AppRoutes.rangeCardList || route.isFirst,
    );
    Get.snackbar('Deleted', 'Range card entry removed.');
  }

  RangeCardEntry _fallbackEntry() {
    final now = DateTime.now();
    return RangeCardEntry(
      id: IdGenerator.generate(prefix: 'range'),
      targetName: 'New Entry',
      targetSizeValue: 0,
      targetSizeUnit: MeasurementUnit.meter,
      reticleReading: 0,
      reticleType: ReticleType.mil,
      outputPreference: DistanceOutputPreference.both,
      calculatedDistanceMeters: 0,
      calculatedDistanceYards: 0,
      dope: '',
      windFull: '',
      windHalf: '',
      windQuarter: '',
      notes: '',
      createdAt: now,
      updatedAt: now,
    );
  }
}

import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/range_card_entry.dart';
import 'package:milexact/data/repositories/range_card_repository.dart';

class RangeCardListController extends GetxController {
  RangeCardListController(this._repository);

  final RangeCardRepository _repository;
  final searchQuery = ''.obs;

  RxList<RangeCardEntry> get entries => _repository.entries;

  List<RangeCardEntry> get filteredEntries {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return entries.toList(growable: false);
    }

    return entries
        .where((entry) {
          return entry.targetName.toLowerCase().contains(query) ||
              entry.dopeValue.toLowerCase().contains(query) ||
              entry.windDirectionClock.toLowerCase().contains(query) ||
              entry.targetPlacementLabel.toLowerCase().contains(query) ||
              entry.terrainNotes.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void openEntry(RangeCardEntry entry) {
    Get.toNamed(AppRoutes.rangeCardEdit, arguments: entry);
  }

  Future<void> deleteEntry(String entryId) async {
    await _repository.delete(entryId);
    Get.snackbar('Deleted', 'Range card entry removed.');
  }
}

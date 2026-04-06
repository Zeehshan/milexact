import 'package:get/get.dart';
import 'package:milexact/data/models/range_card_entry.dart';
import 'package:milexact/services/storage_service.dart';

class RangeCardRepository extends GetxService {
  RangeCardRepository(this._storage);

  final StorageService _storage;
  final RxList<RangeCardEntry> entries = <RangeCardEntry>[].obs;

  Future<RangeCardRepository> init() async {
    _reload();
    return this;
  }

  RangeCardEntry? entryById(String id) {
    return entries.firstWhereOrNull((entry) => entry.id == id);
  }

  Future<void> upsert(RangeCardEntry entry) async {
    await _storage.rangeCardsBox.put(entry.id, entry.toJson());
    _reload();
  }

  Future<void> delete(String entryId) async {
    await _storage.rangeCardsBox.delete(entryId);
    _reload();
  }

  void _reload() {
    entries.assignAll(
      _storage.rangeCardsBox.values
          .map((raw) => RangeCardEntry.fromJson(Map<String, dynamic>.from(raw)))
          .toList()
        ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt)),
    );
  }
}

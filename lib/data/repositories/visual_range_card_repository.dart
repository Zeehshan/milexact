import 'package:get/get.dart';
import 'package:milexact/data/models/visual_range_card_state.dart';
import 'package:milexact/services/storage_service.dart';

class VisualRangeCardRepository extends GetxService {
  VisualRangeCardRepository(this._storage);

  final StorageService _storage;
  final RxList<VisualRangeCardState> cards = <VisualRangeCardState>[].obs;

  Future<VisualRangeCardRepository> init() async {
    _reload();
    return this;
  }

  VisualRangeCardState? cardById(String id) {
    return cards.firstWhereOrNull((card) => card.id == id);
  }

  VisualRangeCardState? cardByLinkedRangeEntry(String entryId) {
    return cards.firstWhereOrNull(
      (card) => card.linkedRangeCardEntryId == entryId,
    );
  }

  Future<void> upsert(VisualRangeCardState card) async {
    await _storage.visualRangeCardsBox.put(card.id, card.toJson());
    _reload();
  }

  Future<void> delete(String cardId) async {
    await _storage.visualRangeCardsBox.delete(cardId);
    _reload();
  }

  void _reload() {
    cards.assignAll(
      _storage.visualRangeCardsBox.values
          .map(
            (raw) =>
                VisualRangeCardState.fromJson(Map<String, dynamic>.from(raw)),
          )
          .toList()
        ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt)),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/range_card_entry.dart';
import 'package:milexact/data/models/target_marker.dart';
import 'package:milexact/data/models/terrain_item.dart';
import 'package:milexact/data/models/visual_point.dart';
import 'package:milexact/data/models/visual_range_card_state.dart';
import 'package:milexact/data/repositories/visual_range_card_repository.dart';
import 'package:milexact/services/visual_range_card_service.dart';
import 'package:milexact/shared/utils/id_generator.dart';

class VisualRangeCardController extends GetxController {
  VisualRangeCardController(this._repository, this._visualRangeCardService);

  final VisualRangeCardRepository _repository;
  final VisualRangeCardService _visualRangeCardService;

  final currentCard = Rxn<VisualRangeCardState>();
  final editorMode = VisualEditorMode.marker.obs;
  final draftTerrainPoints = <VisualPoint>[].obs;
  final draggingMarkerId = RxnString();
  final _history = <VisualRangeCardState>[];

  RangeCardEntry? linkedEntry;

  List<TargetMarker> get targetMarkers =>
      currentCard.value?.targetMarkers ?? const <TargetMarker>[];

  List<TerrainItem> get terrainItems =>
      currentCard.value?.terrainItems ?? const <TerrainItem>[];

  bool get canCommitTerrain =>
      editorMode.value.isTerrain && draftTerrainPoints.length >= 2;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is RangeCardEntry) {
      linkedEntry = args;
    }
    _loadCard();
  }

  void setEditorMode(VisualEditorMode mode) {
    editorMode.value = mode;
    draggingMarkerId.value = null;
  }

  void toggleArcLines(bool enabled) {
    final card = currentCard.value;
    if (card == null) {
      return;
    }
    _snapshot();
    currentCard.value = card.copyWith(
      arcLinesEnabled: enabled,
      updatedAt: DateTime.now(),
    );
  }

  void handleTap({required Size size, required Offset localPosition}) {
    if (!_visualRangeCardService.isInsidePlot(
      localPosition: localPosition,
      size: size,
    )) {
      return;
    }

    if (editorMode.value == VisualEditorMode.marker) {
      _addMarker(size: size, localPosition: localPosition);
      return;
    }

    draftTerrainPoints.add(
      _visualRangeCardService.normalizedPointFromOffset(
        localPosition: localPosition,
        size: size,
      ),
    );
  }

  void handlePanStart({required Size size, required Offset localPosition}) {
    if (editorMode.value != VisualEditorMode.marker) {
      return;
    }

    for (final marker in targetMarkers) {
      final markerOffset = _visualRangeCardService.offsetFromMarker(
        marker: marker,
        size: size,
      );
      if ((markerOffset - localPosition).distance <= 24) {
        _snapshot();
        draggingMarkerId.value = marker.id;
        return;
      }
    }
  }

  void handlePanUpdate({required Size size, required Offset localPosition}) {
    final markerId = draggingMarkerId.value;
    final card = currentCard.value;
    if (markerId == null || card == null) {
      return;
    }
    if (!_visualRangeCardService.isInsidePlot(
      localPosition: localPosition,
      size: size,
    )) {
      return;
    }

    final nextMarkers = card.targetMarkers
        .map((marker) {
          if (marker.id != markerId) {
            return marker;
          }
          final updated = _visualRangeCardService.markerFromOffset(
            id: marker.id,
            label: marker.label,
            localPosition: localPosition,
            size: size,
            linkedRangeCardEntryId: marker.linkedRangeCardEntryId,
            iconType: marker.iconType,
            notes: marker.notes,
          );
          return marker.copyWith(
            angle: updated.angle,
            distance: updated.distance,
          );
        })
        .toList(growable: false);

    currentCard.value = card.copyWith(
      targetMarkers: nextMarkers,
      updatedAt: DateTime.now(),
    );
  }

  void handlePanEnd() {
    draggingMarkerId.value = null;
  }

  void commitTerrain() {
    final terrainType = editorMode.value.terrainType;
    final card = currentCard.value;
    if (terrainType == null || card == null || draftTerrainPoints.length < 2) {
      return;
    }

    _snapshot();
    final terrainItem = TerrainItem(
      id: IdGenerator.generate(prefix: 'terrain'),
      type: terrainType,
      points: draftTerrainPoints.toList(growable: false),
      label: terrainType.label,
      styleToken: editorMode.value.name,
    );

    currentCard.value = card.copyWith(
      terrainItems: [...card.terrainItems, terrainItem],
      updatedAt: DateTime.now(),
    );
    draftTerrainPoints.clear();
  }

  void renameMarker({
    required String markerId,
    required String label,
    required String notes,
  }) {
    final card = currentCard.value;
    if (card == null) {
      return;
    }

    _snapshot();
    currentCard.value = card.copyWith(
      targetMarkers: card.targetMarkers
          .map(
            (marker) => marker.id == markerId
                ? marker.copyWith(label: label.trim(), notes: notes.trim())
                : marker,
          )
          .toList(growable: false),
      updatedAt: DateTime.now(),
    );
  }

  void renameTerrain({required String terrainId, required String label}) {
    final card = currentCard.value;
    if (card == null) {
      return;
    }

    _snapshot();
    currentCard.value = card.copyWith(
      terrainItems: card.terrainItems
          .map(
            (terrain) => terrain.id == terrainId
                ? terrain.copyWith(label: label.trim())
                : terrain,
          )
          .toList(growable: false),
      updatedAt: DateTime.now(),
    );
  }

  void removeMarker(String markerId) {
    final card = currentCard.value;
    if (card == null) {
      return;
    }

    _snapshot();
    currentCard.value = card.copyWith(
      targetMarkers: card.targetMarkers
          .where((marker) => marker.id != markerId)
          .toList(growable: false),
      updatedAt: DateTime.now(),
    );
  }

  void removeTerrain(String terrainId) {
    final card = currentCard.value;
    if (card == null) {
      return;
    }

    _snapshot();
    currentCard.value = card.copyWith(
      terrainItems: card.terrainItems
          .where((terrain) => terrain.id != terrainId)
          .toList(growable: false),
      updatedAt: DateTime.now(),
    );
  }

  void undo() {
    if (draftTerrainPoints.isNotEmpty) {
      draftTerrainPoints.removeLast();
      return;
    }

    if (_history.isEmpty) {
      return;
    }

    currentCard.value = _history.removeLast();
  }

  void clearAll() {
    final card = currentCard.value;
    if (card == null) {
      return;
    }

    _snapshot();
    draftTerrainPoints.clear();
    currentCard.value = card.copyWith(
      targetMarkers: const <TargetMarker>[],
      terrainItems: const <TerrainItem>[],
      updatedAt: DateTime.now(),
    );
  }

  Future<void> save() async {
    final card = currentCard.value;
    if (card == null) {
      return;
    }

    final normalized = card.copyWith(updatedAt: DateTime.now());
    currentCard.value = normalized;
    await _repository.upsert(normalized);
    Get.snackbar('Saved', 'Visual range card stored locally.');
  }

  String distanceLabel(TargetMarker marker) {
    if (linkedEntry != null &&
        marker.linkedRangeCardEntryId == linkedEntry!.id &&
        linkedEntry!.distanceMeters > 0) {
      return '${linkedEntry!.distanceMeters.round()} m';
    }
    return '${marker.distance.round()} m';
  }

  Offset markerOffset(TargetMarker marker, Size size) {
    return _visualRangeCardService.offsetFromMarker(marker: marker, size: size);
  }

  Offset terrainOffset(VisualPoint point, Size size) {
    return _visualRangeCardService.offsetFromNormalizedPoint(
      point: point,
      size: size,
    );
  }

  void _loadCard() {
    VisualRangeCardState? existing;
    if (linkedEntry != null) {
      existing = _repository.cardByLinkedRangeEntry(linkedEntry!.id);
    }

    existing ??= _repository.cards.firstWhereOrNull(
      (card) => card.linkedRangeCardEntryId == null,
    );

    currentCard.value = existing ?? _blankCard();
    if (linkedEntry != null &&
        currentCard.value!.targetMarkers.isEmpty &&
        linkedEntry!.distanceMeters > 0) {
      currentCard.value = currentCard.value!.copyWith(
        targetMarkers: [
          TargetMarker(
            id: IdGenerator.generate(prefix: 'marker'),
            label: linkedEntry!.targetName,
            angle: 90,
            distance: math.min(linkedEntry!.distanceMeters, 1000),
            linkedRangeCardEntryId: linkedEntry!.id,
            iconType: 'target',
            notes: '',
          ),
        ],
      );
    }
  }

  void _addMarker({required Size size, required Offset localPosition}) {
    final card = currentCard.value;
    if (card == null) {
      return;
    }

    _snapshot();
    final label = linkedEntry != null && card.targetMarkers.isEmpty
        ? linkedEntry!.targetName
        : 'Target ${card.targetMarkers.length + 1}';
    final marker = _visualRangeCardService.markerFromOffset(
      id: IdGenerator.generate(prefix: 'marker'),
      label: label,
      localPosition: localPosition,
      size: size,
      linkedRangeCardEntryId: linkedEntry != null && card.targetMarkers.isEmpty
          ? linkedEntry!.id
          : null,
      notes: '',
    );

    currentCard.value = card.copyWith(
      targetMarkers: [...card.targetMarkers, marker],
      updatedAt: DateTime.now(),
    );
  }

  void _snapshot() {
    final card = currentCard.value;
    if (card == null) {
      return;
    }
    _history.add(VisualRangeCardState.fromJson(card.toJson()));
  }

  VisualRangeCardState _blankCard() {
    final now = DateTime.now();
    return VisualRangeCardState(
      id: IdGenerator.generate(prefix: 'visual'),
      linkedRangeCardEntryId: linkedEntry?.id,
      arcLinesEnabled: true,
      terrainItems: const <TerrainItem>[],
      targetMarkers: const <TargetMarker>[],
      createdAt: now,
      updatedAt: now,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/range_card_entry.dart';
import 'package:milexact/data/models/target_marker.dart';
import 'package:milexact/data/models/terrain_item.dart';
import 'package:milexact/data/models/visual_point.dart';
import 'package:milexact/data/models/visual_range_card_state.dart';
import 'package:milexact/data/repositories/range_card_repository.dart';
import 'package:milexact/data/repositories/visual_range_card_repository.dart';
import 'package:milexact/services/visual_range_card_service.dart';
import 'package:milexact/shared/utils/id_generator.dart';

class VisualRangeCardController extends GetxController {
  VisualRangeCardController(
    this._rangeCardRepository,
    this._repository,
    this._visualRangeCardService,
  );

  final RangeCardRepository _rangeCardRepository;
  final VisualRangeCardRepository _repository;
  final VisualRangeCardService _visualRangeCardService;

  final currentCard = Rxn<VisualRangeCardState>();
  final editorMode = VisualEditorMode.marker.obs;
  final isDrawModeEnabled = false.obs;
  final draftTerrainPoints = <VisualPoint>[].obs;
  final draggingMarkerId = RxnString();
  final draggingMarkerPreview = Rxn<TargetMarker>();
  final _history = <VisualRangeCardState>[];
  bool _isTerrainDrawing = false;

  RangeCardEntry? linkedEntry;

  RxList<RangeCardEntry> get rangeCardEntries => _rangeCardRepository.entries;

  List<TargetMarker> get targetMarkers {
    final preview = draggingMarkerPreview.value;
    final linkedEntries =
        rangeCardEntries
            .where((entry) => entry.distanceMeters > 0)
            .toList(growable: false)
          ..sort((left, right) {
            final createdAtCompare = left.createdAt.compareTo(right.createdAt);
            if (createdAtCompare != 0) {
              return createdAtCompare;
            }
            return left.id.compareTo(right.id);
          });
    final linkedMarkers = linkedEntries
        .map(_markerFromRangeEntry)
        .map((marker) => preview?.id == marker.id ? preview! : marker)
        .toList(growable: false);
    final linkedIds = linkedMarkers
        .map((marker) => marker.linkedRangeCardEntryId)
        .whereType<String>()
        .toSet();
    final legacyMarkers =
        currentCard.value?.targetMarkers
            .where(
              (marker) =>
                  marker.linkedRangeCardEntryId == null ||
                  !linkedIds.contains(marker.linkedRangeCardEntryId),
            )
            .map((marker) => preview?.id == marker.id ? preview! : marker)
            .toList(growable: false) ??
        const <TargetMarker>[];
    return [...linkedMarkers, ...legacyMarkers];
  }

  List<TerrainItem> get terrainItems =>
      currentCard.value?.terrainItems ?? const <TerrainItem>[];

  bool get canCommitTerrain =>
      editorMode.value.isTerrain && draftTerrainPoints.length >= 2;

  double get displayMaxDistance =>
      _visualRangeCardService.effectiveMaxDistance(targetMarkers);

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
    draggingMarkerPreview.value = null;
    _isTerrainDrawing = false;
    draftTerrainPoints.clear();
  }

  void setDrawModeEnabled(bool isEnabled) {
    isDrawModeEnabled.value = isEnabled;
    if (!isEnabled) {
      draggingMarkerId.value = null;
      draggingMarkerPreview.value = null;
      _isTerrainDrawing = false;
    }
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
    if (!isDrawModeEnabled.value) {
      return;
    }
    if (_isTerrainDrawing) {
      return;
    }
    if (!_visualRangeCardService.isInsidePlot(
      localPosition: localPosition,
      size: size,
    )) {
      return;
    }

    if (editorMode.value == VisualEditorMode.marker) {
      return;
    }

    _appendTerrainPoint(size: size, localPosition: localPosition);
  }

  void handlePanStart({required Size size, required Offset localPosition}) {
    if (!isDrawModeEnabled.value) {
      return;
    }
    if (!_visualRangeCardService.isInsidePlot(
      localPosition: localPosition,
      size: size,
    )) {
      return;
    }

    if (editorMode.value.isTerrain) {
      _snapshot();
      _isTerrainDrawing = true;
      draggingMarkerPreview.value = null;
      draftTerrainPoints.clear();
      _appendTerrainPoint(size: size, localPosition: localPosition);
      return;
    }

    for (final marker in targetMarkers) {
      final markerOffset = _visualRangeCardService.offsetFromMarker(
        marker: marker,
        size: size,
        maxDistanceMeters: displayMaxDistance,
      );
      if ((markerOffset - localPosition).distance <= 24) {
        _snapshot();
        draggingMarkerId.value = marker.id;
        return;
      }
    }
  }

  void handlePanUpdate({required Size size, required Offset localPosition}) {
    if (!isDrawModeEnabled.value) {
      return;
    }
    if (editorMode.value.isTerrain) {
      if (!_isTerrainDrawing ||
          !_visualRangeCardService.isInsidePlot(
            localPosition: localPosition,
            size: size,
          )) {
        return;
      }

      _appendTerrainPoint(size: size, localPosition: localPosition);
      return;
    }

    final markerId = draggingMarkerId.value;
    if (markerId == null) {
      return;
    }
    if (!_visualRangeCardService.isInsidePlot(
      localPosition: localPosition,
      size: size,
    )) {
      return;
    }

    final marker = targetMarkers.firstWhereOrNull(
      (entry) => entry.id == markerId,
    );
    if (marker == null) {
      return;
    }

    final updated = _visualRangeCardService.markerFromOffset(
      id: marker.id,
      label: marker.label,
      localPosition: localPosition,
      size: size,
      maxDistanceMeters: displayMaxDistance,
      linkedRangeCardEntryId: marker.linkedRangeCardEntryId,
      iconType: marker.iconType,
      notes: marker.notes,
    );
    draggingMarkerPreview.value = updated;
  }

  Future<void> handlePanEnd() async {
    if (!isDrawModeEnabled.value) {
      draggingMarkerId.value = null;
      draggingMarkerPreview.value = null;
      _isTerrainDrawing = false;
      return;
    }
    if (_isTerrainDrawing) {
      _isTerrainDrawing = false;
      if (draftTerrainPoints.length >= 2) {
        _commitTerrain(shouldSnapshot: false);
      } else {
        draftTerrainPoints.clear();
      }
      return;
    }

    final preview = draggingMarkerPreview.value;
    if (preview != null) {
      if (preview.linkedRangeCardEntryId != null) {
        final rangeEntry = _rangeCardRepository.entryById(
          preview.linkedRangeCardEntryId!,
        );
        if (rangeEntry != null) {
          await _rangeCardRepository.upsert(
            rangeEntry.copyWith(
              targetPlacementAngle: preview.angle,
              updatedAt: DateTime.now(),
            ),
          );
        }
      } else {
        final card = currentCard.value;
        if (card != null) {
          currentCard.value = card.copyWith(
            targetMarkers: card.targetMarkers
                .map((entry) => entry.id == preview.id ? preview : entry)
                .toList(growable: false),
            updatedAt: DateTime.now(),
          );
        }
      }
    }

    draggingMarkerId.value = null;
    draggingMarkerPreview.value = null;
  }

  void commitTerrain() {
    _commitTerrain();
  }

  void _commitTerrain({bool shouldSnapshot = true}) {
    final terrainType = editorMode.value.terrainType;
    final card = currentCard.value;
    if (terrainType == null || card == null || draftTerrainPoints.length < 2) {
      return;
    }

    if (shouldSnapshot) {
      _snapshot();
    }
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
    final linkedEntry = _rangeCardRepository.entryById(markerId);
    if (linkedEntry != null) {
      _rangeCardRepository.upsert(
        linkedEntry.copyWith(
          targetPlacementLabel: label.trim(),
          terrainNotes: notes.trim(),
          updatedAt: DateTime.now(),
        ),
      );
      return;
    }

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
    final linkedEntry = _rangeCardRepository.entryById(markerId);
    if (linkedEntry != null) {
      return;
    }

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

  RangeCardEntry? linkedRangeEntryForMarker(TargetMarker marker) {
    final entryId = marker.linkedRangeCardEntryId;
    if (entryId == null) {
      return null;
    }
    return _rangeCardRepository.entryById(entryId);
  }

  String markerAngleLabel(TargetMarker marker) {
    final visualAngle = _visualRangeCardService.visualAngleFromStored(
      marker.angle,
    );
    if (visualAngle.abs() < 0.5) {
      return 'CTR';
    }
    return visualAngle > 0
        ? 'R${visualAngle.abs().round()}°'
        : 'L${visualAngle.abs().round()}°';
  }

  Future<void> adjustMarkerAngle(String markerId, double deltaDegrees) async {
    final marker = targetMarkers.firstWhereOrNull(
      (entry) => entry.id == markerId,
    );
    if (marker == null) {
      return;
    }
    final visualAngle = _visualRangeCardService.visualAngleFromStored(
      marker.angle,
    );
    final nextVisualAngle = (visualAngle + deltaDegrees).clamp(
      -VisualRangeCardService.halfFanDegrees + 5,
      VisualRangeCardService.halfFanDegrees - 5,
    );
    await _persistMarker(
      marker.copyWith(
        angle: _visualRangeCardService.storedAngleFromVisual(nextVisualAngle),
      ),
    );
  }

  Future<void> centerMarkerAngle(String markerId) async {
    final marker = targetMarkers.firstWhereOrNull(
      (entry) => entry.id == markerId,
    );
    if (marker == null) {
      return;
    }
    await _persistMarker(
      marker.copyWith(angle: _visualRangeCardService.storedAngleFromVisual(0)),
    );
  }

  String distanceLabel(TargetMarker marker) {
    final linkedRangeEntry = marker.linkedRangeCardEntryId == null
        ? null
        : _rangeCardRepository.entryById(marker.linkedRangeCardEntryId!);
    if (linkedRangeEntry != null && linkedRangeEntry.distanceMeters > 0) {
      return '${linkedRangeEntry.distanceMeters.round()} m';
    }
    return '${marker.distance.round()} m';
  }

  Offset markerOffset(TargetMarker marker, Size size) {
    return _visualRangeCardService.offsetFromMarker(
      marker: marker,
      size: size,
      maxDistanceMeters: displayMaxDistance,
    );
  }

  Offset terrainOffset(VisualPoint point, Size size) {
    return _visualRangeCardService.offsetFromNormalizedPoint(
      point: point,
      size: size,
    );
  }

  Future<void> _persistMarker(TargetMarker marker) async {
    if (marker.linkedRangeCardEntryId != null) {
      final rangeEntry = _rangeCardRepository.entryById(
        marker.linkedRangeCardEntryId!,
      );
      if (rangeEntry == null) {
        return;
      }
      await _rangeCardRepository.upsert(
        rangeEntry.copyWith(
          targetPlacementAngle: marker.angle,
          updatedAt: DateTime.now(),
        ),
      );
      return;
    }

    final card = currentCard.value;
    if (card == null) {
      return;
    }

    currentCard.value = card.copyWith(
      targetMarkers: card.targetMarkers
          .map((entry) => entry.id == marker.id ? marker : entry)
          .toList(growable: false),
      updatedAt: DateTime.now(),
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
  }

  void _snapshot() {
    final card = currentCard.value;
    if (card == null) {
      return;
    }
    _history.add(VisualRangeCardState.fromJson(card.toJson()));
  }

  void _appendTerrainPoint({
    required Size size,
    required Offset localPosition,
  }) {
    if (draftTerrainPoints.isNotEmpty) {
      final lastOffset = _visualRangeCardService.offsetFromNormalizedPoint(
        point: draftTerrainPoints.last,
        size: size,
      );
      if ((lastOffset - localPosition).distance < 8) {
        return;
      }
    }

    draftTerrainPoints.add(
      _visualRangeCardService.normalizedPointFromOffset(
        localPosition: localPosition,
        size: size,
      ),
    );
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

  TargetMarker _markerFromRangeEntry(RangeCardEntry entry) {
    final targetName = entry.targetName.trim();
    return TargetMarker(
      id: entry.id,
      label: targetName.isEmpty ? 'Unknown Target' : targetName,
      angle: entry.targetPlacementAngle,
      distance: entry.distanceMeters,
      linkedRangeCardEntryId: entry.id,
      iconType: 'target',
      notes: entry.terrainNotes,
    );
  }
}

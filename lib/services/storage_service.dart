import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:milexact/data/local/hive_boxes.dart';

class StorageService extends GetxService {
  Future<StorageService> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>(HiveBoxes.categories),
      Hive.openBox<Map>(HiveBoxes.presets),
      Hive.openBox<Map>(HiveBoxes.rangeCards),
      Hive.openBox<Map>(HiveBoxes.settings),
    ]);
    return this;
  }

  Box<Map> get categoriesBox => Hive.box<Map>(HiveBoxes.categories);
  Box<Map> get presetsBox => Hive.box<Map>(HiveBoxes.presets);
  Box<Map> get rangeCardsBox => Hive.box<Map>(HiveBoxes.rangeCards);
  Box<Map> get settingsBox => Hive.box<Map>(HiveBoxes.settings);
}

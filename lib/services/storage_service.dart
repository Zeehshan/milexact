import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:milexact/data/local/hive_boxes.dart';

class StorageService extends GetxService {
  Future<StorageService> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>(HiveBoxes.categories),
      Hive.openBox<Map>(HiveBoxes.presets),
      Hive.openBox<Map>(HiveBoxes.dopeProfiles),
      Hive.openBox<Map>(HiveBoxes.rangeCards),
      Hive.openBox<Map>(HiveBoxes.visualRangeCards),
      Hive.openBox<Map>(HiveBoxes.settings),
      Hive.openBox<Map>(HiveBoxes.authUsers),
      Hive.openBox<Map>(HiveBoxes.authSession),
    ]);
    return this;
  }

  Box<Map> get categoriesBox => Hive.box<Map>(HiveBoxes.categories);
  Box<Map> get presetsBox => Hive.box<Map>(HiveBoxes.presets);
  Box<Map> get dopeProfilesBox => Hive.box<Map>(HiveBoxes.dopeProfiles);
  Box<Map> get rangeCardsBox => Hive.box<Map>(HiveBoxes.rangeCards);
  Box<Map> get visualRangeCardsBox => Hive.box<Map>(HiveBoxes.visualRangeCards);
  Box<Map> get settingsBox => Hive.box<Map>(HiveBoxes.settings);
  Box<Map> get authUsersBox => Hive.box<Map>(HiveBoxes.authUsers);
  Box<Map> get authSessionBox => Hive.box<Map>(HiveBoxes.authSession);
}

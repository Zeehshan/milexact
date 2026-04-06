import 'package:flutter/widgets.dart';
import 'package:milexact/app/app.dart';
import 'package:milexact/app/bindings/initial_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitialBinding.initServices();
  runApp(const MilExactApp());
}

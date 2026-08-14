import 'package:flutter/material.dart';

import 'app/nova_app.dart';
import 'app/state/app_controller.dart';
import 'data/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = LocalStore();
  final controller = AppController(store: store);
  await controller.initialize();
  runApp(NovaApp(controller: controller));
}

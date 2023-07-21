import 'package:alchronos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  registerDependencies();

  testWidgets('End to End Test', (tester) async {
    await tester.pumpWidget(const AlchronosApp());
  });
}

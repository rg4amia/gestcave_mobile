import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:gestcave/bindings/initial_binding.dart';
import 'package:gestcave/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    InitialBinding().dependencies();
  });

  tearDown(Get.reset);

  testWidgets('login screen loads as initial route', (tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/login'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'CONNEXION'), findsOneWidget);
  });
}

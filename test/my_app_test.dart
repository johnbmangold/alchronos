// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:alchronos/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  registerDependencies();

  testWidgets('Finds icon and button', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AlchronosApp());

    expect(find.byKey(const Key('loadingView')), findsOneWidget);

    // Initial controls are present
    // expect(find.byKey(const Key('drinkIcon')), findsOneWidget);
    // expect(find.byKey(const Key('drinkButton')), findsOneWidget);
  });

  // testWidgets('Test app accessibility', (tester) async {
  //   final SemanticsHandle handle = tester.ensureSemantics();
  //   await tester.pumpWidget(const AlchronosApp());

  //   // Checks that tappable nodes have a minimum size of 48 by 48 pixels
  //   // for Android.
  //   await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

  //   // Checks that tappable nodes have a minimum size of 44 by 44 pixels
  //   // for iOS.
  //   await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

  //   // Checks that touch targets with a tap or long press action are labeled.
  //   await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

  //   // Checks whether semantic nodes meet the minimum text contrast levels.
  //   // The recommended text contrast is 3:1 for larger text
  //   // (18 point and above regular).
  //   await expectLater(tester, meetsGuideline(textContrastGuideline));
  //   handle.dispose();
  // });
}

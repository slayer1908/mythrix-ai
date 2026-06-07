// Top-level smoke test — boots the app and verifies the splash renders.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mythrix_ai/app.dart';

void main() {
  testWidgets('MythrixApp builds without crashing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MythrixApp()),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

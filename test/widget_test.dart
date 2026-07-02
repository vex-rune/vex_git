import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vex_git/main.dart';

void main() {
  testWidgets('App boots and shows splash with progress indicator', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: VexGitApp()));
    expect(find.text('Vex Git'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // 让 splash 的延迟 timer 跑完
    await tester.pump(const Duration(milliseconds: 400));
  });
}
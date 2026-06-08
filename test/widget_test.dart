import 'package:cube_maze/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('game screen opens assembly instructions', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CubeMazeApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();

    expect(find.text('说明'), findsOneWidget);

    await tester.tap(find.text('说明'));
    await tester.pumpAndSettle();

    expect(find.text('第一关管道组装说明'), findsOneWidget);
    expect(find.text('管道模块 64 个'), findsOneWidget);
    expect(find.text('组装步骤'), findsOneWidget);
    expect(find.text('坐标摆放清单'), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
  });
}

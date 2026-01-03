import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:magnet_copy/providers/magnet_provider.dart';
import 'package:magnet_copy/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen displays empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => MagnetProvider(),
          child: const HomeScreen(),
        ),
      ),
    );

    expect(find.text('수집된 Magnet 링크가 없습니다'), findsOneWidget);
    expect(find.text('초기화'), findsOneWidget);
    expect(find.text('전체 복사'), findsOneWidget);
    expect(find.text('항상 위'), findsOneWidget);
    expect(find.text('총 0개 링크'), findsOneWidget);
  });

  test('MagnetProvider adds links and returns correct result', () {
    final provider = MagnetProvider();

    // First add should succeed
    var result = provider.addLink('magnet:?xt=urn:btih:ABC123&dn=TestFile');
    expect(result, AddLinkResult.added);
    expect(provider.count, 1);

    // Duplicate should return duplicate
    result = provider.addLink('magnet:?xt=urn:btih:ABC123&dn=TestFile');
    expect(result, AddLinkResult.duplicate);
    expect(provider.count, 1);

    // Different link should succeed
    result = provider.addLink('magnet:?xt=urn:btih:DEF456&dn=AnotherFile');
    expect(result, AddLinkResult.added);
    expect(provider.count, 2);

    provider.clearAll();
    expect(provider.count, 0);

    provider.dispose();
  });

  test('MagnetProvider returns invalid for non-magnet links', () {
    final provider = MagnetProvider();

    var result = provider.addLink('https://example.com');
    expect(result, AddLinkResult.invalid);
    expect(provider.count, 0);

    result = provider.addLink('magnet:?xt=urn:btih:ABC123');
    expect(result, AddLinkResult.added);
    expect(provider.count, 1);

    provider.dispose();
  });
}

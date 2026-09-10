import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/widgets/glass/sliver_collapsing_glass_header.dart';

void main() {
  testWidgets('collapsing glass header pins compact bar after scroll',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            key: const Key('test_scroll'),
            slivers: [
              const SliverCollapsingGlassHeader(
                topInset: 0,
                expandedBodyHeight: 160,
                collapsedBodyHeight: 56,
                horizontalPadding: 16,
                expanded: ColoredBox(
                  color: Colors.orange,
                  child: Center(
                    child: Text('expanded_header', key: Key('expanded_header')),
                  ),
                ),
                collapsed: ColoredBox(
                  color: Colors.blue,
                  child: Center(
                    child: Text('collapsed_header', key: Key('collapsed_header')),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => SizedBox(
                    height: 80,
                    child: Text('item_$index'),
                  ),
                  childCount: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('expanded_header')), findsOneWidget);
    // Fully visible surfaces skip Opacity (no saveLayer); only mid-fade uses it.
    expect(
      find.ancestor(
        of: find.byKey(const Key('expanded_header')),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
    expect(find.byKey(const Key('collapsed_header')), findsNothing);

    await tester.drag(find.byKey(const Key('test_scroll')), const Offset(0, -240));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('collapsed_header')), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byKey(const Key('collapsed_header')),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
    expect(find.byKey(const Key('expanded_header')), findsNothing);
    expect(find.text('item_0'), findsNothing);
  });

  test('delegate extents include top inset', () {
    final delegate = CollapsingGlassHeaderDelegate(
      topInset: 24,
      expandedBodyHeight: 120,
      collapsedBodyHeight: 48,
      expanded: const SizedBox.shrink(),
      collapsed: const SizedBox.shrink(),
    );
    expect(delegate.maxExtent, 144);
    expect(delegate.minExtent, 72);
  });
}

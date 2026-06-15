import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_card_state.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_stamp_style.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/widgets/loyalty_stamp_style_preview.dart';

void main() {
  testWidgets('MODERN aspect ratio renders without overflow', (tester) async {
    await tester.pumpWidget(_preview(style: _style()));

    final aspect = tester.widget<AspectRatio>(
      find.byKey(const ValueKey('loyalty-hero-aspect')),
    );
    expect(aspect.aspectRatio, closeTo(1200 / 628, 0.001));
    expect(tester.takeException(), isNull);
  });

  testWidgets('COMPACT aspect ratio renders without overflow', (tester) async {
    await tester.pumpWidget(_preview(style: _style(layoutVariant: 'COMPACT')));

    final aspect = tester.widget<AspectRatio>(
      find.byKey(const ValueKey('loyalty-hero-aspect')),
    );
    expect(aspect.aspectRatio, closeTo(1032 / 336, 0.001));
    expect(tester.takeException(), isNull);
  });

  testWidgets('MODERN uses business subtitle and program headline', (
    tester,
  ) async {
    await tester.pumpWidget(_preview(style: _style()));

    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('loyalty-hero-subtitle')))
          .data,
      'Tavrix Cafe',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('loyalty-hero-headline')))
          .data,
      'Tavrix Cafe Stamp Card',
    );
  });

  testWidgets('COMPACT uses program subtitle and business headline', (
    tester,
  ) async {
    await tester.pumpWidget(_preview(style: _style(layoutVariant: 'COMPACT')));

    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('loyalty-hero-subtitle')))
          .data,
      'Tavrix Cafe Stamp Card',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('loyalty-hero-headline')))
          .data,
      'Tavrix Cafe',
    );
  });

  testWidgets('progress badge clamps goal and is not duplicated', (
    tester,
  ) async {
    await tester.pumpWidget(
      _preview(cardState: _cardState(stampCount: 3, stampGoal: 12)),
    );

    expect(find.text('stamps'), findsOneWidget);
    expect(find.text('3 / 10'), findsOneWidget);
  });

  testWidgets('reward banner shows backend reward prefix', (tester) async {
    await tester.pumpWidget(_preview());

    expect(find.text('Reward: Free coffee'), findsOneWidget);
  });

  testWidgets('stamp grid renders filled and empty stamps', (tester) async {
    await tester.pumpWidget(
      _preview(cardState: _cardState(stampCount: 3, stampGoal: 10)),
    );

    expect(_stampCells(prefix: 'loyalty-stamp-cell-filled'), findsNWidgets(3));
    expect(_stampCells(prefix: 'loyalty-stamp-cell-empty'), findsNWidgets(7));
  });

  testWidgets('stamp goal above 10 renders only 10 hero stamps', (
    tester,
  ) async {
    await tester.pumpWidget(
      _preview(cardState: _cardState(stampCount: 11, stampGoal: 15)),
    );

    expect(_stampCells(prefix: 'loyalty-stamp-cell-filled'), findsNWidgets(10));
    expect(find.text('10 / 10'), findsOneWidget);
  });

  testWidgets('invalid null and empty colors fallback safely', (tester) async {
    await tester.pumpWidget(
      _preview(
        style: const LoyaltyStampStyle(
          id: 'style',
          loyaltyProgramId: 'program',
          presetKey: 'STAR',
          backgroundColor: 'not-a-color',
          accentColor: '',
          textColor: null,
          imageBackgroundColor: '#xyz',
          imageSurfaceColor: '',
          imageAccentColor: null,
          imageTextColor: ' ',
          stampFilledColor: '#12',
          stampEmptyColor: 'nope',
          rewardBannerColor: null,
          layoutVariant: 'MODERN',
        ),
      ),
    );

    expect(find.byType(LoyaltyStampStylePreview), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('all preset keys render without crashing', (tester) async {
    for (final key in const [
      'STAR',
      'COOKIE',
      'COFFEE',
      'BOWL',
      'BURGER',
      'PIZZA',
      'HEART',
      'CUPCAKE',
      'UNKNOWN',
    ]) {
      await tester.pumpWidget(_preview(style: _style(presetKey: key)));
      expect(find.byType(LoyaltyStampStylePreview), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

Finder _stampCells({required String prefix}) {
  return find.byWidgetPredicate((widget) {
    final key = widget.key;
    return key is ValueKey<String> && key.value.startsWith(prefix);
  });
}

Widget _preview({LoyaltyStampStyle? style, LoyaltyCardState? cardState}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: LoyaltyStampStylePreview(
            style: style ?? _style(),
            cardState: cardState ?? _cardState(),
            businessName: 'Tavrix Cafe',
          ),
        ),
      ),
    ),
  );
}

LoyaltyCardState _cardState({int stampCount = 3, int stampGoal = 10}) {
  return LoyaltyCardState(
    stampCount: stampCount,
    stampGoal: stampGoal,
    rewardReady: false,
    progressPercent: 30,
    rewardName: 'Free coffee',
    programName: 'Tavrix Cafe Stamp Card',
  );
}

LoyaltyStampStyle _style({
  String presetKey = 'STAR',
  String layoutVariant = 'MODERN',
}) {
  return LoyaltyStampStyle(
    id: 'style',
    loyaltyProgramId: 'program',
    presetKey: presetKey,
    imageBackgroundColor: '#7c2d12',
    imageSurfaceColor: '#92400e',
    imageAccentColor: '#facc15',
    imageTextColor: '#ffffff',
    stampFilledColor: '#facc15',
    stampEmptyColor: '#d6d3d1',
    rewardBannerColor: '#a16207',
    layoutVariant: layoutVariant,
  );
}

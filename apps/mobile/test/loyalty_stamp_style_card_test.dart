import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_program.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_requests.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_stamp_style.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/widgets/loyalty_stamp_style_card.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/widgets/loyalty_stamp_style_preview.dart';

void main() {
  testWidgets('style section and preview render for editable role', (
    tester,
  ) async {
    UpdateLoyaltyStampStyleRequest? savedRequest;

    await tester.pumpWidget(
      _widget(canEdit: true, onSave: (request) => savedRequest = request),
    );

    expect(find.text('Loyalty Card Style'), findsOneWidget);
    expect(find.byType(LoyaltyStampStylePreview), findsOneWidget);
    expect(find.text('Tavrix Cafe Stamp Card'), findsOneWidget);
    expect(find.text('Save card style'), findsOneWidget);

    await tester.ensureVisible(find.text('Save card style'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save card style'));
    await tester.pump();

    expect(savedRequest?.presetKey, 'COFFEE');
    expect(savedRequest?.layoutVariant, 'MODERN');
  });

  testWidgets('staff sees view-only message and no save button', (
    tester,
  ) async {
    await tester.pumpWidget(_widget(canEdit: false));

    expect(
      find.text('Only owners and managers can edit the card style.'),
      findsOneWidget,
    );
    expect(find.text('Save card style'), findsNothing);
  });

  testWidgets('custom color fields render in custom mode', (tester) async {
    await tester.pumpWidget(
      _widget(canEdit: true, style: _style(colorMode: 'CUSTOM')),
    );

    expect(find.text('Background color'), findsOneWidget);
    expect(find.text('Reward banner color'), findsOneWidget);
  });

  testWidgets('missing active program state is safe', (tester) async {
    await tester.pumpWidget(
      _widget(
        canEdit: true,
        program: null,
        includeStyle: false,
        errorMessage:
            'No active loyalty program is available for card styling yet.',
      ),
    );

    expect(find.text('Loyalty Card Style'), findsOneWidget);
    expect(find.byType(LoyaltyStampStylePreview), findsOneWidget);
    expect(
      find.text('No active loyalty program is available for card styling yet.'),
      findsOneWidget,
    );
    expect(find.text('Save card style'), findsNothing);
  });
}

Widget _widget({
  required bool canEdit,
  LoyaltyProgram? program = _program,
  LoyaltyStampStyle? style,
  bool includeStyle = true,
  String? errorMessage,
  ValueChanged<UpdateLoyaltyStampStyleRequest>? onSave,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: LoyaltyStampStyleCard(
          stampPresets: _presets,
          stampStyle: includeStyle ? style ?? _style() : null,
          businessName: 'Tavrix Cafe',
          program: program,
          selectedMembership: null,
          canEdit: canEdit,
          isLoading: false,
          isSaving: false,
          errorMessage: errorMessage,
          onSave: onSave ?? (_) {},
        ),
      ),
    ),
  );
}

const _program = LoyaltyProgram(
  id: 'loyalty_program_id',
  businessId: 'bus_123',
  name: 'Tavrix Cafe Stamp Card',
  stampGoal: 7,
  rewardName: 'Free coffee',
);

const _presets = LoyaltyStampPresets(
  presets: [
    LoyaltyStampPreset(key: 'STAR', label: 'Star'),
    LoyaltyStampPreset(key: 'COFFEE', label: 'Coffee'),
  ],
  styleTypes: ['PRESET'],
  layoutVariants: ['MODERN', 'COMPACT'],
);

LoyaltyStampStyle _style({String colorMode = 'PRESET'}) {
  return LoyaltyStampStyle(
    id: 'stamp_style_id',
    loyaltyProgramId: 'loyalty_program_id',
    styleType: 'PRESET',
    presetKey: 'COFFEE',
    themePreset: colorMode == 'CUSTOM' ? 'CUSTOM' : 'COFFEE',
    colorMode: colorMode,
    backgroundColor: '#111827',
    accentColor: '#f59e0b',
    textColor: '#ffffff',
    walletBackgroundColor: '#2563eb',
    imageBackgroundColor: '#7c2d12',
    imageSurfaceColor: '#92400e',
    imageAccentColor: '#facc15',
    imageTextColor: '#ffffff',
    stampFilledColor: '#facc15',
    stampEmptyColor: '#d6d3d1',
    rewardBannerColor: '#a16207',
    layoutVariant: 'MODERN',
    isDefault: false,
  );
}

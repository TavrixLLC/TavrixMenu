import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/theme/v2/waflo_theme_v2.dart';
import 'package:tavrix_menu_mobile/core/theme/v2/waflo_tokens_v2.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v2/waflo_button_v2.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v2/waflo_card_v2.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v2/waflo_empty_state_v2.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v2/waflo_input_v2.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v2/waflo_screen_v2.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v2/waflo_section_header_v2.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v2/waflo_status_badge_v2.dart';
import 'package:tavrix_menu_mobile/shared/widgets/v2/waflo_step_card_v2.dart';

void main() {
  group('Waflo UI V2 Design System Tokens & Theme Tests', () {
    test('WafloThemeV2 light matches V2 color tokens', () {
      final theme = WafloThemeV2.light;
      expect(theme.colorScheme.primary, WafloColorsV2.primaryCoral);
      expect(theme.colorScheme.secondary, WafloColorsV2.accentCrimson);
      expect(theme.colorScheme.error, WafloColorsV2.danger);
      expect(theme.scaffoldBackgroundColor, WafloColorsV2.backgroundCanvas);
    });
  });

  group('Waflo UI V2 Widget Rendering Tests', () {
    testWidgets('WafloButtonV2 renders and responds to tap', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WafloButtonV2(
              label: 'حفظ التغييرات',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('حفظ التغييرات'), findsOneWidget);
      await tester.tap(find.text('حفظ التغييرات'));
      expect(pressed, isTrue);
    });

    testWidgets('WafloCardV2 renders child and clickable state', (
      tester,
    ) async {
      var cardTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WafloCardV2(
              onTap: () => cardTapped = true,
              child: const Text('بطاقة المنيو V2'),
            ),
          ),
        ),
      );

      expect(find.text('بطاقة المنيو V2'), findsOneWidget);
      await tester.tap(find.text('بطاقة المنيو V2'));
      expect(cardTapped, isTrue);
    });

    testWidgets('WafloScreenV2 renders scrollable child and app bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WafloScreenV2(
            title: 'إعدادات المطعم',
            child: Text('محتوى الصفحة V2'),
          ),
        ),
      );

      expect(find.text('إعدادات المطعم'), findsOneWidget);
      expect(find.text('محتوى الصفحة V2'), findsOneWidget);
    });

    testWidgets(
      'WafloSectionHeaderV2 displays title and handles action click',
      (tester) async {
        var actionTapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WafloSectionHeaderV2(
                title: 'قائمة الطعام العائلية',
                subtitle: 'اختر تصنيفات المنيو المتاحة لزبائنك',
                actionLabel: 'إضافة تصنيف',
                onActionPressed: () => actionTapped = true,
              ),
            ),
          ),
        );

        expect(find.text('قائمة الطعام العائلية'), findsOneWidget);
        expect(
          find.text('اختر تصنيفات المنيو المتاحة لزبائنك'),
          findsOneWidget,
        );
        expect(find.text('إضافة تصنيف'), findsOneWidget);
        await tester.tap(find.text('إضافة تصنيف'));
        expect(actionTapped, isTrue);
      },
    );

    testWidgets(
      'WafloStepCardV2 renders onboarding tasks with state indicators',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  WafloStepCardV2(
                    stepNumber: 1,
                    title: 'إضافة الأقسام والوجبات',
                    description: 'أضف تصنيفات مثل المقبلات والوجبات الرئيسية',
                    state: WafloStepState.completed,
                  ),
                  WafloStepCardV2(
                    stepNumber: 2,
                    title: 'تحميل الرمز التعريفي QR',
                    description: 'قم بتحميل رمز المنيو لطباعته على الطاولات',
                    state: WafloStepState.active,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('إضافة الأقسام والوجبات'), findsOneWidget);
        expect(find.text('تحميل الرمز التعريفي QR'), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
      },
    );

    testWidgets(
      'WafloEmptyStateV2 displays icon, title, description, and action button',
      (tester) async {
        var actionTriggered = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WafloEmptyStateV2(
                icon: Icons.fastfood_outlined,
                title: 'لا توجد تصنيفات حتى الآن',
                description: 'ابدأ بإضافة أول تصنيف لتجهيز المنيو الخاص بك',
                actionLabel: 'إضافة تصنيف جديد',
                onActionPressed: () => actionTriggered = true,
              ),
            ),
          ),
        );

        expect(find.text('لا توجد تصنيفات حتى الآن'), findsOneWidget);
        expect(find.text('إضافة تصنيف جديد'), findsOneWidget);
        await tester.tap(find.text('إضافة تصنيف جديد'));
        expect(actionTriggered, isTrue);
      },
    );

    testWidgets('WafloStatusBadgeV2 renders with type styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WafloStatusBadgeV2(
                  label: 'نشط حالياً',
                  type: WafloStatusTypeV2.success,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('نشط حالياً'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('WafloInputV2 renders form input fields with labels', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WafloInputV2(
              label: 'اسم الوجبة بالكامل',
              hint: 'مثال: كباب لحم عراقي',
              controller: controller,
              prefixIcon: Icons.restaurant_menu,
            ),
          ),
        ),
      );

      expect(find.text('اسم الوجبة بالكامل'), findsOneWidget);
      expect(find.text('مثال: كباب لحم عراقي'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    });
  });
}

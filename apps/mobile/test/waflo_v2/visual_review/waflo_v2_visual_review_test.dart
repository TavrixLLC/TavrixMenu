import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'waflo_v2_visual_review_app.dart';

void main() {
  for (final scenario in WafloVisualReviewScenario.values) {
    testWidgets('${scenario.queryValue} review surface renders safely', (
      tester,
    ) async {
      tester.view.physicalSize = switch (scenario) {
        WafloVisualReviewScenario.stateGalleryArabic => const Size(430, 1280),
        WafloVisualReviewScenario.accessibilitySmallArabic => const Size(
          360,
          800,
        ),
        WafloVisualReviewScenario.providerComparisonEnglish => const Size(
          430,
          1500,
        ),
        _ => const Size(430, 932),
      };
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildVisualReviewApp(scenario));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      final direction = tester.widget<Directionality>(
        find.byType(Directionality).first,
      );
      final expectsRtl = switch (scenario) {
        WafloVisualReviewScenario.managerEnglish ||
        WafloVisualReviewScenario.studioEnglish ||
        WafloVisualReviewScenario.providerComparisonEnglish => false,
        _ => true,
      };
      expect(
        direction.textDirection,
        expectsRtl ? TextDirection.rtl : TextDirection.ltr,
      );
    });
  }
}

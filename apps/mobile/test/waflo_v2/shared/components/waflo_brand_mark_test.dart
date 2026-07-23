import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_brand_mark.dart';

import '../../test_fixtures.dart';

void main() {
  testWidgets('official mark keeps minimum size and explicit clear space', (
    tester,
  ) async {
    await tester.pumpWidget(
      foundationHarness(
        home: const Scaffold(body: Center(child: WafloBrandMark())),
      ),
    );
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, WafloBrandMark.assetPath);
    expect(image.width, WafloBrandMark.recommendedUiSize);
    expect(image.height, WafloBrandMark.recommendedUiSize);
    expect(
      tester.getSize(find.byType(WafloBrandMark)).width,
      WafloBrandMark.recommendedUiSize + (WafloBrandMark.defaultClearSpace * 2),
    );
  });

  test('mark rejects rendering below the official minimum', () {
    expect(
      () => WafloBrandMark(markSize: WafloBrandMark.minimumRenderedSize - 1),
      throwsAssertionError,
    );
  });
}

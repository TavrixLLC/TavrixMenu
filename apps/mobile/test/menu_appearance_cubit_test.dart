import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/copy/pilot_arabic_copy.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/repositories/business_repository.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/get_my_business.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/domain/entities/business_appearance.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/domain/entities/menu_template.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/domain/repositories/menu_appearance_repository.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/domain/usecases/get_business_appearance.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/domain/usecases/get_menu_template_catalog.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/domain/usecases/update_business_appearance.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/presentation/bloc/menu_appearance_cubit.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/presentation/bloc/menu_appearance_state.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/presentation/pages/menu_appearance_screen.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/presentation/utils/menu_template_preview_url.dart';
import 'package:tavrix_menu_mobile/shared/widgets/waflo_button.dart';

void main() {
  test('loads catalog and saves selected template', () async {
    final appearanceRepository = _FakeMenuAppearanceRepository();
    final cubit = _cubit(appearanceRepository);

    await cubit.load();
    expect(cubit.state.status, MenuAppearanceStatus.success);
    expect(cubit.state.currentTemplateId, 'waflo-warm');

    cubit.selectTemplate('minimal-modern');
    expect(cubit.state.canSave, isTrue);

    await cubit.save();
    expect(appearanceRepository.savedTemplateId, 'minimal-modern');
    expect(cubit.state.currentTemplateId, 'minimal-modern');
    expect(cubit.state.successMessage, PilotArabicCopy.menuAppearanceSaved);

    await cubit.close();
  });

  test('backend 403 keeps draft and shows permission message', () async {
    final appearanceRepository = _FakeMenuAppearanceRepository(
      updateFailure: const ForbiddenFailure(),
    );
    final cubit = _cubit(appearanceRepository);

    await cubit.load();
    cubit.selectTemplate('minimal-modern');
    await cubit.save();

    expect(cubit.state.currentTemplateId, 'waflo-warm');
    expect(cubit.state.draftTemplateId, 'minimal-modern');
    expect(cubit.state.saveForbidden, isTrue);
    expect(cubit.state.errorMessage, PilotArabicCopy.menuAppearancePermission);

    await cubit.close();
  });

  test('appearance permission false disables save', () async {
    final appearanceRepository = _FakeMenuAppearanceRepository();
    final cubit = _cubit(
      appearanceRepository,
      business: const Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: 'tavrix-cafe',
        publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
        permissions: BusinessPermissions(
          canManageAppearance: false,
          canManageMenu: false,
        ),
      ),
    );

    await cubit.load();
    cubit.selectTemplate('minimal-modern');

    expect(cubit.state.canManageAppearance, isFalse);
    expect(cubit.state.canSave, isFalse);

    await cubit.close();
  });

  test(
    'template integration stays on production endpoints and preview shape',
    () {
      final preview = buildMenuTemplatePreviewUri(
        business: const Business(
          id: 'bus_123',
          name: 'Tavrix Cafe',
          slug: 'tavrix-cafe',
          publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
        ),
        templateId: 'minimal-modern',
        customerWebBaseUrl: 'https://menu.example.test',
      );

      expect(
        preview.toString(),
        'https://menu.example.test/m/tavrix-cafe?previewTemplateId=minimal-modern',
      );
      expect(preview.toString(), isNot(contains('mobilePreviewUrl')));
      expect(preview.toString(), isNot(contains('/dev/menu-templates')));
    },
  );

  testWidgets('preview copy hides implementation query parameters', (
    tester,
  ) async {
    final appearanceRepository = _FakeMenuAppearanceRepository();
    final cubit = _cubit(appearanceRepository);
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider<MenuAppearanceCubit>.value(
        value: cubit,
        child: const MaterialApp(
          home: MenuAppearanceScreen(
            customerWebBaseUrl: 'https://menu.example.test',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('${PilotArabicCopy.previewDraftMenu} (Tavrix Cafe)'),
      findsOneWidget,
    );
    expect(find.text(_wafloWarmArabicTitle), findsOneWidget);
    expect(find.text(_minimalModernArabicTitle), findsOneWidget);
    expect(find.text('Waflo Warm'), findsNothing);
    expect(find.text('Minimal Modern'), findsNothing);
    expect(
      find.textContaining(RegExp('css|premium|template', caseSensitive: false)),
      findsNothing,
    );
    expect(find.textContaining('previewTemplateId'), findsNothing);
  });

  testWidgets('template cards render on a small Android viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appearanceRepository = _FakeMenuAppearanceRepository(
      templates: _smallAndroidTemplates,
    );
    final cubit = _cubit(appearanceRepository);
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider<MenuAppearanceCubit>.value(
        value: cubit,
        child: const MaterialApp(
          home: MenuAppearanceScreen(
            customerWebBaseUrl: 'https://menu.example.test',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.textContaining(PilotArabicCopy.previewDraftMenu),
      findsOneWidget,
    );
    expect(find.text(_arabicTemplateName), findsOneWidget);
    expect(find.text(_arabicTemplateDescription), findsOneWidget);
    expect(find.text(_arabicCafeLabel), findsOneWidget);
    expect(find.text(_arabicLayoutLabel), findsOneWidget);
    expect(find.textContaining('previewTemplateId'), findsNothing);
    expect(find.textContaining('minimal-modern'), findsNothing);
  });

  testWidgets('preview is disabled when public menu link is not ready', (
    tester,
  ) async {
    final appearanceRepository = _FakeMenuAppearanceRepository();
    final cubit = _cubit(
      appearanceRepository,
      business: const Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: '',
        publicMenuUrl: '',
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider<MenuAppearanceCubit>.value(
        value: cubit,
        child: const MaterialApp(
          home: MenuAppearanceScreen(customerWebBaseUrl: ''),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(unavailablePreviewMessage), findsWidgets);
    final previewButton = tester.widget<WafloButton>(
      find.widgetWithText(WafloButton, PilotArabicCopy.previewAction).first,
    );
    expect(previewButton.onPressed, isNull);
  });

  test('preview URL builder uses business slug and template id', () {
    final uri = buildMenuTemplatePreviewUri(
      business: const Business(
        id: 'bus_123',
        name: 'Happy Birthday',
        slug: 'happy-birthday-2',
        publicMenuUrl: 'https://card.waflo.app/m/happy-birthday-2',
      ),
      templateId: 'waflo-warm',
      customerWebBaseUrl: '',
    );

    expect(
      uri.toString(),
      'https://card.waflo.app/m/happy-birthday-2?previewTemplateId=waflo-warm',
    );
  });

  test(
    'preview URL builder uses configured customer web base when available',
    () {
      final uri = buildMenuTemplatePreviewUri(
        business: const Business(
          id: 'bus_123',
          name: 'Tavrix Cafe',
          slug: 'tavrix-cafe',
          publicMenuUrl: '',
        ),
        templateId: 'minimal-modern',
        customerWebBaseUrl: 'http://localhost:3001/',
      );

      expect(
        uri.toString(),
        'http://localhost:3001/m/tavrix-cafe?previewTemplateId=minimal-modern',
      );
    },
  );

  test('preview URL builder returns null when slug or base is missing', () {
    final missingSlug = buildMenuTemplatePreviewUri(
      business: const Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: '',
        publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
      ),
      templateId: 'waflo-warm',
      customerWebBaseUrl: '',
    );
    final missingBase = buildMenuTemplatePreviewUri(
      business: const Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: 'tavrix-cafe',
        publicMenuUrl: '',
      ),
      templateId: 'waflo-warm',
      customerWebBaseUrl: '',
    );

    expect(missingSlug, isNull);
    expect(missingBase, isNull);
  });
}

MenuAppearanceCubit _cubit(
  _FakeMenuAppearanceRepository appearanceRepository, {
  Business business = _readyBusiness,
}) {
  final businessRepository = _FakeBusinessRepository(business);
  return MenuAppearanceCubit(
    getMyBusiness: GetMyBusiness(businessRepository),
    getMenuTemplateCatalog: GetMenuTemplateCatalog(appearanceRepository),
    getBusinessAppearance: GetBusinessAppearance(appearanceRepository),
    updateBusinessAppearance: UpdateBusinessAppearance(appearanceRepository),
  );
}

const _readyBusiness = Business(
  id: 'bus_123',
  name: 'Tavrix Cafe',
  slug: 'tavrix-cafe',
  publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
  permissions: BusinessPermissions.owner(),
);

const _arabicTemplateName = '\u0642\u0627\u0644\u0628 \u062f\u0627\u0641\u0626';
const _arabicTemplateDescription =
    '\u0623\u0644\u0648\u0627\u0646 \u062f\u0627\u0641\u0626\u0629 '
    '\u0644\u0644\u0645\u0646\u064a\u0648 '
    '\u0648\u0627\u0644\u0648\u0644\u0627\u0621.';
const _arabicCafeLabel = '\u0643\u0627\u0641\u064a\u0647\u0627\u062a';
const _arabicLayoutLabel =
    '\u0628\u0637\u0627\u0642\u0627\u062a '
    '\u0648\u0627\u0636\u062d\u0629';
const _wafloWarmArabicTitle =
    '\u062f\u0627\u0641\u0626 \u0648\u0645\u0631\u064a\u062d';
const _minimalModernArabicTitle =
    '\u0628\u0633\u064a\u0637 \u0648\u062d\u062f\u064a\u062b';

const _smallAndroidTemplates = [
  MenuTemplate(
    id: 'pilotWarm',
    displayName: _arabicTemplateName,
    description: _arabicTemplateDescription,
    bestFor: [
      '\u0643\u0627\u0641\u064a\u0647\u0627\u062a\u060c '
          '\u0645\u0637\u0627\u0639\u0645 '
          '\u0639\u0627\u0626\u0644\u064a\u0629\u060c '
          '\u0645\u062e\u0627\u0628\u0632 '
          '\u0648\u062d\u0644\u0648\u064a\u0627\u062a',
    ],
    previewColors: ['#FF6B4A', '#FFF8F2', '#43A047'],
    layoutLabel: _arabicLayoutLabel,
  ),
  MenuTemplate(
    id: 'minimal-modern',
    displayName: 'Minimal Modern',
    description: 'Clean template.',
  ),
];

class _FakeBusinessRepository implements BusinessRepository {
  const _FakeBusinessRepository(this.business);

  final Business business;

  @override
  Future<Either<Failure, Business>> getMyBusiness() async {
    return Right(business);
  }

  @override
  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Business>> updateBusiness({
    required String id,
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
    String? logoUrl,
    String? coverUrl,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeMenuAppearanceRepository implements MenuAppearanceRepository {
  _FakeMenuAppearanceRepository({
    this.updateFailure,
    List<MenuTemplate>? templates,
  }) : templates =
           templates ??
           const [
             MenuTemplate(
               id: 'waflo-warm',
               displayName: 'Waflo Warm',
               description: 'Default template.',
             ),
             MenuTemplate(
               id: 'minimal-modern',
               displayName: 'Minimal Modern',
               description: 'Clean template.',
             ),
           ];

  final Failure? updateFailure;
  final List<MenuTemplate> templates;
  String? savedTemplateId;

  @override
  Future<Either<Failure, List<MenuTemplate>>> getTemplates() async {
    return Right(templates);
  }

  @override
  Future<Either<Failure, BusinessAppearance>> getBusinessAppearance(
    String businessId,
  ) async {
    return Right(
      BusinessAppearance(businessId: businessId, menuTemplateId: 'waflo-warm'),
    );
  }

  @override
  Future<Either<Failure, BusinessAppearance>> updateBusinessAppearance({
    required String businessId,
    required String menuTemplateId,
  }) async {
    final failure = updateFailure;
    if (failure != null) {
      return Left(failure);
    }
    savedTemplateId = menuTemplateId;
    return Right(
      BusinessAppearance(
        businessId: businessId,
        menuTemplateId: menuTemplateId,
      ),
    );
  }
}

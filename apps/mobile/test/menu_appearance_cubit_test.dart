import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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
    expect(cubit.state.successMessage, 'Menu template saved.');

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
    expect(cubit.state.errorMessage, contains('permission'));

    await cubit.close();
  });

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
      find.text(
        "Preview opens Tavrix Cafe's public menu with this design without saving changes.",
      ),
      findsOneWidget,
    );
    expect(find.textContaining('previewTemplateId'), findsNothing);
  });
}

MenuAppearanceCubit _cubit(_FakeMenuAppearanceRepository appearanceRepository) {
  final businessRepository = _FakeBusinessRepository();
  return MenuAppearanceCubit(
    getMyBusiness: GetMyBusiness(businessRepository),
    getMenuTemplateCatalog: GetMenuTemplateCatalog(appearanceRepository),
    getBusinessAppearance: GetBusinessAppearance(appearanceRepository),
    updateBusinessAppearance: UpdateBusinessAppearance(appearanceRepository),
  );
}

class _FakeBusinessRepository implements BusinessRepository {
  @override
  Future<Either<Failure, Business>> getMyBusiness() async {
    return const Right(
      Business(
        id: 'bus_123',
        name: 'Tavrix Cafe',
        slug: 'tavrix-cafe',
        publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
        permissions: BusinessPermissions.owner(),
      ),
    );
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
  _FakeMenuAppearanceRepository({this.updateFailure});

  final Failure? updateFailure;
  String? savedTemplateId;

  @override
  Future<Either<Failure, List<MenuTemplate>>> getTemplates() async {
    return const Right([
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
    ]);
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

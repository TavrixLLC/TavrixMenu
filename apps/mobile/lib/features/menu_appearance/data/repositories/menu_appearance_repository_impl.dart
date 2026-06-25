import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/run_safe.dart';
import '../../domain/entities/business_appearance.dart';
import '../../domain/entities/menu_template.dart';
import '../../domain/repositories/menu_appearance_repository.dart';
import '../datasources/menu_appearance_remote_data_source.dart';

class MenuAppearanceRepositoryImpl implements MenuAppearanceRepository {
  MenuAppearanceRepositoryImpl({
    required MenuAppearanceRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required bool devFallbackEnabled,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo,
       _devFallbackEnabled = devFallbackEnabled;

  final MenuAppearanceRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final bool _devFallbackEnabled;
  String _devTemplateId = 'waflo-warm';

  bool get _useDevData =>
      !_remoteDataSource.canCallBackend && _devFallbackEnabled;

  @override
  Future<Either<Failure, List<MenuTemplate>>> getTemplates() {
    return runSafe(() async {
      if (_useDevData) {
        return _devTemplates;
      }

      final models = await _remoteDataSource.getTemplates();
      return models.map((model) => model.toEntity()).toList(growable: false);
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, BusinessAppearance>> getBusinessAppearance(
    String businessId,
  ) {
    return runSafe(() async {
      if (_useDevData) {
        return BusinessAppearance(
          businessId: businessId,
          menuTemplateId: _devTemplateId,
        );
      }

      final model = await _remoteDataSource.getBusinessAppearance(businessId);
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, BusinessAppearance>> updateBusinessAppearance({
    required String businessId,
    required String menuTemplateId,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        if (!_devTemplates.any((template) => template.id == menuTemplateId)) {
          return BusinessAppearance(
            businessId: businessId,
            menuTemplateId: _devTemplateId,
          );
        }
        _devTemplateId = menuTemplateId;
        return BusinessAppearance(
          businessId: businessId,
          menuTemplateId: _devTemplateId,
        );
      }

      final model = await _remoteDataSource.updateBusinessAppearance(
        businessId: businessId,
        menuTemplateId: menuTemplateId,
      );
      return model.toEntity();
    }, _networkInfo);
  }
}

const _devTemplates = [
  MenuTemplate(
    id: 'waflo-warm',
    displayName: 'Waflo Warm',
    description:
        'Coral, cream, and green with rounded cards for restaurants and cafes.',
    bestFor: ['Most restaurants', 'Cafes', 'Casual dining'],
    previewColors: ['#FF6B4A', '#FFF8F2', '#43A047'],
    layoutLabel: 'Rounded card grid',
    supportedFeatures: ['loyalty', 'rtl', 'images'],
  ),
  MenuTemplate(
    id: 'coffeehouse-premium',
    displayName: 'Coffeehouse Premium',
    description:
        'Dark green, gold, and cream with a polished cafe and dessert feel.',
    bestFor: ['Premium cafes', 'Desserts', 'Roasters'],
    previewColors: ['#1F3D2B', '#F59E0B', '#FFF8F2'],
    layoutLabel: 'Editorial cafe layout',
    supportedFeatures: ['loyalty', 'rtl', 'images'],
  ),
  MenuTemplate(
    id: 'street-bites',
    displayName: 'Street Bites',
    description:
        'Bold coral and red accents for fast-food and street-food browsing.',
    bestFor: ['Fast food', 'Street food', 'Takeaway counters'],
    previewColors: ['#FF6B4A', '#F97316', '#DC2626'],
    layoutLabel: 'Compact energetic list',
    supportedFeatures: ['loyalty', 'rtl', 'images'],
  ),
  MenuTemplate(
    id: 'minimal-modern',
    displayName: 'Minimal Modern',
    description: 'Clean white and neutral surfaces with a subtle coral accent.',
    bestFor: ['Premium restaurants', 'Simple menus', 'Hotel cafes'],
    previewColors: ['#FFFFFF', '#1F2933', '#FF6B4A'],
    layoutLabel: 'Border-first spacious rows',
    supportedFeatures: ['loyalty', 'rtl', 'images'],
  ),
];

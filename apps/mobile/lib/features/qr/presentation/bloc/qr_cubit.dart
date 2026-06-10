import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/config/app_config.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../business_setup/domain/entities/business.dart';
import '../../../business_setup/domain/entities/public_link.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import '../../../business_setup/domain/usecases/get_public_link.dart';
import 'qr_state.dart';

class QRCubit extends Cubit<QRState> {
  QRCubit({
    required GetMyBusiness getMyBusiness,
    required GetPublicLink getPublicLink,
    required AppConfig config,
  }) : _getMyBusiness = getMyBusiness,
       _getPublicLink = getPublicLink,
       _config = config,
       super(const QRState.initial());

  final GetMyBusiness _getMyBusiness;
  final GetPublicLink _getPublicLink;
  final AppConfig _config;

  Future<void> load() async {
    emit(const QRState(status: QRStatus.loading));

    final businessResult = await _getMyBusiness();
    await businessResult.fold(
      (failure) async => emit(
        QRState(
          status: QRStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (business) async {
        if (business == null) {
          emit(
            const QRState(
              status: QRStatus.failure,
              errorMessage:
                  'Business setup is required before opening QR menu.',
            ),
          );
          return;
        }

        final linkResult = await _getPublicLink(business.id);
        linkResult.fold(
          (_) => emit(
            QRState(
              status: QRStatus.success,
              business: business,
              publicLink: _fallbackLink(business),
              usedFallback: true,
            ),
          ),
          (publicLink) => emit(
            QRState(
              status: QRStatus.success,
              business: business,
              publicLink: publicLink.publicMenuUrl.isEmpty
                  ? _fallbackLink(business)
                  : publicLink,
              usedFallback: publicLink.publicMenuUrl.isEmpty,
            ),
          ),
        );
      },
    );
  }

  PublicLink _fallbackLink(Business business) {
    final url = _config.customerMenuUrl(business.slug);
    return PublicLink(
      businessId: business.id,
      slug: business.slug,
      publicMenuPath: '/m/${business.slug}',
      publicMenuUrl: url,
      qrPayload: url,
    );
  }
}

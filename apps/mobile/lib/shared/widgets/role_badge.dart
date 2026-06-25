import '../../core/utils/business_role.dart';
import 'status_badge.dart';

class RoleBadge extends StatusBadge {
  RoleBadge({required String role, super.key})
    : super(label: BusinessRole.displayLabel(role));
}

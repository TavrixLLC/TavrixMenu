class BusinessRole {
  const BusinessRole._();

  static const owner = 'OWNER';
  static const manager = 'MANAGER';
  static const staff = 'STAFF';
  static const operator = 'BUSINESS_OPERATOR';

  static const _knownRoles = {owner, manager, staff};

  static String normalize(String? role) {
    final normalized = role?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return operator;
    }
    return _knownRoles.contains(normalized) ? normalized : operator;
  }

  static bool isKnown(String? role) {
    final normalized = role?.trim().toUpperCase();
    return normalized != null && _knownRoles.contains(normalized);
  }

  static String displayLabel(String? role) {
    return switch (normalize(role)) {
      owner => 'Owner',
      manager => 'Manager',
      staff => 'Staff',
      _ => 'Business Operator',
    };
  }
}

import 'package:equatable/equatable.dart';

class ReorderMenuRecord extends Equatable {
  const ReorderMenuRecord({required this.id, required this.sortOrder});

  final String id;
  final int sortOrder;

  Map<String, dynamic> toJson() {
    return {'id': id, 'sortOrder': sortOrder};
  }

  @override
  List<Object?> get props => [id, sortOrder];
}

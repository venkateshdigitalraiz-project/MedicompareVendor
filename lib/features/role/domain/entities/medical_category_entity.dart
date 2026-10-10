import 'package:equatable/equatable.dart';

class MedicalCategoryEntity extends Equatable {
  final String id;
  final String name;

  const MedicalCategoryEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

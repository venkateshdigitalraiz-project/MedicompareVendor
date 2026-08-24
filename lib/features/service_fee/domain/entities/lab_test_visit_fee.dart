import 'package:equatable/equatable.dart';

class LabTestVisitFee extends Equatable {
  final String visitType;
  final double homeVisitFee;
  final double urgentSurcharge;
  final double maxRadius;

  const LabTestVisitFee({
    required this.visitType,
    required this.homeVisitFee,
    required this.urgentSurcharge,
    required this.maxRadius,
  });

  @override
  List<Object?> get props => [
        visitType,
        homeVisitFee,
        urgentSurcharge,
        maxRadius,
      ];
}

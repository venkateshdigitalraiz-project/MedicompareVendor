import 'package:equatable/equatable.dart';

abstract class EditLeadEvent extends Equatable {
  const EditLeadEvent();

  @override
  List<Object?> get props => [];
}

class LoadLabTestDetailsEvent extends EditLeadEvent {
  final String productId;

  const LoadLabTestDetailsEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateLabTestDetailsEvent extends EditLeadEvent {
  final String productId;
  final Map<String, dynamic> data;

  const UpdateLabTestDetailsEvent(this.productId, this.data);

  @override
  List<Object?> get props => [productId, data];
}

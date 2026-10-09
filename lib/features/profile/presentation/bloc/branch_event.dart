import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class BranchEvent extends Equatable {
  const BranchEvent();

  @override
  List<Object?> get props => [];
}

class DeleteBranchEvent extends BranchEvent {
  final String branchId;

  const DeleteBranchEvent(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

class CreateBranchEvent extends BranchEvent {
  final Map<String, dynamic> data;
  final File? image;

  const CreateBranchEvent({
    required this.data,
    this.image,
  });

  @override
  List<Object?> get props => [data, image];
}

class UpdateBranchEvent extends BranchEvent {
  final String branchId;
  final Map<String, dynamic> data;
  final File? image;

  const UpdateBranchEvent({
    required this.branchId,
    required this.data,
    this.image,
  });

  @override
  List<Object?> get props => [branchId, data, image];
}

class FetchBranchListEvent extends BranchEvent {
  final String search;

  const FetchBranchListEvent({this.search = ''});

  @override
  List<Object?> get props => [search];
}

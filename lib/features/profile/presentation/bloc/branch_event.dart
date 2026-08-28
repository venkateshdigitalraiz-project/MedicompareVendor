import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class BranchEvent extends Equatable {
  const BranchEvent();

  @override
  List<Object?> get props => [];
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

class FetchBranchListEvent extends BranchEvent {
  final String search;

  const FetchBranchListEvent({this.search = ''});

  @override
  List<Object?> get props => [search];
}

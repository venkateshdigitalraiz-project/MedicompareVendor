import 'package:equatable/equatable.dart';
import '../../data/models/diagnostic_model.dart';

abstract class DiagnosticState extends Equatable {
  const DiagnosticState();
  @override
  List<Object?> get props => [];
}

class DiagnosticInitial extends DiagnosticState {}

class DiagnosticLoading extends DiagnosticState {}

class DiagnosticLoaded extends DiagnosticState {
  final List<DiagnosticCategory> categories;
  final DiagnosticResponse diagnosticResponse;
  final String selectedCategoryId;
  final String searchQuery;
  final bool isLoadingMore;

  const DiagnosticLoaded({
    required this.categories,
    required this.diagnosticResponse,
    this.selectedCategoryId = '',
    this.searchQuery = '',
    this.isLoadingMore = false,
  });

  DiagnosticLoaded copyWith({
    List<DiagnosticCategory>? categories,
    DiagnosticResponse? diagnosticResponse,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return DiagnosticLoaded(
      categories: categories ?? this.categories,
      diagnosticResponse: diagnosticResponse ?? this.diagnosticResponse,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [categories, diagnosticResponse, selectedCategoryId, searchQuery, isLoadingMore];
}

class DiagnosticError extends DiagnosticState {
  final String message;
  const DiagnosticError(this.message);
  @override
  List<Object?> get props => [message];
}

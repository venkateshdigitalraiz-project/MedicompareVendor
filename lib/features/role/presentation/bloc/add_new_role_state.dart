import 'package:equatable/equatable.dart';

class AddNewRoleState extends Equatable {
  final Map<String, Set<String>> permissions;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  const AddNewRoleState({
    required this.permissions,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  factory AddNewRoleState.initial() {
    return const AddNewRoleState(permissions: {});
  }

  AddNewRoleState copyWith({
    Map<String, Set<String>>? permissions,
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
  }) {
    return AddNewRoleState(
      permissions: permissions ?? this.permissions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  int get totalSelected {
    int count = 0;
    for (var set in permissions.values) {
      count += set.length;
    }
    return count;
  }

  @override
  List<Object?> get props => [permissions, isSubmitting, isSuccess, error];
}

import '../../../../core/error/failures.dart';
import '../entities/medical_category_entity.dart';
import '../repositories/role_repository.dart';

class GetMedicalCategoriesUseCase {
  final RoleRepository repository;

  GetMedicalCategoriesUseCase(this.repository);

  Future<Either<Failure, List<MedicalCategoryEntity>>> call() {
    return repository.getMedicalCategories();
  }
}

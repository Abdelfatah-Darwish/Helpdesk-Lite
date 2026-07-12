import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetAuthenticatedUserUseCase {
  final AuthRepository repository;

  GetAuthenticatedUserUseCase(this.repository);

  Future<UserEntity?> call() {
    return repository.getAuthenticatedUser();
  }
}

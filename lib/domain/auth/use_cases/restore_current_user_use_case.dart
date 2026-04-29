import 'package:milexact/domain/auth/entities/app_user.dart';
import 'package:milexact/domain/auth/repositories/auth_repository_contract.dart';

class RestoreCurrentUserUseCase {
  const RestoreCurrentUserUseCase(this._repository);

  final AuthRepositoryContract _repository;

  Future<AppUser?> call() => _repository.restoreCurrentUser();
}

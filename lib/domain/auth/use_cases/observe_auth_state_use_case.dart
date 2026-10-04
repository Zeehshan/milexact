import 'package:milexact/domain/auth/entities/app_user.dart';
import 'package:milexact/domain/auth/repositories/auth_repository_contract.dart';

class ObserveAuthStateUseCase {
  const ObserveAuthStateUseCase(this._repository);

  final AuthRepositoryContract _repository;

  Stream<AppUser?> call() => _repository.authStateChanges();
}

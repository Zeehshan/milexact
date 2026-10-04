import 'package:milexact/domain/auth/repositories/auth_repository_contract.dart';

class SendPasswordResetEmailUseCase {
  const SendPasswordResetEmailUseCase(this._repository);

  final AuthRepositoryContract _repository;

  Future<void> call({required String email}) {
    return _repository.sendPasswordResetEmail(email: email);
  }
}

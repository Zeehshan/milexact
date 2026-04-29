import 'package:milexact/domain/auth/repositories/auth_repository_contract.dart';

class SendEmailVerificationUseCase {
  const SendEmailVerificationUseCase(this._repository);

  final AuthRepositoryContract _repository;

  Future<void> call() => _repository.sendEmailVerification();
}

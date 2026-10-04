import 'package:milexact/domain/auth/entities/app_user.dart';
import 'package:milexact/domain/auth/repositories/auth_repository_contract.dart';

class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(this._repository);

  final AuthRepositoryContract _repository;

  Future<AppUser> call({required String email, required String password}) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}

/// Abstract base class for all use cases in the application.
///
/// Each use case encapsulates a single piece of business logic.
/// [Type] is the return type and [Params] is the input parameter type.
///
/// Usage:
/// ```dart
/// class GetUser extends UseCase<User, GetUserParams> {
///   final UserRepository repository;
///   GetUser(this.repository);
///
///   @override
///   Future<Type> call(GetUserParams params) async {
///     return await repository.getUser(params.id);
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Use this class when a use case does not require any parameters.
class NoParams {
  const NoParams();
}

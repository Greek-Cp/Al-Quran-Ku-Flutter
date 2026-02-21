/// Base class for all use cases.
///
/// [Type] is the return type of the use case.
/// [Params] is the input parameters type.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Use when the use case does not require any parameters.
class NoParams {
  const NoParams();
}

/// Resultado de uma operação que pode falhar.
///
/// Repositories devolvem `Result` em vez de lançar exceções, para que quem
/// chama seja obrigado a tratar os dois casos:
///
/// ```dart
/// switch (await repository.getLanguage()) {
///   case Ok(:final value):
///     // usar value
///   case Failure(:final error):
///     // tratar error
/// }
/// ```
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;

  const factory Result.failure(Exception error) = Failure<T>;
}

/// Operação concluída com sucesso, carregando [value].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

/// Operação que falhou com [error].
final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final Exception error;
}

/// Fonte da data e hora atuais.
///
/// Classes que dependem de "hoje" recebem um [Clock] em vez de chamar
/// `DateTime.now()`, para que os testes possam fixar a data.
class Clock {
  const Clock();

  DateTime now() => DateTime.now();
}

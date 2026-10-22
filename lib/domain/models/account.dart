/// Conta onde o dinheiro do usuário está (ex.: conta corrente, carteira).
///
/// Os totais e o saldo não ficam aqui, e sim em `AccountBalance`. Por ora o
/// usuário tem uma única conta, a principal.
class Account {
  const Account({required this.id, required this.name, this.isMain = false});

  final String id;

  /// Nome dado pelo usuário (ex.: "Conta principal").
  final String name;

  /// Conta usada por padrão em transações novas. Existe exatamente uma.
  final bool isMain;

  @override
  bool operator ==(Object other) =>
      other is Account &&
      other.id == id &&
      other.name == name &&
      other.isMain == isMain;

  @override
  int get hashCode => Object.hash(id, name, isMain);
}

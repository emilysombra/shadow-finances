import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/income_category.dart';
import 'package:shadow_finances/domain/models/totals_ledger.dart';
import 'package:shadow_finances/domain/models/transaction.dart';

/// Banco de dados fictício em memória, usado pelos Repositories `Static`
/// enquanto o app não salva dados de verdade.
///
/// Faz o papel do futuro banco (SQLite): guarda contas, transações e a
/// "tabela" de totais por conta. As datas são relativas a [today] (os
/// últimos meses), para que os filtros sempre mostrem algo e o saldo
/// acumulado de meses anteriores apareça.
///
/// Dados fictícios: descrições e nomes são dados do usuário, por isso não
/// são traduzidos.
class SampleDataService {
  SampleDataService({required DateTime today}) {
    DateTime monthsAgo(int months, int day) =>
        DateTime(today.year, today.month - months, day);
    DateTime daysAgo(int days) =>
        DateTime(today.year, today.month, today.day - days);

    var nextId = 0;
    void income(
      DateTime date,
      String description,
      int amountCents,
      IncomeCategory category,
    ) => _incomes.add(
      Income(
        id: 'i${++nextId}',
        description: description,
        amountCents: amountCents,
        date: date,
        accountId: mainAccount.id,
        category: category,
      ),
    );
    void expense(
      DateTime date,
      String description,
      int amountCents,
      ExpenseCategory category,
    ) => _expenses.add(
      Expense(
        id: 'e${++nextId}',
        description: description,
        amountCents: amountCents,
        date: date,
        accountId: mainAccount.id,
        category: category,
      ),
    );

    _incomes.add(
      Income.initialBalance(
        id: 'i${++nextId}',
        amountCents: 120000,
        date: monthsAgo(3, 1),
        accountId: mainAccount.id,
      ),
    );

    // Meses fechados, com despesas fixas.
    for (final months in [3, 2, 1]) {
      income(monthsAgo(months, 5), 'Salário', 650000, IncomeCategory.salary);
      expense(monthsAgo(months, 5), 'Aluguel', 180000, ExpenseCategory.housing);
      expense(
        monthsAgo(months, 12),
        'Conta de luz',
        21450,
        ExpenseCategory.housing,
      );
      expense(
        monthsAgo(months, 15),
        'Supermercado',
        75000,
        ExpenseCategory.food,
      );
    }
    // Um mês no vermelho, para o saldo negativo carregar para o seguinte.
    expense(
      monthsAgo(2, 20),
      'Conserto do carro',
      420000,
      ExpenseCategory.transport,
    );

    // Mês atual e dias recentes (alguns podem cair no mês anterior).
    income(monthsAgo(0, 1), 'Salário', 650000, IncomeCategory.salary);
    expense(daysAgo(1), 'Restaurante', 12750, ExpenseCategory.food);
    expense(
      daysAgo(3),
      'Corrida de aplicativo',
      3280,
      ExpenseCategory.transport,
    );
    expense(daysAgo(5), 'Farmácia', 8990, ExpenseCategory.health);
    expense(daysAgo(9), 'Cinema', 6400, ExpenseCategory.leisure);
    income(daysAgo(14), 'Projeto de site', 180000, IncomeCategory.freelance);
    income(daysAgo(20), 'Reembolso de passagem', 4590, IncomeCategory.refund);

    // A "tabela" de totais é montada uma vez, como uma migração de dados.
    // Depois disso, gravações aplicariam só a diferença (TotalsLedger.add).
    _ledgers[mainAccount.id] = TotalsLedger.of([..._incomes, ..._expenses]);
  }

  static const mainAccount = Account(
    id: 'main',
    name: 'Conta principal',
    isMain: true,
  );

  final _incomes = <Income>[];
  final _expenses = <Expense>[];
  final _ledgers = <String, TotalsLedger>{};

  List<Account> get accounts => const [mainAccount];

  List<Income> get incomes => List.unmodifiable(_incomes);

  List<Expense> get expenses => List.unmodifiable(_expenses);

  /// Totais guardados de cada conta, por id.
  Map<String, TotalsLedger> get ledgers => Map.unmodifiable(_ledgers);
}

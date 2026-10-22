import 'package:flutter/foundation.dart';

import 'package:shadow_finances/data/repositories/account/account_repository.dart';
import 'package:shadow_finances/data/repositories/expense/expense_repository.dart';
import 'package:shadow_finances/data/repositories/income/income_repository.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

/// Estado da tela inicial: resumo financeiro e lista de transações.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._accountRepository,
    required this._incomeRepository,
    required this._expenseRepository,
  });

  final AccountRepository _accountRepository;
  final IncomeRepository _incomeRepository;
  final ExpenseRepository _expenseRepository;

  FinancialSummary? _summary;
  List<Transaction> _transactions = const [];
  bool _hasError = false;

  /// Resumo carregado; `null` enquanto carrega ou se o carregamento falhou.
  FinancialSummary? get summary => _summary;

  /// Receitas e despesas juntas, das mais recentes para as mais antigas.
  List<Transaction> get transactions => _transactions;

  /// Se o último carregamento falhou.
  bool get hasError => _hasError;

  /// Carrega (ou recarrega) contas, receitas e despesas. Só exibe algo se as
  /// três chegarem, para nunca mostrar valores pela metade.
  ///
  /// O resumo soma apenas os totais já guardados de cada conta: as
  /// transações servem só para a lista, nunca são somadas aqui.
  Future<void> load() async {
    final (accounts, incomes, expenses) = await (
      _accountRepository.getAccountBalances(),
      _incomeRepository.getIncomes(),
      _expenseRepository.getExpenses(),
    ).wait;

    switch ((accounts, incomes, expenses)) {
      case (
        Ok(value: final accounts),
        Ok(value: final incomes),
        Ok(value: final expenses),
      ):
        _summary = FinancialSummary.sum(
          accounts.map((account) => account.totals),
        );
        _transactions = List.unmodifiable(
          <Transaction>[...incomes, ...expenses]
            ..sort((a, b) => b.date.compareTo(a.date)),
        );
        _hasError = false;
      default:
        _hasError = true;
    }
    notifyListeners();
  }
}

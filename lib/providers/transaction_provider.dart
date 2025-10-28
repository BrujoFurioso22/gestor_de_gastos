import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/hive_service.dart';
import 'account_provider.dart';
import 'app_config_provider.dart';

/// Provider para todas las transacciones
final transactionsProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
      return TransactionNotifier(ref);
    });

/// Provider para transacciones filtradas
final filteredTransactionsProvider =
    Provider.family<List<Transaction>, TransactionFilter>((ref, filter) {
      final transactions = ref.watch(transactionsProvider);
      return _filterTransactions(transactions, filter);
    });

/// Provider para estadísticas de transacciones
final transactionStatsProvider = Provider<TransactionStats>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final stats = _calculateStats(transactions);

  // Agregar el balance inicial de la cuenta actual
  final currentAccount = ref.watch(currentAccountProvider);
  final initialBalance = currentAccount?.initialBalance ?? 0.0;
  final adjustedBalance = stats.balance + initialBalance;

  return TransactionStats(
    totalIncome: stats.totalIncome,
    totalExpenses: stats.totalExpenses,
    balance: adjustedBalance,
    transactionCount: stats.transactionCount,
    categoryStats: stats.categoryStats,
  );
});

/// Provider para transacciones del mes actual
final currentMonthTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final now = DateTime.now();
  return transactions.where((transaction) {
    return transaction.date.year == now.year &&
        transaction.date.month == now.month;
  }).toList();
});

/// Provider para transacciones por tipo
final transactionsByTypeProvider =
    Provider.family<List<Transaction>, TransactionType>((ref, type) {
      final transactions = ref.watch(transactionsProvider);
      return transactions
          .where((transaction) => transaction.type == type)
          .toList();
    });

/// Provider para transacciones por categoría
final transactionsByCategoryProvider =
    Provider.family<List<Transaction>, String>((ref, categoryId) {
      final transactions = ref.watch(transactionsProvider);
      return transactions
          .where((transaction) => transaction.category == categoryId)
          .toList();
    });

/// Provider para búsqueda de transacciones
final searchTransactionsProvider = Provider.family<List<Transaction>, String>((
  ref,
  query,
) {
  final transactions = ref.watch(transactionsProvider);
  if (query.isEmpty) return transactions;

  final lowercaseQuery = query.toLowerCase();
  return transactions.where((transaction) {
    return (transaction.title?.toLowerCase().contains(lowercaseQuery) ??
            false) ||
        (transaction.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
  }).toList();
});

/// Notifier para manejar las transacciones
class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final Ref _ref;

  TransactionNotifier(this._ref) : super([]) {
    _loadTransactions();

    // Escuchar cambios en la configuración de la app para recargar transacciones
    _ref.listen(appConfigProvider, (previous, next) {
      if (previous?.currentAccountId != next.currentAccountId) {
        _loadTransactions();
      }
    });

    // Asignar accountId a transacciones existentes que no lo tengan
    Future.microtask(() => assignAccountIdToExistingTransactions());
  }

  /// Carga todas las transacciones desde Hive (filtradas por cuenta actual)
  void _loadTransactions() {
    final allTransactions = HiveService.getAllTransactions();
    final appConfig = _ref.read(appConfigProvider);
    final currentAccountId = appConfig.currentAccountId;


    // Si hay una cuenta actual, filtrar por ella
    if (currentAccountId != null) {
      state = allTransactions.where((transaction) {
        return transaction.accountId == currentAccountId;
      }).toList();
    } else {
      state = allTransactions;
    }

  }

  /// Agrega una nueva transacción
  Future<void> addTransaction(Transaction transaction) async {
    // Asignar la cuenta actual si no tiene
    final appConfig = _ref.read(appConfigProvider);
    final transactionWithAccount = transaction.copyWith(
      accountId: transaction.accountId ?? appConfig.currentAccountId,
    );

    await HiveService.addTransaction(transactionWithAccount);
    _loadTransactions();
  }

  /// Actualiza una transacción existente
  Future<void> updateTransaction(Transaction transaction) async {
    await HiveService.updateTransaction(transaction);
    _loadTransactions();
  }

  /// Elimina una transacción
  Future<void> deleteTransaction(String transactionId) async {
    await HiveService.deleteTransaction(transactionId);
    _loadTransactions();
  }

  /// Obtiene una transacción por ID
  Transaction? getTransaction(String transactionId) {
    return HiveService.getTransaction(transactionId);
  }

  /// Refresca la lista de transacciones
  void refresh() {
    _loadTransactions();
  }

  /// Asigna accountId a transacciones existentes que no lo tengan
  Future<void> assignAccountIdToExistingTransactions() async {
    final allTransactions = HiveService.getAllTransactions();
    final appConfig = _ref.read(appConfigProvider);
    final currentAccountId = appConfig.currentAccountId;

    if (currentAccountId == null) return;

    final transactionsToUpdate = <Transaction>[];

    for (final transaction in allTransactions) {
      if (transaction.accountId == null) {
        final updatedTransaction = transaction.copyWith(
          accountId: currentAccountId,
        );
        transactionsToUpdate.add(updatedTransaction);
      }
    }

    if (transactionsToUpdate.isNotEmpty) {
      
      for (final transaction in transactionsToUpdate) {
        await HiveService.updateTransaction(transaction);
      }
      _loadTransactions();
    }
  }
}

/// Filtro para transacciones
class TransactionFilter {
  final TransactionType? type;
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  const TransactionFilter({
    this.type,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  TransactionFilter copyWith({
    TransactionType? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return TransactionFilter(
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Estadísticas de transacciones
class TransactionStats {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int transactionCount;
  final Map<String, double> categoryStats;

  const TransactionStats({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.transactionCount,
    required this.categoryStats,
  });
}

/// Filtra transacciones según los criterios especificados
List<Transaction> _filterTransactions(
  List<Transaction> transactions,
  TransactionFilter filter,
) {
  final filtered = transactions.where((transaction) {
    // Filtro por tipo
    if (filter.type != null && transaction.type != filter.type) {
      return false;
    }

    // Filtro por categoría
    if (filter.categoryId != null &&
        transaction.category != filter.categoryId) {
      return false;
    }

    // Filtro por rango de fechas
    if (filter.startDate != null &&
        transaction.date.isBefore(filter.startDate!)) {
      return false;
    }
    if (filter.endDate != null && transaction.date.isAfter(filter.endDate!)) {
      return false;
    }

    // Filtro por búsqueda
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      if (!(transaction.title?.toLowerCase().contains(query) ?? false) &&
          !(transaction.notes?.toLowerCase().contains(query) ?? false)) {
        return false;
      }
    }

    return true;
  }).toList();

  // Ordenar por fecha (más recientes primero)
  filtered.sort((a, b) => b.date.compareTo(a.date));

  return filtered;
}

/// Calcula estadísticas de las transacciones
TransactionStats _calculateStats(List<Transaction> transactions) {
  double totalIncome = 0;
  double totalExpenses = 0;
  final Map<String, double> categoryStats = {};

  for (final transaction in transactions) {
    if (transaction.type == TransactionType.income) {
      totalIncome += transaction.amount;
    } else {
      totalExpenses += transaction.amount;
    }

    categoryStats[transaction.category] =
        (categoryStats[transaction.category] ?? 0) + transaction.amount;
  }

  return TransactionStats(
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    balance: totalIncome - totalExpenses,
    transactionCount: transactions.length,
    categoryStats: categoryStats,
  );
}

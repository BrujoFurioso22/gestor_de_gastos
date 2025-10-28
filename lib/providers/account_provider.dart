import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../services/hive_service.dart';
import 'app_config_provider.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, List<Account>>((
  ref,
) {
  return AccountNotifier();
});

final currentAccountProvider = Provider<Account?>((ref) {
  final accounts = ref.watch(accountProvider);
  if (accounts.isEmpty) return null;

  final appConfig = ref.watch(appConfigProvider);
  final currentAccountId = appConfig.currentAccountId;

  if (currentAccountId == null) return null;

  return accounts.firstWhere(
    (account) => account.id == currentAccountId,
    orElse: () => accounts.first,
  );
});

/// Provider para verificar el límite de cuentas
final accountLimitProvider = Provider.family<bool, bool>((ref, isPremium) {
  const int freeAccountLimit = 2;
  final accounts = ref.watch(accountProvider);

  // Si es premium, no hay límite
  if (isPremium) return false;

  // Si no es premium, verificar si alcanzó el límite
  return accounts.length >= freeAccountLimit;
});

class AccountNotifier extends StateNotifier<List<Account>> {
  AccountNotifier() : super([]) {
    _init();
  }

  void _init() {
    state = HiveService.getAllAccounts();
  }

  /// Verifica si puede agregar más cuentas
  bool canAddAccount(bool isPremium) {
    const int freeAccountLimit = 2;

    if (isPremium) return true;

    return state.length < freeAccountLimit;
  }

  Future<void> addAccount(String name, double initialBalance) async {
    final account = Account(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      initialBalance: initialBalance,
    );

    await HiveService.addAccount(account);
    state = HiveService.getAllAccounts();
  }

  Future<void> updateAccount(Account account) async {
    await HiveService.updateAccount(account);
    state = HiveService.getAllAccounts();
  }

  Future<void> deleteAccount(String accountId) async {
    await HiveService.deleteAccount(accountId);
    state = HiveService.getAllAccounts();
  }

  Future<void> setCurrentAccount(String accountId) async {
    final appConfig = HiveService.getAppConfig();
    final updatedConfig = appConfig.copyWith(currentAccountId: accountId);
    await HiveService.updateAppConfig(updatedConfig);
  }
}

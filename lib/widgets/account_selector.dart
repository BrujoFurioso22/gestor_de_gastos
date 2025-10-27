import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';
import '../providers/app_config_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/subscription_provider.dart';
import '../services/simple_localization.dart';

class AccountSelector extends ConsumerWidget {
  const AccountSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountProvider);
    final appConfig = ref.watch(appConfigProvider);

    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Obtener la cuenta actual
    final currentAccountId = appConfig.currentAccountId;
    final currentAccount = accounts.firstWhere(
      (account) => account.id == currentAccountId,
      orElse: () => accounts.first,
    );

    return Card(
      child: InkWell(
        onTap: () => _showAccountDialog(context, ref, accounts),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              HugeIcon(icon: HugeIconsStrokeRounded.money01, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SimpleLocalization.getText(ref, 'account'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentAccount.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountDialog(
    BuildContext context,
    WidgetRef ref,
    List<Account> accounts,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      SimpleLocalization.getText(ref, 'accounts'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddAccountDialog(context, ref),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    final isCurrent =
                        account.id ==
                        ref.read(appConfigProvider).currentAccountId;

                    return ListTile(
                      leading: Icon(
                        isCurrent
                            ? Icons.account_circle
                            : Icons.account_circle_outlined,
                        color: isCurrent
                            ? Theme.of(context).primaryColor
                            : null,
                        size: 32,
                      ),
                      title: Text(
                        account.name,
                        style: TextStyle(
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '\$ ${account.initialBalance.toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditAccountDialog(context, ref, account);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await ref
                                  .read(accountProvider.notifier)
                                  .deleteAccount(account.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      SimpleLocalization.getText(
                                        ref,
                                        'accountDeleted',
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () async {
                        if (!isCurrent) {
                          // Cambiar de cuenta
                          await ref
                              .read(appConfigProvider.notifier)
                              .updateCurrentAccountId(account.id);
                          // Recargar transacciones y suscripciones
                          ref.read(transactionsProvider.notifier).refresh();
                          ref.read(subscriptionsProvider.notifier).refresh();
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final accounts = ref.read(accountProvider);
    final isPremium = ref.read(isPremiumProvider);

    // Verificar límite de cuentas
    if (!isPremium && accounts.length >= 2) {
      // Mostrar diálogo informativo
      _showAccountLimitDialog(context, ref);
      return;
    }

    final nameController = TextEditingController();
    final balanceController = TextEditingController();

    // Cerrar el diálogo anterior
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                SimpleLocalization.getText(ref, 'newAccount'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: SimpleLocalization.getText(ref, 'accountName'),
                  hintText: 'Ej: Cuenta Principal',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: SimpleLocalization.getText(ref, 'initialBalance'),
                  hintText: 'Ej: 1000.00',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(SimpleLocalization.getText(ref, 'cancel')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text;
                      final balance =
                          double.tryParse(balanceController.text) ?? 0.0;

                      if (name.isNotEmpty) {
                        Navigator.pop(context);
                        await ref
                            .read(accountProvider.notifier)
                            .addAccount(name, balance);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                SimpleLocalization.getText(ref, 'accountAdded'),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(SimpleLocalization.getText(ref, 'add')),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditAccountDialog(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) {
    final balanceController = TextEditingController(
      text: account.initialBalance.toStringAsFixed(2),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${SimpleLocalization.getText(ref, 'editBalance')}: ${account.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                SimpleLocalization.getText(ref, 'balanceReferenceInfo'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: SimpleLocalization.getText(ref, 'initialBalance'),
                  hintText: 'Ej: 1500.00',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(SimpleLocalization.getText(ref, 'cancel')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final balance =
                          double.tryParse(balanceController.text) ?? 0.0;

                      await ref
                          .read(accountProvider.notifier)
                          .updateAccount(
                            account.copyWith(initialBalance: balance),
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              SimpleLocalization.getText(ref, 'balanceUpdated'),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(SimpleLocalization.getText(ref, 'update')),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountLimitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'maxAccountsReached')),
        content: Text(
          SimpleLocalization.getText(ref, 'freeAccountLimitMessage'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'close')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar este diálogo
              // Mostrar mensaje indicando que debe ir a configuración
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    SimpleLocalization.getText(ref, 'requiresPremium'),
                  ),
                  action: SnackBarAction(
                    label: SimpleLocalization.getText(ref, 'upgradeToPremium'),
                    onPressed: () {
                      // Este mensaje se cerrará automáticamente
                    },
                  ),
                ),
              );
            },
            child: Text(SimpleLocalization.getText(ref, 'upgradeToPremium')),
          ),
        ],
      ),
    );
  }
}

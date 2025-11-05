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
import '../utils/app_formatters.dart';
import '../services/feedback_service.dart';

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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => _showAccountDialog(context, ref, accounts),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: HugeIcon(
                icon: HugeIconsStrokeRounded.money01,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SimpleLocalization.getText(ref, 'account'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentAccount.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountDialog(
    BuildContext context,
    WidgetRef ref,
    List<Account> accounts,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.money01,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          SimpleLocalization.getText(ref, 'accounts'),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        FeedbackService.buttonFeedback(ref);
                        Navigator.pop(context);
                        _showAddAccountDialog(context, ref);
                      },
                    ),
                  ],
                ),
              ),
              // Lista de cuentas
              Flexible(
                child: accounts.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_circle_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay cuentas',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: accounts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          final isCurrent =
                              account.id ==
                              ref.read(appConfigProvider).currentAccountId;

                          return _buildAccountCard(
                            context,
                            ref,
                            account,
                            isCurrent,
                            theme,
                            isDark,
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

  Widget _buildAccountCard(
    BuildContext context,
    WidgetRef ref,
    Account account,
    bool isCurrent,
    ThemeData theme,
    bool isDark,
  ) {
    return InkWell(
      onTap: () async {
        FeedbackService.buttonFeedback(ref);
        if (!isCurrent) {
          await ref
              .read(appConfigProvider.notifier)
              .updateCurrentAccountId(account.id);
          ref.read(transactionsProvider.notifier).refresh();
          ref.read(subscriptionsProvider.notifier).refresh();
        }
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrent
              ? theme.colorScheme.primaryContainer.withOpacity(0.5)
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.1),
            width: isCurrent ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.none,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Nombre de la cuenta
                    Expanded(
                      child: Text(
                        account.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Botones de acción (más compactos)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () {
                            FeedbackService.buttonFeedback(ref);
                            Navigator.pop(context);
                            _showEditAccountDialog(context, ref, account);
                          },
                          tooltip: SimpleLocalization.getText(ref, 'edit'),
                          padding: const EdgeInsets.all(0),
                          constraints: const BoxConstraints(
                            minWidth: 25,
                            minHeight: 25,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          onPressed: () async {
                            FeedbackService.buttonFeedback(ref);
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  SimpleLocalization.getText(ref, 'delete'),
                                ),
                                content: Text(
                                  '¿${SimpleLocalization.getText(ref, 'delete')} la cuenta "${account.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      SimpleLocalization.getText(ref, 'cancel'),
                                    ),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error,
                                    ),
                                    child: Text(
                                      SimpleLocalization.getText(ref, 'delete'),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
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
                            }
                          },
                          tooltip: SimpleLocalization.getText(ref, 'delete'),
                          padding: const EdgeInsets.all(0),
                          constraints: const BoxConstraints(
                            minWidth: 25,
                            minHeight: 25,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Balance
                Text(
                  '${SimpleLocalization.getText(ref, 'initialBalance')}: ${AppFormatters.formatCurrency(account.initialBalance, ref)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            // Badge Activa con posición absoluta (abajo a la derecha)
            if (isCurrent)
              Positioned(
                bottom: -10,
                right: -13,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomRight: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
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

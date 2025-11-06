import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../models/recurring_payment.dart';
import '../models/transaction.dart';
import '../providers/recurring_payment_provider.dart';
import '../providers/app_config_provider.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import '../widgets/inputs/search_input_field.dart';
import '../widgets/inputs/custom_floating_action_button.dart';
import '../widgets/forms/recurring_payment_form.dart';
import '../widgets/cards/recurring_payment_card.dart';

class RecurringPaymentsScreen extends ConsumerStatefulWidget {
  const RecurringPaymentsScreen({super.key});

  @override
  ConsumerState<RecurringPaymentsScreen> createState() =>
      _RecurringPaymentsScreenState();
}

class _RecurringPaymentsScreenState
    extends ConsumerState<RecurringPaymentsScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allPayments = ref.watch(recurringPaymentsProvider);
    final expensePayments = ref.watch(
      recurringPaymentsByTypeProvider(TransactionType.expense),
    );
    final incomePayments = ref.watch(
      recurringPaymentsByTypeProvider(TransactionType.income),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          SimpleLocalization.getText(ref, 'recurringPayments'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: SimpleLocalization.getText(ref, 'all')),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(icon: HugeIconsStrokeRounded.dollar01, size: 16),
                  const SizedBox(width: 4),
                  Text(SimpleLocalization.getText(ref, 'expenses')),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(icon: HugeIconsStrokeRounded.money01, size: 16),
                  const SizedBox(width: 4),
                  Text(SimpleLocalization.getText(ref, 'income')),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: SearchInputField(
              controller: _searchController,
              hintText: SimpleLocalization.getText(
              ref,
              'searchRecurringPayments',
            ),
              onChanged: () {
                setState(() {});
              },
              onClear: () {
                setState(() {});
              },
            ),
          ),

          // Lista de pagos recurrentes
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPaymentsList(allPayments, 'all'),
                _buildPaymentsList(expensePayments, 'expenses'),
                _buildPaymentsList(incomePayments, 'income'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AddFloatingActionButton(
        onPressed: _showAddPaymentDialog,
      ),
    );
  }

  Widget _buildPaymentsList(
    List<RecurringPayment> payments,
    String type,
  ) {
    if (payments.isEmpty) {
      return _buildEmptyState(type);
    }

    // Filtrar por búsqueda si hay texto
    final filteredPayments = _searchController.text.isEmpty
        ? payments
        : payments.where((payment) {
            final query = _searchController.text.toLowerCase();
            return payment.name.toLowerCase().contains(query) ||
                (payment.description?.toLowerCase().contains(query) ?? false) ||
                (payment.notes?.toLowerCase().contains(query) ?? false);
          }).toList();

    return ListView.builder(
      padding: EdgeInsets.only(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
        bottom: AppConstants.defaultPadding +
            MediaQuery.of(context).padding.bottom,
      ),
      itemCount: filteredPayments.length,
      itemBuilder: (context, index) {
        final payment = filteredPayments[index];
        return RecurringPaymentCard(
          payment: payment,
          onTap: () => _showEditPaymentDialog(payment),
          onToggleStatus: () => _togglePaymentStatus(payment),
          onDelete: () => _showDeleteDialog(payment),
        );
      },
    );
  }


  Widget _buildEmptyState(String type) {
    final theme = Theme.of(context);
    String message;
    String subtitle;

    switch (type) {
      case 'expenses':
        message = SimpleLocalization.getText(ref, 'noRecurringExpenses');
        subtitle = SimpleLocalization.getText(ref, 'addFirstRecurringExpense');
        break;
      case 'income':
        message = SimpleLocalization.getText(ref, 'noRecurringIncome');
        subtitle = SimpleLocalization.getText(ref, 'addFirstRecurringIncome');
        break;
      default:
        message = SimpleLocalization.getText(ref, 'noRecurringPayments');
        subtitle = SimpleLocalization.getText(ref, 'addFirstRecurringPayment');
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIconsStrokeRounded.arrowUpDown,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      builder: (context) => const RecurringPaymentForm(isEdit: false),
    );
  }

  void _showEditPaymentDialog(RecurringPayment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      builder: (context) => RecurringPaymentForm(
        recurringPayment: payment,
        isEdit: true,
      ),
    );
  }

  void _togglePaymentStatus(RecurringPayment payment) {
    ref.read(recurringPaymentsProvider.notifier).togglePaymentStatus(payment.id);
  }

  void _showDeleteDialog(RecurringPayment payment) {
    final isEnglish = ref.read(appConfigProvider).language == 'en';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          SimpleLocalization.getText(ref, 'deleteRecurringPayment'),
        ),
        content: Text(
          SimpleLocalization.getTextByKey(
            'deleteRecurringPaymentConfirm',
            isEnglish,
          ).replaceAll('{name}', payment.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'cancel')),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(recurringPaymentsProvider.notifier)
                  .deleteRecurringPayment(payment.id);
              Navigator.pop(context);
            },
            child: Text(SimpleLocalization.getText(ref, 'delete')),
          ),
        ],
      ),
    );
  }
}


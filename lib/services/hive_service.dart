import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/app_settings.dart';
import '../models/subscription.dart';
import '../models/recurring_payment.dart';
import '../models/app_config.dart';
import '../models/account.dart';
import '../constants/app_constants.dart';

class HiveService {
  static late Box<Transaction> _transactionsBox;
  static late Box<Category> _categoriesBox;
  static late Box<AppSettings> _settingsBox;
  static late Box<Subscription> _subscriptionsBox;
  static late Box<RecurringPayment> _recurringPaymentsBox;
  static late Box<AppConfig> _appConfigBox;
  static late Box<Account> _accountsBox;

  /// Inicializa Hive y abre las cajas
  static Future<void> init() async {
    await Hive.initFlutter();

    // Registrar adaptadores
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(SubscriptionAdapter());
    Hive.registerAdapter(SubscriptionFrequencyAdapter());
    Hive.registerAdapter(RecurringPaymentAdapter());
    Hive.registerAdapter(RecurringFrequencyAdapter());
    Hive.registerAdapter(AppConfigAdapter());
    Hive.registerAdapter(CurrencyAdapter());
    Hive.registerAdapter(DateFormatAdapter());
    Hive.registerAdapter(DecimalSeparatorAdapter());
    Hive.registerAdapter(AppThemeAdapter());
    Hive.registerAdapter(FontSizeAdapter());
    Hive.registerAdapter(LanguageAdapter());
    Hive.registerAdapter(AccountAdapter());

    // Abrir cajas
    _transactionsBox = await Hive.openBox<Transaction>(
      AppConstants.transactionsBoxName,
    );
    _categoriesBox = await Hive.openBox<Category>(
      AppConstants.categoriesBoxName,
    );
    _settingsBox = await Hive.openBox<AppSettings>(
      AppConstants.settingsBoxName,
    );
    _subscriptionsBox = await Hive.openBox<Subscription>(
      AppConstants.subscriptionsBoxName,
    );
    _recurringPaymentsBox = await Hive.openBox<RecurringPayment>(
      AppConstants.recurringPaymentsBoxName,
    );
    _appConfigBox = await Hive.openBox<AppConfig>(
      AppConstants.appConfigBoxName,
    );
    _accountsBox = await Hive.openBox<Account>('accounts');

    // Inicializar datos por defecto si es necesario
    await _initializeDefaultData();
  }

  /// Inicializa datos por defecto
  static Future<void> _initializeDefaultData() async {
    // Inicializar categorías por defecto si no existen
    if (_categoriesBox.isEmpty) {
      final defaultCategories = DefaultCategories.allCategories;
      for (final category in defaultCategories) {
        await _categoriesBox.put(category.id, category);
      }
    } else {
      // Actualizar categorías existentes con nuevos iconos
      await _updateExistingCategories();
    }

    // Inicializar configuración por defecto si no existe
    if (_settingsBox.isEmpty) {
      final defaultSettings = AppSettings();
      await _settingsBox.put('default', defaultSettings);
    }

    // Inicializar cuenta por defecto si no hay cuentas
    if (_accountsBox.isEmpty) {
      final defaultAccount = Account(
        id: 'default',
        name: 'Cuenta Principal',
        initialBalance: 0.0,
      );
      await _accountsBox.put('default', defaultAccount);

      // Establecer como cuenta actual en AppConfig
      final appConfig = getAppConfig();
      final updatedConfig = appConfig.copyWith(currentAccountId: 'default');
      await updateAppConfig(updatedConfig);
    }
  }

  /// Actualiza las categorías existentes con los nuevos iconos
  static Future<void> _updateExistingCategories() async {
    final defaultCategories = DefaultCategories.allCategories;
    for (final defaultCategory in defaultCategories) {
      final existingCategory = _categoriesBox.get(defaultCategory.id);
      if (existingCategory != null) {
        // Actualizar solo si el icono es diferente
        if (existingCategory.icon != defaultCategory.icon) {
          final updatedCategory = existingCategory.copyWith(
            icon: defaultCategory.icon,
          );
          await _categoriesBox.put(defaultCategory.id, updatedCategory);
        }
      } else {
        // Agregar categoría si no existe
        await _categoriesBox.put(defaultCategory.id, defaultCategory);
      }
    }
  }

  /// Actualiza las traducciones de categorías por defecto cuando cambia el idioma
  static Future<void> updateCategoryTranslations(String language) async {

    for (final categoryId in DefaultCategories.defaultCategoryIds) {
      final existingCategory = _categoriesBox.get(categoryId);
      if (existingCategory != null) {
        final translatedName = DefaultCategories.getTranslatedName(
          categoryId,
          language,
        );

        if (existingCategory.name != translatedName) {
          final updatedCategory = existingCategory.copyWith(
            name: translatedName,
          );
          await _categoriesBox.put(categoryId, updatedCategory);
        }
      }
    }
  }

  /// Obtiene la caja de transacciones
  static Box<Transaction> get transactionsBox => _transactionsBox;

  /// Obtiene la caja de categorías
  static Box<Category> get categoriesBox => _categoriesBox;

  /// Obtiene la caja de configuración
  static Box<AppSettings> get settingsBox => _settingsBox;

  /// Obtiene la caja de suscripciones
  static Box<Subscription> get subscriptionsBox => _subscriptionsBox;
  static Box<AppConfig> get appConfigBox => _appConfigBox;

  /// Obtiene la caja de cuentas
  static Box<Account> get accountsBox => _accountsBox;

  /// Cierra todas las cajas
  static Future<void> close() async {
    await _transactionsBox.close();
    await _categoriesBox.close();
    await _settingsBox.close();
    await _subscriptionsBox.close();
    await _recurringPaymentsBox.close();
    await _appConfigBox.close();
    await _accountsBox.close();
  }

  /// Limpia todos los datos
  static Future<void> clearAllData() async {
    await _transactionsBox.clear();
    await _categoriesBox.clear();
    await _settingsBox.clear();
    await _subscriptionsBox.clear();
    await _recurringPaymentsBox.clear();
    await _appConfigBox.clear();
    await _accountsBox.clear();
    await _initializeDefaultData();
  }

  /// Fuerza la actualización de categorías con nuevos iconos
  static Future<void> updateCategoriesWithNewIcons() async {
    await _updateExistingCategories();
  }

  /// Restaura las categorías por defecto (elimina todas las categorías personalizadas)
  static Future<void> restoreDefaultCategories() async {
    // Limpiar todas las categorías existentes
    await _categoriesBox.clear();

    // Agregar las categorías por defecto
    final defaultCategories = DefaultCategories.allCategories;
    for (final category in defaultCategories) {
      await _categoriesBox.put(category.id, category);
    }
  }

  /// Obtiene todas las transacciones
  static List<Transaction> getAllTransactions() {
    return _transactionsBox.values.toList();
  }

  /// Obtiene todas las categorías
  static List<Category> getAllCategories() {
    return _categoriesBox.values.toList();
  }

  /// Obtiene las categorías por tipo
  static List<Category> getCategoriesByType(TransactionType type) {
    return _categoriesBox.values
        .where((category) => category.type == type)
        .toList();
  }

  /// Obtiene la configuración de la app
  static AppSettings getAppSettings() {
    return _settingsBox.get('default') ?? AppSettings();
  }

  /// Guarda la configuración de la app
  static Future<void> saveAppSettings(AppSettings settings) async {
    await _settingsBox.put('default', settings);
  }

  /// Agrega una transacción
  static Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  /// Actualiza una transacción
  static Future<void> updateTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  /// Elimina una transacción
  static Future<void> deleteTransaction(String transactionId) async {
    await _transactionsBox.delete(transactionId);
  }

  /// Obtiene una transacción por ID
  static Transaction? getTransaction(String transactionId) {
    return _transactionsBox.get(transactionId);
  }

  /// Obtiene transacciones por tipo
  static List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactionsBox.values
        .where((transaction) => transaction.type == type)
        .toList();
  }

  /// Obtiene transacciones por categoría
  static List<Transaction> getTransactionsByCategory(String categoryId) {
    return _transactionsBox.values
        .where((transaction) => transaction.category == categoryId)
        .toList();
  }

  /// Obtiene transacciones por rango de fechas
  static List<Transaction> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _transactionsBox.values
        .where(
          (transaction) =>
              transaction.date.isAfter(
                start.subtract(const Duration(days: 1)),
              ) &&
              transaction.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  /// Obtiene transacciones del mes actual
  static List<Transaction> getCurrentMonthTransactions() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getTransactionsByDateRange(startOfMonth, endOfMonth);
  }

  /// Obtiene el total de ingresos
  static double getTotalIncome() {
    return _transactionsBox.values
        .where((transaction) => transaction.type == TransactionType.income)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Obtiene el total de gastos
  static double getTotalExpenses() {
    return _transactionsBox.values
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Obtiene el balance total
  static double getTotalBalance() {
    return getTotalIncome() - getTotalExpenses();
  }

  /// Obtiene estadísticas por categoría
  static Map<String, double> getCategoryStats(TransactionType type) {
    final transactions = getTransactionsByType(type);
    final Map<String, double> stats = {};

    for (final transaction in transactions) {
      stats[transaction.category] =
          (stats[transaction.category] ?? 0) + transaction.amount;
    }

    return stats;
  }

  /// Busca transacciones por texto
  static List<Transaction> searchTransactions(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _transactionsBox.values
        .where(
          (transaction) =>
              (transaction.title?.toLowerCase().contains(lowercaseQuery) ??
                  false) ||
              (transaction.notes?.toLowerCase().contains(lowercaseQuery) ??
                  false),
        )
        .toList();
  }

  // ========== MÉTODOS DE SUSCRIPCIONES ==========

  /// Obtiene todas las suscripciones
  static List<Subscription> getAllSubscriptions() {
    return _subscriptionsBox.values.toList();
  }

  /// Agrega una suscripción
  static Future<void> addSubscription(Subscription subscription) async {
    await _subscriptionsBox.put(subscription.id, subscription);
  }

  /// Actualiza una suscripción
  static Future<void> updateSubscription(Subscription subscription) async {
    await _subscriptionsBox.put(subscription.id, subscription);
  }

  /// Elimina una suscripción
  static Future<void> deleteSubscription(String subscriptionId) async {
    await _subscriptionsBox.delete(subscriptionId);
  }

  /// Obtiene una suscripción por ID
  static Subscription? getSubscription(String subscriptionId) {
    return _subscriptionsBox.get(subscriptionId);
  }

  /// Obtiene suscripciones por frecuencia
  static List<Subscription> getSubscriptionsByFrequency(
    SubscriptionFrequency frequency,
  ) {
    return _subscriptionsBox.values
        .where((subscription) => subscription.frequency == frequency)
        .toList();
  }

  /// Obtiene suscripciones activas
  static List<Subscription> getActiveSubscriptions() {
    return _subscriptionsBox.values
        .where((subscription) => subscription.isActive)
        .toList();
  }

  /// Obtiene suscripciones inactivas
  static List<Subscription> getInactiveSubscriptions() {
    return _subscriptionsBox.values
        .where((subscription) => !subscription.isActive)
        .toList();
  }

  /// Obtiene suscripciones próximas a vencer
  static List<Subscription> getDueSoonSubscriptions() {
    return _subscriptionsBox.values
        .where(
          (subscription) => subscription.isActive && subscription.isDueSoon,
        )
        .toList();
  }

  /// Obtiene suscripciones vencidas
  static List<Subscription> getOverdueSubscriptions() {
    return _subscriptionsBox.values
        .where(
          (subscription) => subscription.isActive && subscription.isOverdue,
        )
        .toList();
  }

  /// Busca suscripciones por texto
  static List<Subscription> searchSubscriptions(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _subscriptionsBox.values
        .where(
          (subscription) =>
              subscription.name.toLowerCase().contains(lowercaseQuery) ||
              subscription.description.toLowerCase().contains(lowercaseQuery) ||
              (subscription.notes?.toLowerCase().contains(lowercaseQuery) ??
                  false),
        )
        .toList();
  }

  /// Obtiene el costo total mensual de todas las suscripciones activas
  static double getTotalMonthlySubscriptionCost() {
    return _subscriptionsBox.values
        .where((subscription) => subscription.isActive)
        .fold(0.0, (sum, subscription) => sum + subscription.monthlyCost);
  }

  /// Obtiene el costo total anual de todas las suscripciones activas
  static double getTotalYearlySubscriptionCost() {
    return _subscriptionsBox.values
        .where((subscription) => subscription.isActive)
        .fold(0.0, (sum, subscription) => sum + subscription.yearlyCost);
  }

  // ==================== MÉTODOS DE PAGOS RECURRENTES ====================

  /// Obtiene todos los pagos recurrentes
  static List<RecurringPayment> getAllRecurringPayments() {
    return _recurringPaymentsBox.values.toList();
  }

  /// Agrega un pago recurrente
  static Future<void> addRecurringPayment(
    RecurringPayment recurringPayment,
  ) async {
    await _recurringPaymentsBox.put(recurringPayment.id, recurringPayment);
  }

  /// Actualiza un pago recurrente
  static Future<void> updateRecurringPayment(
    RecurringPayment recurringPayment,
  ) async {
    await _recurringPaymentsBox.put(recurringPayment.id, recurringPayment);
  }

  /// Elimina un pago recurrente
  static Future<void> deleteRecurringPayment(String recurringPaymentId) async {
    await _recurringPaymentsBox.delete(recurringPaymentId);
  }

  /// Obtiene un pago recurrente por ID
  static RecurringPayment? getRecurringPayment(String recurringPaymentId) {
    return _recurringPaymentsBox.get(recurringPaymentId);
  }

  /// Obtiene pagos recurrentes activos
  static List<RecurringPayment> getActiveRecurringPayments() {
    return _recurringPaymentsBox.values
        .where((payment) => payment.isActive)
        .toList();
  }

  /// Obtiene pagos recurrentes inactivos
  static List<RecurringPayment> getInactiveRecurringPayments() {
    return _recurringPaymentsBox.values
        .where((payment) => !payment.isActive)
        .toList();
  }

  /// Obtiene pagos recurrentes por tipo
  static List<RecurringPayment> getRecurringPaymentsByType(
    TransactionType type,
  ) {
    return _recurringPaymentsBox.values
        .where((payment) => payment.type == type)
        .toList();
  }

  /// Obtiene pagos recurrentes próximos a vencer
  static List<RecurringPayment> getDueSoonRecurringPayments() {
    return _recurringPaymentsBox.values
        .where(
          (payment) => payment.isActive && payment.isDueSoon,
        )
        .toList();
  }

  /// Obtiene pagos recurrentes vencidos
  static List<RecurringPayment> getOverdueRecurringPayments() {
    return _recurringPaymentsBox.values
        .where(
          (payment) => payment.isActive && payment.isOverdue,
        )
        .toList();
  }

  /// Busca pagos recurrentes por texto
  static List<RecurringPayment> searchRecurringPayments(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _recurringPaymentsBox.values
        .where(
          (payment) =>
              payment.name.toLowerCase().contains(lowercaseQuery) ||
              (payment.description?.toLowerCase().contains(lowercaseQuery) ??
                  false) ||
              (payment.notes?.toLowerCase().contains(lowercaseQuery) ?? false),
        )
        .toList();
  }

  // ==================== MÉTODOS DE CONFIGURACIÓN DE APP ====================

  /// Obtiene la configuración de la app
  static AppConfig getAppConfig() {
    final configs = _appConfigBox.values.toList();
    if (configs.isEmpty) {
      // Crear configuración por defecto si no existe
      final defaultConfig = AppConfig();
      _appConfigBox.put('default', defaultConfig);
      return defaultConfig;
    }
    return configs.first;
  }

  /// Actualiza la configuración de la app
  static Future<void> updateAppConfig(AppConfig config) async {
    await _appConfigBox.put('default', config);
  }

  /// Obtiene la configuración de moneda
  static String getCurrency() {
    return getAppConfig().currency;
  }

  /// Obtiene el formato de fecha
  static String getDateFormat() {
    return getAppConfig().dateFormat;
  }

  /// Obtiene el separador decimal
  static String getDecimalSeparator() {
    return getAppConfig().decimalSeparator;
  }

  /// Verifica si debe mostrar centavos
  static bool shouldShowCents() {
    return getAppConfig().showCents;
  }

  /// Obtiene el tema de la app
  static String getTheme() {
    return getAppConfig().theme;
  }

  /// Obtiene el tamaño de fuente
  static String getFontSize() {
    return getAppConfig().fontSize;
  }

  /// Obtiene el idioma
  static String getLanguage() {
    return getAppConfig().language;
  }

  /// Verifica si la vibración está habilitada
  static bool isVibrationEnabled() {
    return getAppConfig().vibration;
  }

  /// Verifica si el sonido está habilitado
  static bool isSoundEnabled() {
    return getAppConfig().sound;
  }

  // ========== MÉTODOS DE CUENTAS ==========

  /// Obtiene todas las cuentas
  static List<Account> getAllAccounts() {
    return _accountsBox.values.toList();
  }

  /// Agrega una cuenta
  static Future<void> addAccount(Account account) async {
    await _accountsBox.put(account.id, account);
  }

  /// Actualiza una cuenta
  static Future<void> updateAccount(Account account) async {
    await _accountsBox.put(account.id, account);
  }

  /// Elimina una cuenta
  static Future<void> deleteAccount(String accountId) async {
    await _accountsBox.delete(accountId);
  }

  /// Obtiene una cuenta por ID
  static Account? getAccount(String accountId) {
    return _accountsBox.get(accountId);
  }

  /// Obtiene la cuenta actual
  static Account? getCurrentAccount() {
    final appConfig = getAppConfig();
    if (appConfig.currentAccountId == null) {
      return null;
    }
    return getAccount(appConfig.currentAccountId!);
  }
}

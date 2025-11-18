import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_config_provider.dart';

class SimpleLocalization {
  static String getText(WidgetRef ref, String key) {
    final appConfig = ref.read(appConfigProvider);
    final isEnglish = appConfig.language == 'en';

    return getTextByKey(key, isEnglish);
  }

  static String getTextByKey(String key, bool isEnglish) {
    final translation = _translations[key];
    if (translation == null) return key;

    return isEnglish
        ? (translation['eng'] ?? key)
        : (translation['esp'] ?? key);
  }

  static const Map<String, Map<String, String>> _translations = {
    'before': {'esp': 'antes', 'eng': 'before'},
    'appTitle': {'esp': 'CuidaTuPlata', 'eng': 'CuidaTuPlata'},
    'dashboard': {'esp': 'Inicio', 'eng': 'Dashboard'},
    'history': {'esp': 'Historial', 'eng': 'History'},
    'subscriptions': {'esp': 'Suscripciones', 'eng': 'Subscriptions'},
    'settings': {'esp': 'Configuración', 'eng': 'Settings'},
    'add': {'esp': 'Agregar', 'eng': 'Add'},
    'addTransaction': {'esp': 'Agregar Transacción', 'eng': 'Add Transaction'},
    'addSubscription': {
      'esp': 'Agregar Suscripción',
      'eng': 'Add Subscription',
    },
    'editTransaction': {'esp': 'Editar Transacción', 'eng': 'Edit Transaction'},
    'editSubscription': {
      'esp': 'Editar Suscripción',
      'eng': 'Edit Subscription',
    },
    'delete': {'esp': 'Eliminar', 'eng': 'Delete'},
    'cancel': {'esp': 'Cancelar', 'eng': 'Cancel'},
    'save': {'esp': 'Guardar', 'eng': 'Save'},
    'search': {'esp': 'Buscar', 'eng': 'Search'},
    'filter': {'esp': 'Filtrar', 'eng': 'Filter'},
    'refresh': {'esp': 'Actualizar', 'eng': 'Refresh'},
    'totalBalance': {'esp': 'Balance Total', 'eng': 'Total Balance'},
    'income': {'esp': 'Ingresos', 'eng': 'Income'},
    'expenses': {'esp': 'Gastos', 'eng': 'Expenses'},
    'recentTransactions': {
      'esp': 'Transacciones Recientes',
      'eng': 'Recent Transactions',
    },
    'noTransactions': {'esp': 'No hay transacciones', 'eng': 'No transactions'},
    'addFirstTransaction': {
      'esp': 'Agrega tu primera transacción',
      'eng': 'Add your first transaction',
    },
    'transactionTitle': {'esp': 'Título', 'eng': 'Title'},
    'transactionAmount': {'esp': 'Monto', 'eng': 'Amount'},
    'transactionDate': {'esp': 'Fecha', 'eng': 'Date'},
    'transactionCategory': {'esp': 'Categoría', 'eng': 'Category'},
    'transactionNotes': {'esp': 'Notas', 'eng': 'Notes'},
    'transactionType': {
      'esp': 'Tipo de transacción',
      'eng': 'Transaction type',
    },
    'incomeType': {'esp': 'Ingreso', 'eng': 'Income'},
    'expenseType': {'esp': 'Gasto', 'eng': 'Expense'},
    'subscriptionName': {'esp': 'Nombre', 'eng': 'Name'},
    'subscriptionDescription': {'esp': 'Descripción', 'eng': 'Description'},
    'subscriptionAmount': {'esp': 'Costo', 'eng': 'Cost'},
    'subscriptionFrequency': {'esp': 'Frecuencia', 'eng': 'Frequency'},
    'subscriptionNextPayment': {'esp': 'Próximo pago', 'eng': 'Next payment'},
    'subscriptionActive': {'esp': 'Activa', 'eng': 'Active'},
    'subscriptionInactive': {'esp': 'Inactiva', 'eng': 'Inactive'},
    'subscriptionOverdue': {'esp': 'Pago vencido', 'eng': 'Payment overdue'},
    'monthly': {'esp': 'Mensual', 'eng': 'Monthly'},
    'yearly': {'esp': 'Anual', 'eng': 'Yearly'},
    'weekly': {'esp': 'Semanal', 'eng': 'Weekly'},
    'daily': {'esp': 'Diario', 'eng': 'Daily'},
    'settingsFinancial': {
      'esp': 'Configuración Financiera',
      'eng': 'Financial Configuration',
    },
    'settingsVisual': {
      'esp': 'Configuración Visual',
      'eng': 'Visual Configuration',
    },
    'settingsPrivacy': {'esp': 'Privacidad', 'eng': 'Privacy'},
    'settingsApp': {'esp': 'Configuración de App', 'eng': 'App Configuration'},
    'settingsNotifications': {'esp': 'Notificaciones', 'eng': 'Notifications'},
    'settingsAccount': {'esp': 'Cuenta', 'eng': 'Account'},
    'currency': {'esp': 'Moneda', 'eng': 'Currency'},
    'dateFormat': {'esp': 'Formato de Fecha', 'eng': 'Date Format'},
    'decimalSeparator': {
      'esp': 'Separador Decimal',
      'eng': 'Decimal Separator',
    },
    'showCents': {'esp': 'Mostrar Centavos', 'eng': 'Show Cents'},
    'darkMode': {'esp': 'Modo Oscuro', 'eng': 'Dark Mode'},
    'fontSize': {'esp': 'Tamaño de Fuente', 'eng': 'Font Size'},
    'language': {'esp': 'Idioma', 'eng': 'Language'},
    'vibration': {'esp': 'Vibración', 'eng': 'Vibration'},
    'sound': {'esp': 'Sonido', 'eng': 'Sound'},
    'deleteAllData': {
      'esp': 'Eliminar Todos los Datos',
      'eng': 'Delete All Data',
    },
    'exportData': {'esp': 'Exportar Datos', 'eng': 'Export Data'},
    'exportTransactions': {
      'esp': 'Exportar Transacciones',
      'eng': 'Export Transactions',
    },
    'exportTransactionsDescription': {
      'esp': 'Exporta tus transacciones a Excel o CSV',
      'eng': 'Export your transactions to Excel or CSV',
    },
    'subscriptionReminders': {
      'esp': 'Recordatorio de Suscripciones',
      'eng': 'Subscription Reminders',
    },
    'expenseNotifications': {
      'esp': 'Notificaciones de Gastos',
      'eng': 'Expense Notifications',
    },
    'weeklySummary': {'esp': 'Resumen Semanal', 'eng': 'Weekly Summary'},
    'premiumVersion': {'esp': 'Versión Premium', 'eng': 'Premium Version'},
    'ads': {'esp': 'Anuncios', 'eng': 'Ads'},
    'restoreSettings': {
      'esp': 'Restaurar Configuración',
      'eng': 'Restore Settings',
    },
    'smallFont': {'esp': 'Pequeño', 'eng': 'Small'},
    'normalFont': {'esp': 'Normal', 'eng': 'Normal'},
    'largeFont': {'esp': 'Grande', 'eng': 'Large'},
    'pointSeparator': {'esp': 'Punto (.)', 'eng': 'Point (.)'},
    'commaSeparator': {'esp': 'Coma (,)', 'eng': 'Comma (,)'},
    'daysBefore': {'esp': 'días antes', 'eng': 'days before'},
    'today': {'esp': 'Hoy', 'eng': 'Today'},
    'tomorrow': {'esp': 'Mañana', 'eng': 'Tomorrow'},
    'overdue': {'esp': 'Vencido', 'eng': 'Overdue'},
    'days': {'esp': 'días', 'eng': 'days'},
    'cost': {'esp': 'Costo', 'eng': 'Cost'},
    'nextPayment': {'esp': 'Próximo pago', 'eng': 'Next payment'},
    'pause': {'esp': 'Pausar', 'eng': 'Pause'},
    'resume': {'esp': 'Reanudar', 'eng': 'Resume'},
    'markAsPaid': {'esp': 'Marcar como pagada', 'eng': 'Mark as paid'},
    'monthlyCost': {'esp': 'Costo Mensual', 'eng': 'Monthly Cost'},
    'yearlyCost': {'esp': 'Costo Anual', 'eng': 'Yearly Cost'},
    'distributionOfExpenses': {
      'esp': 'Distribución de Gastos',
      'eng': 'Distribution of Expenses',
    },
    'noDataToShow': {
      'esp': 'No hay datos para mostrar',
      'eng': 'No data to show',
    },
    'searchTransactions': {
      'esp': 'Buscar transacciones...',
      'eng': 'Search transactions...',
    },
    'filterTransactions': {
      'esp': 'Filtrar Transacciones',
      'eng': 'Filter Transactions',
    },
    'allTransactions': {'esp': 'Todas', 'eng': 'All'},
    'initializingSettings': {
      'esp': 'Inicializando configuración...',
      'eng': 'Initializing settings...',
    },
    'errorOccurred': {'esp': 'Ocurrió un error', 'eng': 'An error occurred'},
    'retry': {'esp': 'Reintentar', 'eng': 'Retry'},
    'deleteDataConfirm': {
      'esp': '¿Estás seguro de que quieres eliminar todos los datos?',
      'eng': 'Are you sure you want to delete all data?',
    },
    'deleteDataWarning': {
      'esp': 'Esta acción no se puede deshacer',
      'eng': 'This action cannot be undone',
    },
    'restoreSettingsConfirm': {
      'esp': '¿Restaurar la configuración a valores por defecto?',
      'eng': 'Restore settings to default values?',
    },
    'yes': {'esp': 'Sí', 'eng': 'Yes'},
    'no': {'esp': 'No', 'eng': 'No'},
    'active': {'esp': 'Activa', 'eng': 'Active'},
    'inactive': {'esp': 'Inactiva', 'eng': 'Inactive'},
    'spanish': {'esp': 'Español', 'eng': 'Español'},
    'english': {'esp': 'English', 'eng': 'English'},
    'dollars': {'esp': 'Dólar Americano', 'eng': 'US Dollar'},
    'euros': {'esp': 'Euro', 'eng': 'Euro'},
    'pesos': {'esp': 'Peso Mexicano', 'eng': 'Mexican Peso'},
    'pounds': {'esp': 'Libra Esterlina', 'eng': 'British Pound'},
    'canadianDollars': {'esp': 'Dólar Canadiense', 'eng': 'Canadian Dollar'},
    'australianDollars': {
      'esp': 'Dólar Australiano',
      'eng': 'Australian Dollar',
    },
    'ddmmyyyy': {'esp': 'DD/MM/YYYY', 'eng': 'DD/MM/YYYY'},
    'mmddyyyy': {'esp': 'MM/DD/YYYY', 'eng': 'MM/DD/YYYY'},
    'yyyymmdd': {'esp': 'YYYY-MM-DD', 'eng': 'YYYY-MM-DD'},
    'deleteAllDataConfirm': {
      'esp': '¿Eliminar todos los datos?',
      'eng': 'Delete all data?',
    },
    'exportDataConfirm': {'esp': '¿Exportar datos?', 'eng': 'Export data?'},
    'premiumActive': {'esp': 'Activa', 'eng': 'Active'},
    'premiumInactive': {'esp': 'Inactiva', 'eng': 'Inactive'},
    'viewAll': {'esp': 'Ver todas', 'eng': 'View all'},
    'noRecentTransactions': {
      'esp': 'No hay transacciones recientes',
      'eng': 'No recent transactions',
    },
    'clear': {'esp': 'Limpiar', 'eng': 'Clear'},
    'apply': {'esp': 'Aplicar', 'eng': 'Apply'},
    'deleteTransaction': {
      'esp': 'Eliminar Transacción',
      'eng': 'Delete Transaction',
    },
    'all': {'esp': 'Todas', 'eng': 'All'},
    'searchSubscriptions': {
      'esp': 'Buscar suscripciones...',
      'eng': 'Search subscriptions...',
    },
    'noActiveSubscriptions': {
      'esp': 'No hay suscripciones activas',
      'eng': 'No active subscriptions',
    },
    'addFirstActiveSubscription': {
      'esp': 'Agrega tu primera suscripción activa',
      'eng': 'Add your first active subscription',
    },
    'noInactiveSubscriptions': {
      'esp': 'No hay suscripciones inactivas',
      'eng': 'No inactive subscriptions',
    },
    'pausedSubscriptionsAppearHere': {
      'esp': 'Las suscripciones pausadas aparecerán aquí',
      'eng': 'Paused subscriptions will appear here',
    },
    'noSubscriptions': {
      'esp': 'No hay suscripciones',
      'eng': 'No subscriptions',
    },
    'addFirstSubscription': {
      'esp': 'Agrega tu primera suscripción',
      'eng': 'Add your first subscription',
    },
    'markedAsPaid': {'esp': 'marcada como pagada', 'eng': 'marked as paid'},
    'undo': {'esp': 'Deshacer', 'eng': 'Undo'},
    'deleteSubscription': {
      'esp': 'Eliminar Suscripción',
      'eng': 'Delete Subscription',
    },
    'deleteSubscriptionConfirm': {
      'esp': '¿Estás seguro de que quieres eliminar "{name}"?',
      'eng': 'Are you sure you want to delete "{name}"?',
    },
    'filterSubscriptions': {
      'esp': 'Filtrar Suscripciones',
      'eng': 'Filter Subscriptions',
    },
    'paymentFrequency': {
      'esp': 'Frecuencia de pago',
      'eng': 'Payment frequency',
    },
    'quarterly': {'esp': 'Trimestral', 'eng': 'Quarterly'},
    'initializingConfig': {
      'esp': 'Inicializando configuración...',
      'eng': 'Initializing configuration...',
    },
    'error': {'esp': 'Error:', 'eng': 'Error:'},
    'deleteTransactionsAndSubscriptions': {
      'esp': 'Borrar transacciones y suscripciones',
      'eng': 'Delete transactions and subscriptions',
    },
    'downloadPdfOrExcel': {
      'esp': 'Descargar en PDF o Excel',
      'eng': 'Download in PDF or Excel',
    },
    'requiresPremium': {'esp': 'Requiere Premium', 'eng': 'Requires Premium'},
    'selectCurrency': {'esp': 'Seleccionar Moneda', 'eng': 'Select Currency'},
    'functionInDevelopment': {
      'esp': 'Función en desarrollo',
      'eng': 'Function in development',
    },
    'selectExportFormat': {
      'esp': 'Selecciona el formato de exportación:',
      'eng': 'Select export format:',
    },
    'exportingToPdf': {
      'esp': 'Exportando a PDF...',
      'eng': 'Exporting to PDF...',
    },
    'exportingToExcel': {
      'esp': 'Exportando a Excel...',
      'eng': 'Exporting to Excel...',
    },
    'exportingToCsv': {
      'esp': 'Exportando a CSV...',
      'eng': 'Exporting to CSV...',
    },
    'exportCompleted': {
      'esp': 'Exportación completada',
      'eng': 'Export completed',
    },
    'fileOpened': {'esp': 'Archivo abierto', 'eng': 'File opened'},
    'exportError': {'esp': 'Error al exportar', 'eng': 'Export error'},
    'shareFile': {'esp': 'Compartir archivo', 'eng': 'Share file'},
    'shareError': {'esp': 'Error al compartir', 'eng': 'Share error'},
    'unlockPremiumFeatures': {
      'esp': 'Desbloquea todas las funciones premium:',
      'eng': 'Unlock all premium features:',
    },
    'noAds': {'esp': 'Sin anuncios', 'eng': 'No ads'},
    'advancedExport': {'esp': 'Exportación avanzada', 'eng': 'Advanced export'},
    'customThemes': {'esp': 'Temas personalizados', 'eng': 'Custom themes'},
    'cloudBackup': {'esp': 'Backup en la nube', 'eng': 'Cloud backup'},
    'prioritySupport': {
      'esp': 'Soporte prioritario',
      'eng': 'Priority support',
    },
    'close': {'esp': 'Cerrar', 'eng': 'Close'},
    'ok': {'esp': 'Aceptar', 'eng': 'OK'},
    'upgrade': {'esp': 'Actualizar', 'eng': 'Upgrade'},
    'settingsRestored': {
      'esp': 'Configuración restaurada',
      'eng': 'Settings restored',
    },
    'restore': {'esp': 'Restaurar', 'eng': 'Restore'},
    'day': {'esp': 'Día', 'eng': 'Day'},
    'titleRequired': {
      'esp': 'El título es obligatorio',
      'eng': 'Title is required',
    },
    'amountRequired': {
      'esp': 'El monto es obligatorio',
      'eng': 'Amount is required',
    },
    'enterValidAmount': {
      'esp': 'Ingresa un monto válido',
      'eng': 'Enter a valid amount',
    },
    'categoryRequired': {
      'esp': 'La categoría es obligatoria',
      'eng': 'Category is required',
    },
    'transactionSaved': {
      'esp': 'Transacción guardada correctamente',
      'eng': 'Transaction saved successfully',
    },
    'errorSaving': {'esp': 'Error al guardar:', 'eng': 'Error saving:'},
    'selectCategory': {
      'esp': 'Selecciona una categoría',
      'eng': 'Select a category',
    },
    'notesOptional': {'esp': 'Notas (opcional)', 'eng': 'Notes (optional)'},
    'additionalInfo': {
      'esp': 'Información adicional...',
      'eng': 'Additional information...',
    },
    'exampleSupermarket': {
      'esp': 'Ej: Compra de supermercado',
      'eng': 'Ex: Supermarket purchase',
    },
    'manageCategories': {
      'esp': 'Gestionar Categorías',
      'eng': 'Manage Categories',
    },
    'addCategory': {'esp': 'Agregar Categoría', 'eng': 'Add Category'},
    'editCategory': {'esp': 'Editar Categoría', 'eng': 'Edit Category'},
    'deleteCategory': {'esp': 'Eliminar Categoría', 'eng': 'Delete Category'},
    'categoryName': {'esp': 'Nombre de la categoría', 'eng': 'Category name'},
    'selectIcon': {'esp': 'Seleccionar icono', 'eng': 'Select icon'},
    'selectColor': {'esp': 'Seleccionar color', 'eng': 'Select color'},
    'select': {'esp': 'Seleccionar', 'eng': 'Select'},
    'categoryType': {'esp': 'Tipo de categoría', 'eng': 'Category type'},
    'expense': {'esp': 'Gasto', 'eng': 'Expense'},
    'categoryCreated': {
      'esp': 'Categoría creada correctamente',
      'eng': 'Category created successfully',
    },
    'categoryUpdated': {
      'esp': 'Categoría actualizada correctamente',
      'eng': 'Category updated successfully',
    },
    'categoryDeleted': {
      'esp': 'Categoría eliminada correctamente',
      'eng': 'Category deleted successfully',
    },
    'deleteCategoryConfirm': {
      'esp': '¿Estás seguro de que quieres eliminar esta categoría?',
      'eng': 'Are you sure you want to delete this category?',
    },
    'categoryNameRequired': {
      'esp': 'El nombre de la categoría es obligatorio',
      'eng': 'Category name is required',
    },
    'selectCategoryType': {
      'esp': 'Selecciona el tipo de categoría',
      'eng': 'Select category type',
    },
    'noCategories': {'esp': 'No hay categorías', 'eng': 'No categories'},
    'addFirstCategory': {
      'esp': 'Agrega tu primera categoría',
      'eng': 'Add your first category',
    },
    'category': {'esp': 'Categoría', 'eng': 'Category'},
    'manageSubscriptions': {
      'esp': 'Gestionar Suscripciones',
      'eng': 'Manage Subscriptions',
    },
    'date': {'esp': 'Fecha', 'eng': 'Date'},
    'startDate': {'esp': 'Fecha de inicio', 'eng': 'Start date'},
    'endDate': {'esp': 'Fecha de fin (opcional)', 'eng': 'End date (optional)'},
    'subscriptionNotes': {'esp': 'Notas (opcional)', 'eng': 'Notes (optional)'},
    'subscriptionCreated': {
      'esp': 'Suscripción creada correctamente',
      'eng': 'Subscription created successfully',
    },
    'subscriptionUpdated': {
      'esp': 'Suscripción actualizada correctamente',
      'eng': 'Subscription updated successfully',
    },
    'subscriptionDeleted': {
      'esp': 'Suscripción eliminada correctamente',
      'eng': 'Subscription deleted successfully',
    },
    'subscriptionNameRequired': {
      'esp': 'El nombre de la suscripción es obligatorio',
      'eng': 'Subscription name is required',
    },
    'subscriptionAmountRequired': {
      'esp': 'El monto es obligatorio',
      'eng': 'Amount is required',
    },
    'selectFrequency': {
      'esp': 'Selecciona la frecuencia',
      'eng': 'Select frequency',
    },
    'noSubscriptionsFound': {
      'esp': 'No se encontraron suscripciones',
      'eng': 'No subscriptions found',
    },
    // Hint texts for forms
    'titleHint': {
      'esp': 'Ej: Comida, Transporte, Salario...',
      'eng': 'Ex: Food, Transport, Salary...',
    },
    'transactionNotesHint': {
      'esp': 'Información adicional sobre la transacción...',
      'eng': 'Additional information about the transaction...',
    },
    'categoryNameHint': {
      'esp': 'Ej: Alimentación, Transporte, Entretenimiento...',
      'eng': 'Ex: Food, Transport, Entertainment...',
    },
    'subscriptionDescriptionHint': {
      'esp': 'Descripción breve de la suscripción...',
      'eng': 'Brief description of the subscription...',
    },
    'subscriptionNotesHint': {
      'esp': 'Información adicional sobre la suscripción...',
      'eng': 'Additional information about the subscription...',
    },
    // Additional missing keys
    'optional': {'esp': 'opcional', 'eng': 'optional'},
    'nameRequired': {
      'esp': 'El nombre es obligatorio',
      'eng': 'Name is required',
    },
    'invalidAmount': {'esp': 'Monto inválido', 'eng': 'Invalid amount'},
    'title': {'esp': 'Título', 'eng': 'Title'},
    'amount': {'esp': 'Monto', 'eng': 'Amount'},
    'notes': {'esp': 'Notas', 'eng': 'Notes'},
    'description': {'esp': 'Descripción', 'eng': 'Description'},
    'frequency': {'esp': 'Frecuencia', 'eng': 'Frequency'},
    'hasEndDate': {'esp': 'Tiene fecha de fin', 'eng': 'Has end date'},
    'selectDate': {'esp': 'Seleccionar fecha', 'eng': 'Select date'},
    'update': {'esp': 'Actualizar', 'eng': 'Update'},
    'transactionUpdated': {
      'esp': 'Transacción actualizada correctamente',
      'eng': 'Transaction updated successfully',
    },
    'transactionAdded': {
      'esp': 'Transacción agregada correctamente',
      'eng': 'Transaction added successfully',
    },
    'subscriptionAdded': {
      'esp': 'Suscripción agregada correctamente',
      'eng': 'Subscription added successfully',
    },
    'categoryAdded': {
      'esp': 'Categoría agregada correctamente',
      'eng': 'Category added successfully',
    },
    'createAndEditCustomCategories': {
      'esp': 'Crear y editar categorías personalizadas',
      'eng': 'Create and edit custom categories',
    },
    'addPaymentOnCreateSubscription': {
      'esp': 'Agregar pago al crear la suscripción',
      'eng': 'Add payment when creating subscription',
    },
    'addPaymentOnCreateRecurringPayment': {
      'esp': 'Agregar pago al crear el pago recurrente',
      'eng': 'Add payment when creating recurring payment',
    },
    'downloadExcelOrCsv': {
      'esp': 'Descargar en Excel o CSV',
      'eng': 'Download in Excel or CSV',
    },
    'account': {'esp': 'Cuenta', 'eng': 'Account'},
    'accounts': {'esp': 'Cuentas', 'eng': 'Accounts'},
    'accountName': {'esp': 'Nombre', 'eng': 'Name'},
    'initialBalance': {'esp': 'Balance inicial', 'eng': 'Initial Balance'},
    'accountDeleted': {'esp': 'Cuenta eliminada', 'eng': 'Account deleted'},
    'accountAdded': {
      'esp': 'Cuenta agregada exitosamente',
      'eng': 'Account added successfully',
    },
    'balanceUpdated': {
      'esp': 'Balance actualizado exitosamente',
      'eng': 'Balance updated successfully',
    },
    'newAccount': {'esp': 'Nueva Cuenta', 'eng': 'New Account'},
    'editBalance': {'esp': 'Editar Balance', 'eng': 'Edit Balance'},
    'balanceReferenceInfo': {
      'esp':
          'El balance inicial es solo una referencia. Este valor no afecta tus transacciones existentes.',
      'eng':
          'Initial balance is for reference only. This value does not affect your existing transactions.',
    },
    'monthlyExpenseLimit': {
      'esp': 'Límite Mensual de Gastos',
      'eng': 'Monthly Expense Limit',
    },
    'limitExceeded': {'esp': 'Límite excedido', 'eng': 'Limit exceeded'},
    'remaining': {'esp': 'Queda', 'eng': 'Remaining'},
    'used': {'esp': 'usado', 'eng': 'used'},
    'of': {'esp': 'de', 'eng': 'of'},
    'distributionByCategory': {
      'esp': 'Distribución por Categoría',
      'eng': 'Distribution by Category',
    },
    'week': {'esp': 'Semana', 'eng': 'Week'},
    'month': {'esp': 'Mes', 'eng': 'Month'},
    'year': {'esp': 'Año', 'eng': 'Year'},
    'noExpenses': {'esp': 'No hay gastos', 'eng': 'No expenses'},
    'noIncome': {'esp': 'No hay ingresos', 'eng': 'No income'},
    'noDataForPeriod': {
      'esp': 'No hay datos en este período',
      'eng': 'No data for this period',
    },
    'yesterday': {'esp': 'Ayer', 'eng': 'Yesterday'},
    'transaction': {'esp': 'transacción', 'eng': 'transaction'},
    'transactions': {'esp': 'transacciones', 'eng': 'transactions'},
    'noTitle': {'esp': 'Sin título', 'eng': 'No title'},
    'daysAgo': {'esp': 'días atrás', 'eng': 'days ago'},
    'inDays': {'esp': 'En X días', 'eng': 'In X days'},
    'finished': {'esp': 'Finalizada', 'eng': 'Finished'},
    'endsToday': {'esp': 'Finaliza hoy', 'eng': 'Ends today'},
    'endsInDays': {'esp': 'Finaliza en X días', 'eng': 'Ends in X days'},
    'endsOn': {'esp': 'Finaliza el', 'eng': 'Ends on'},
    'manageYourSubscription': {
      'esp': 'Gestiona tu suscripción',
      'eng': 'Manage your subscription',
    },
    'manageYourRecurringPayment': {
      'esp': 'Gestiona tu pago recurrente',
      'eng': 'Manage your recurring payment',
    },
    'pauseSubtitle': {
      'esp': 'Detener temporalmente',
      'eng': 'Temporarily stop',
    },
    'resumeSubtitle': {
      'esp': 'Reactivar suscripción',
      'eng': 'Reactivate subscription',
    },
    'deleteSubtitle': {
      'esp': 'Eliminar permanentemente',
      'eng': 'Permanently delete',
    },
    'noLimitConfigured': {
      'esp': 'Sin límite configurado',
      'eng': 'No limit configured',
    },
    'management': {'esp': 'Gestión', 'eng': 'Management'},
    'weekStart': {'esp': 'Inicio de semana', 'eng': 'Week start'},
    'monday': {'esp': 'Lunes', 'eng': 'Monday'},
    'sunday': {'esp': 'Domingo', 'eng': 'Sunday'},
    'restoreCategories': {
      'esp': 'Restaurar Categorías',
      'eng': 'Restore Categories',
    },
    'restoreCategoriesDescription': {
      'esp':
          'Restaurar categorías por defecto (elimina categorías personalizadas)',
      'eng': 'Restore default categories (removes custom categories)',
    },
    'notifications': {'esp': 'Notificaciones', 'eng': 'Notifications'},
    'notificationsPermissionRequired': {
      'esp': 'Se necesitan permisos para las notificaciones',
      'eng': 'Permissions required for notifications',
    },
    'testNotification': {
      'esp': 'Probar Notificación',
      'eng': 'Test Notification',
    },
    'sendTestNotification': {
      'esp': 'Enviar notificación de prueba',
      'eng': 'Send test notification',
    },
    'premiumModeTesting': {
      'esp': 'Modo Premium (Pruebas)',
      'eng': 'Premium Mode (Testing)',
    },
    'sendingTestNotification': {
      'esp': 'Enviando notificación de prueba...',
      'eng': 'Sending test notification...',
    },
    'setMonthlyExpenseLimit': {
      'esp':
          'Establece un límite de gastos para el mes. La barra de progreso en el dashboard te ayudará a controlar tus gastos.',
      'eng':
          'Set a monthly expense limit. The progress bar in the dashboard will help you control your expenses.',
    },
    'removeLimit': {'esp': 'Eliminar límite', 'eng': 'Remove limit'},
    'enterValidValue': {
      'esp': 'Por favor ingresa un valor válido',
      'eng': 'Please enter a valid value',
    },
    'categoriesUpdated': {
      'esp': 'Categorías actualizadas con nuevos iconos',
      'eng': 'Categories updated with new icons',
    },
    'updateIcons': {'esp': 'Actualizar Iconos', 'eng': 'Update Icons'},
    'categoriesRestoredSuccessfully': {
      'esp': 'Categorías restauradas correctamente',
      'eng': 'Categories restored successfully',
    },
    'errorRestoringCategories': {
      'esp': 'Error al restaurar categorías',
      'eng': 'Error restoring categories',
    },
    'weeklyLimit': {'esp': 'Límite mensual', 'eng': 'Monthly limit'},
    'exampleAmount': {'esp': 'Ej: 1000.00', 'eng': 'Ex: 1000.00'},
    'maxAccountsReached': {
      'esp': 'Límite de cuentas alcanzado',
      'eng': 'Account limit reached',
    },
    'freeAccountLimitMessage': {
      'esp':
          'La versión gratuita permite hasta 2 cuentas. Actualiza a Premium para agregar cuentas ilimitadas.',
      'eng':
          'The free version allows up to 2 accounts. Upgrade to Premium to add unlimited accounts.',
    },
    'upgradeToPremium': {
      'esp': 'Actualizar a Premium',
      'eng': 'Upgrade to Premium',
    },
    'premiumRequired': {'esp': 'Premium Requerido', 'eng': 'Premium Required'},
    'accountsLimit': {
      'esp': 'Cuentas: {current} de {limit}',
      'eng': 'Accounts: {current} of {limit}',
    },
    'unlimitedAccounts': {
      'esp': 'Cuentas ilimitadas',
      'eng': 'Unlimited accounts',
    },
    'purchaseSuccessful': {
      'esp':
          '¡Compra exitosa! Ahora tienes acceso a todas las funciones Premium.',
      'eng':
          'Purchase successful! You now have access to all Premium features.',
    },
    'purchaseError': {
      'esp': 'Error al procesar la compra. Por favor intenta de nuevo.',
      'eng': 'Error processing purchase. Please try again.',
    },
    'purchasesNotAvailable': {
      'esp': 'Las compras no están disponibles en este momento.',
      'eng': 'Purchases are not available at this time.',
    },
    'productsNotFound': {
      'esp': 'No se encontraron productos disponibles.',
      'eng': 'No products found.',
    },
    'purchaseCanceled': {
      'esp': 'La compra fue cancelada.',
      'eng': 'Purchase was canceled.',
    },
    'processingPurchase': {
      'esp': 'Procesando compra...',
      'eng': 'Processing purchase...',
    },
    'restorePurchases': {
      'esp': 'Verificar Suscripción',
      'eng': 'Verify Subscription',
    },
    'purchasesRestored': {
      'esp': 'Suscripción verificada correctamente',
      'eng': 'Subscription verified successfully',
    },
    'selectPlan': {
      'esp': 'Selecciona tu plan Premium',
      'eng': 'Select your Premium plan',
    },
    'premiumFeaturesIncluded': {
      'esp': 'Incluye todas las funciones Premium',
      'eng': 'Includes all Premium features',
    },
    'bestValue': {'esp': 'Mejor valor', 'eng': 'Best value'},
    'workingCorrectly': {
      'esp': 'están funcionando correctamente',
      'eng': 'are working correctly',
    },
    'testNotificationSent': {
      'esp': 'Notificación de prueba enviada',
      'eng': 'Test notification sent',
    },
    'errorSendingNotification': {
      'esp': 'Error enviando notificación',
      'eng': 'Error sending notification',
    },
    'paymentReminder': {
      'esp': 'Recordatorio de Pago',
      'eng': 'Payment Reminder',
    },
    'subscriptionDueSoon': {
      'esp': 'vence pronto. ¡No olvides pagarlo!',
      'eng': 'is due soon. Don\'t forget to pay it!',
    },
    'paymentProcessed': {'esp': 'Pago Procesado', 'eng': 'Payment Processed'},
    'immediateNotifications': {
      'esp': 'Notificaciones Inmediatas',
      'eng': 'Immediate Notifications',
    },
    'immediateNotificationsDescription': {
      'esp': 'Notificaciones que se muestran inmediatamente',
      'eng': 'Notifications that are shown immediately',
    },
    'faq': {'esp': 'Preguntas Frecuentes', 'eng': 'Frequently Asked Questions'},
    'faqDescription': {
      'esp': 'Encuentra respuestas a preguntas comunes',
      'eng': 'Find answers to common questions',
    },
    'support': {'esp': 'Soporte', 'eng': 'Support'},
    'supportSubtitle': {
      'esp': 'Estamos aquí para ayudarte',
      'eng': 'We\'re here to help',
    },
    'contactSupport': {'esp': 'Contactar Soporte', 'eng': 'Contact Support'},
    'contactSupportDescription': {
      'esp': 'Envía un email o consulta información',
      'eng': 'Send an email or get information',
    },
    'supportEmail': {'esp': 'Email de Soporte', 'eng': 'Support Email'},
    'sendEmail': {'esp': 'Enviar Email', 'eng': 'Send Email'},
    'emailCopied': {
      'esp': 'Email copiado al portapapeles',
      'eng': 'Email copied to clipboard',
    },
    'supportInfo': {
      'esp': 'Información de Soporte',
      'eng': 'Support Information',
    },
    'appInfo': {'esp': 'Información de la App', 'eng': 'App Information'},
    'appName': {'esp': 'CuidaTuPlata', 'eng': 'CuidaTuPlata'},
    'appVersion': {'esp': 'Versión', 'eng': 'Version'},
    'platform': {'esp': 'Plataforma', 'eng': 'Platform'},
    'services': {'esp': 'Servicios', 'eng': 'Services'},
    'recurringPayments': {
      'esp': 'Pagos Recurrentes',
      'eng': 'Recurring Payments',
    },
    'recurringPaymentsDescription': {
      'esp': 'Gestiona facturas e ingresos recurrentes',
      'eng': 'Manage recurring bills and income',
    },
    'addRecurringPayment': {
      'esp': 'Agregar Pago Recurrente',
      'eng': 'Add Recurring Payment',
    },
    'editRecurringPayment': {
      'esp': 'Editar Pago Recurrente',
      'eng': 'Edit Recurring Payment',
    },
    'recurringPaymentName': {'esp': 'Nombre', 'eng': 'Name'},
    'recurringPaymentDescription': {
      'esp': 'Descripción (opcional)',
      'eng': 'Description (optional)',
    },
    'recurringPaymentAmount': {'esp': 'Monto', 'eng': 'Amount'},
    'recurringPaymentType': {'esp': 'Tipo de pago', 'eng': 'Payment type'},
    'recurringPaymentCategory': {'esp': 'Categoría', 'eng': 'Category'},
    'recurringPaymentFrequency': {'esp': 'Frecuencia', 'eng': 'Frequency'},
    'dayOfMonth': {'esp': 'Día del mes', 'eng': 'Day of month'},
    'dayOfMonthHint': {
      'esp': 'Día en que se realiza el pago (1-31)',
      'eng': 'Day when payment is made (1-31)',
    },
    'recurringPaymentCreated': {
      'esp': 'Pago recurrente creado correctamente',
      'eng': 'Recurring payment created successfully',
    },
    'recurringPaymentUpdated': {
      'esp': 'Pago recurrente actualizado correctamente',
      'eng': 'Recurring payment updated successfully',
    },
    'recurringPaymentDeleted': {
      'esp': 'Pago recurrente eliminado correctamente',
      'eng': 'Recurring payment deleted successfully',
    },
    'recurringPaymentNameRequired': {
      'esp': 'El nombre es obligatorio',
      'eng': 'Name is required',
    },
    'recurringPaymentAmountRequired': {
      'esp': 'El monto es obligatorio',
      'eng': 'Amount is required',
    },
    'recurringPaymentCategoryRequired': {
      'esp': 'La categoría es obligatoria',
      'eng': 'Category is required',
    },
    'selectRecurringPaymentType': {
      'esp': 'Selecciona el tipo de pago',
      'eng': 'Select payment type',
    },
    'selectRecurringPaymentCategory': {
      'esp': 'Selecciona una categoría',
      'eng': 'Select a category',
    },
    'noRecurringPayments': {
      'esp': 'No hay pagos recurrentes',
      'eng': 'No recurring payments',
    },
    'addFirstRecurringPayment': {
      'esp': 'Agrega tu primer pago recurrente',
      'eng': 'Add your first recurring payment',
    },
    'noRecurringExpenses': {
      'esp': 'No hay gastos recurrentes',
      'eng': 'No recurring expenses',
    },
    'addFirstRecurringExpense': {
      'esp': 'Agrega tu primer gasto recurrente',
      'eng': 'Add your first recurring expense',
    },
    'noRecurringIncome': {
      'esp': 'No hay ingresos recurrentes',
      'eng': 'No recurring income',
    },
    'addFirstRecurringIncome': {
      'esp': 'Agrega tu primer ingreso recurrente',
      'eng': 'Add your first recurring income',
    },
    'searchRecurringPayments': {
      'esp': 'Buscar pagos recurrentes...',
      'eng': 'Search recurring payments...',
    },
    'deleteRecurringPayment': {
      'esp': 'Eliminar Pago Recurrente',
      'eng': 'Delete Recurring Payment',
    },
    'deleteRecurringPaymentConfirm': {
      'esp': '¿Estás seguro de que quieres eliminar "{name}"?',
      'eng': 'Are you sure you want to delete "{name}"?',
    },
    'dueSoon': {'esp': 'Próximo', 'eng': 'Due Soon'},
    'moreNotificationsOptions': {
      'esp': 'Más opciones de notificaciones',
      'eng': 'More notification options',
    },
    'advancedReminderOptionsPremium': {
      'esp':
          'Las opciones avanzadas de recordatorios están disponibles para usuarios Premium. Actualiza a Premium para personalizar tus preferencias de recordatorios.',
      'eng':
          'Advanced reminder options are available for Premium users. Upgrade to Premium to customize your reminder preferences.',
    },
    'dataExportPremiumFeature': {
      'esp':
          'La exportación de datos es una función Premium. Actualiza a Premium para exportar tus transacciones en formato Excel o CSV.',
      'eng':
          'Data export is a Premium feature. Upgrade to Premium to export your transactions to Excel or CSV format.',
    },
    'productNotAvailable': {
      'esp': 'Este producto no está disponible. Por favor intenta más tarde.',
      'eng': 'This product is not available. Please try again later.',
    },
    'paymentMethodInvalid': {
      'esp':
          'El método de pago no es válido. Por favor verifica tu información de pago.',
      'eng':
          'Payment method is invalid. Please check your payment information.',
    },
    'purchaseServiceUnavailable': {
      'esp':
          'El servicio de compras no está disponible temporalmente. Por favor intenta más tarde.',
      'eng':
          'Purchase service is temporarily unavailable. Please try again later.',
    },
    'networkErrorCheckConnection': {
      'esp':
          'Error de conexión. Por favor verifica tu conexión a internet e intenta de nuevo.',
      'eng':
          'Network error. Please check your internet connection and try again.',
    },
    'purchaseIssueContactSupport': {
      'esp':
          'Hubo un problema con la compra. Por favor contacta soporte si esto continúa.',
      'eng':
          'There was an issue with the purchase. Please contact support if this continues.',
    },
    'noTransactionsToExport': {
      'esp': 'No hay transacciones para exportar',
      'eng': 'No transactions to export',
    },
    'exportToExcelFormat': {
      'esp': 'Exportar en formato Excel',
      'eng': 'Export to Excel format',
    },
    'exportToCsvFormat': {
      'esp': 'Exportar en formato CSV',
      'eng': 'Export to CSV format',
    },
    'fileExportedSuccessfully': {
      'esp': '¡Archivo exportado exitosamente!',
      'eng': 'File exported successfully!',
    },
    'whatWouldYouLikeToDoWithFile': {
      'esp': '¿Qué deseas hacer con el archivo?',
      'eng': 'What would you like to do with the file?',
    },
    'saveLocation': {'esp': 'Ubicación de guardado:', 'eng': 'Save location:'},
    'share': {'esp': 'Compartir', 'eng': 'Share'},
    'saveToDownloads': {
      'esp': 'Guardar en Descargas',
      'eng': 'Save to Downloads',
    },
    'fileSavedSuccessfully': {
      'esp': '¡Archivo guardado exitosamente!',
      'eng': 'File saved successfully!',
    },
    'locationDownloads': {
      'esp': 'Ubicación: Descargas/{fileName}',
      'eng': 'Location: Downloads/{fileName}',
    },
    'errorSavingFileToDownloads': {
      'esp': 'Error al guardar archivo en Descargas',
      'eng': 'Error saving file to Downloads',
    },
    'transactionsExportedSuccessfully': {
      'esp': '¡Transacciones exportadas exitosamente!',
      'eng': 'Transactions exported successfully!',
    },
    'errorExportingTransactions': {
      'esp': 'Error al exportar transacciones',
      'eng': 'Error exporting transactions',
    },
    'faqHowAddTransaction': {
      'esp': '¿Cómo agrego una transacción?',
      'eng': 'How do I add a transaction?',
    },
    'faqHowAddTransactionAnswer': {
      'esp':
          'Toca el botón + en la pantalla de inicio para agregar una nueva transacción. Selecciona el tipo (ingreso o gasto), ingresa el monto, elige una categoría y guarda.',
      'eng':
          'Tap the + button on the dashboard screen to add a new transaction. Select the type (income or expense), enter the amount, choose a category, and save.',
    },
    'faqHowManageCategories': {
      'esp': '¿Cómo gestiono las categorías?',
      'eng': 'How do I manage categories?',
    },
    'faqHowManageCategoriesAnswer': {
      'esp':
          'Ve a Configuración > Gestión > Gestionar Categorías. Puedes crear, editar y eliminar categorías personalizadas. Las categorías por defecto se pueden restaurar en cualquier momento.',
      'eng':
          'Go to Settings > Management > Manage Categories. You can create, edit, and delete custom categories. Default categories can be restored at any time.',
    },
    'faqHowSubscriptionsWork': {
      'esp': '¿Cómo funcionan las suscripciones?',
      'eng': 'How do subscriptions work?',
    },
    'faqHowSubscriptionsWorkAnswer': {
      'esp':
          'Las suscripciones te permiten rastrear pagos recurrentes. Establece la frecuencia, el monto y la fecha del próximo pago. Recibirás recordatorios antes de que venza el pago.',
      'eng':
          'Subscriptions allow you to track recurring payments. Set the frequency, amount, and next payment date. You\'ll receive reminders before the payment is due.',
    },
    'faqWhatIsPremium': {
      'esp': '¿Qué es la versión premium?',
      'eng': 'What is the premium version?',
    },
    'faqWhatIsPremiumAnswer': {
      'esp':
          'La versión premium elimina los anuncios, proporciona soporte prioritario y permite cuentas ilimitadas. Puedes comprarla mensualmente o anualmente con descuento.',
      'eng':
          'The premium version removes ads, provides priority support, and allows unlimited accounts. You can purchase it monthly or annually with a discount.',
    },
    'faqHowSetMonthlyLimit': {
      'esp': '¿Cómo establezco un límite de gastos mensual?',
      'eng': 'How do I set a monthly expense limit?',
    },
    'faqHowSetMonthlyLimitAnswer': {
      'esp':
          'Ve a Configuración > Configuración Financiera > Límite de Gastos Mensual. Ingresa tu límite deseado y la app rastreará tus gastos comparándolos con él.',
      'eng':
          'Go to Settings > Financial Settings > Monthly Expense Limit. Enter your desired limit, and the app will track your spending against it.',
    },
    'faqCanUseMultipleAccounts': {
      'esp': '¿Puedo usar múltiples cuentas?',
      'eng': 'Can I use multiple accounts?',
    },
    'faqCanUseMultipleAccountsAnswer': {
      'esp':
          '¡Sí! Puedes crear y cambiar entre múltiples cuentas. Cada cuenta tiene sus propias transacciones, suscripciones y balance. Los usuarios premium pueden tener cuentas ilimitadas.',
      'eng':
          'Yes! You can create and switch between multiple accounts. Each account has its own transactions, subscriptions, and balance. Premium users can have unlimited accounts.',
    },
    'faqHowNotificationsWork': {
      'esp': '¿Cómo funcionan las notificaciones?',
      'eng': 'How do notifications work?',
    },
    'faqHowNotificationsWorkAnswer': {
      'esp':
          'Habilita las notificaciones en Configuración > Notificaciones. Recibirás recordatorios para los pagos de suscripciones antes de que venzan. Puedes configurar con cuántos días de anticipación quieres ser notificado.',
      'eng':
          'Enable notifications in Settings > Notifications. You\'ll receive reminders for subscription payments before they\'re due. You can configure how many days in advance you want to be notified.',
    },
    'supportResponseTime': {
      'esp':
          'Normalmente respondemos en 24-48 horas. Para asuntos urgentes, por favor menciona "URGENTE" en el asunto.',
      'eng':
          'We typically respond within 24-48 hours. For urgent matters, please mention "URGENT" in the subject line.',
    },
    'emailInfoCopied': {
      'esp':
          'Información del email copiada. Por favor pégalo en tu cliente de email.',
      'eng': 'Email information copied. Please paste it in your email client.',
    },
    'supportRequestSubject': {
      'esp': 'Solicitud de Soporte - CuidaTuPlata',
      'eng': 'Support Request - CuidaTuPlata',
    },
    'supportEmailBody': {
      'esp': 'Hola,\n\nNecesito ayuda con:\n\n\n\nVersión de la App: {version}',
      'eng': 'Hello,\n\nI need help with:\n\n\n\nApp Version: {version}',
    },
    'frequencyShortDay': {'esp': 'Día', 'eng': 'Day'},
    'frequencyShortWeek': {'esp': 'Sem', 'eng': 'Week'},
    'frequencyShortMonth': {'esp': 'Mes', 'eng': 'Month'},
    'frequencyShortQuarter': {'esp': 'Trim', 'eng': 'Qtr'},
    'frequencyShortYear': {'esp': 'Año', 'eng': 'Year'},
  };
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_config_provider.dart';

class SimpleLocalization {
  static String getText(WidgetRef ref, String key) {
    final appConfig = ref.read(appConfigProvider);
    final isEnglish = appConfig.language == 'en';

    return _getTextByKey(key, isEnglish);
  }

  static String _getTextByKey(String key, bool isEnglish) {
    final translation = _translations[key];
    if (translation == null) return key;

    return isEnglish
        ? (translation['eng'] ?? key)
        : (translation['esp'] ?? key);
  }

  static const Map<String, Map<String, String>> _translations = {
    'before':{'esp': 'antes', 'eng': 'before'},
    'appTitle': {'esp': 'MiControl', 'eng': 'MiControl'},
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
    'subscriptionDueSoon': {
      'esp': 'Pago próximo a vencer',
      'eng': 'Payment due soon',
    },
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
    'unlockPremiumFeatures': {
      'esp': 'Desbloquea todas las funciones premium:',
      'eng': 'Unlock all premium features:',
    },
    'noAds': {'esp': '• Sin anuncios', 'eng': '• No ads'},
    'advancedExport': {
      'esp': '• Exportación avanzada',
      'eng': '• Advanced export',
    },
    'customThemes': {'esp': '• Temas personalizados', 'eng': '• Custom themes'},
    'cloudBackup': {'esp': '• Backup en la nube', 'eng': '• Cloud backup'},
    'prioritySupport': {
      'esp': '• Soporte prioritario',
      'eng': '• Priority support',
    },
    'close': {'esp': 'Cerrar', 'eng': 'Close'},
    'upgrade': {'esp': 'Actualizar', 'eng': 'Upgrade'},
    'settingsRestored': {
      'esp': 'Configuración restaurada',
      'eng': 'Settings restored',
    },
    'restore': {'esp': 'Restaurar', 'eng': 'Restore'},
    'day': {'esp': 'día', 'eng': 'day'},
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
    'category':{
      'esp': 'Categoría',
      'eng': 'Category',
    },
    'manageSubscriptions': {
      'esp': 'Gestionar Suscripciones',
      'eng': 'Manage Subscriptions',
    },
    'date':{
      'esp': 'Fecha',
      'eng': 'Date',
    },
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
    'addPaymentOnCreate': {
      'esp': 'Agregar pago al crear la suscripción',
      'eng': 'Add payment on create subscription',
    },
    'downloadExcelOrCsv': {
      'esp': 'Descargar en Excel o CSV',
      'eng': 'Download in Excel or CSV',
    },
  };
}

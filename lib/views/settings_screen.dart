import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../providers/settings_provider.dart';
import '../providers/admob_provider.dart';
import '../providers/app_config_provider.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import '../utils/app_formatters.dart';
import 'categories_screen.dart';
import '../services/hive_service.dart';
import '../providers/category_provider.dart';
import '../services/notification_service.dart';
import '../services/timer_service.dart';
import '../providers/subscription_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final hiveInitialized = ref.watch(hiveInitializedProvider);
    final appConfig = ref.watch(appConfigProvider);

    // Inicializar la configuración cuando Hive esté listo
    ref.listen(hiveInitializedProvider, (previous, next) {
      next.whenData((isInitialized) {
        if (isInitialized) {
          ref.read(appConfigProvider.notifier).initializeConfig();
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: Text(SimpleLocalization.getText(ref, 'settings'))),
      body: hiveInitialized.when(
        data: (isInitialized) => isInitialized
            ? _buildSettingsContent(
                context,
                ref,
                appConfig,
                isDarkMode,
                isPremium,
              )
            : _buildLoadingWidget(ref),
        loading: () => _buildLoadingWidget(ref),
        error: (error, stack) => _buildErrorWidget(error, ref),
      ),
    );
  }

  Widget _buildLoadingWidget(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(SimpleLocalization.getText(ref, 'initializingConfig')),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIconsStrokeRounded.alertCircle,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text('${SimpleLocalization.getText(ref, 'error')} $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Recargar la página
            },
            child: Text(SimpleLocalization.getText(ref, 'retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    appConfig,
    bool isDarkMode,
    bool isPremium,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      children: [
        // Sección Financiera
        _buildSection(
          context,
          SimpleLocalization.getText(ref, 'settingsFinancial'),
          [
            _buildDropdownTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'currency'),
              _getCurrencyDisplayName(appConfig.currency, ref),
              HugeIconsStrokeRounded.money01,
              () => _showCurrencyDialog(context, ref),
            ),
            _buildDropdownTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'dateFormat'),
              _getDateFormatDisplayName(appConfig.dateFormat, ref),
              HugeIconsStrokeRounded.calendar01,
              () => _showDateFormatDialog(context, ref),
            ),
            _buildDropdownTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'decimalSeparator'),
              appConfig.decimalSeparator == '.'
                  ? SimpleLocalization.getText(ref, 'pointSeparator')
                  : SimpleLocalization.getText(ref, 'commaSeparator'),
              HugeIconsStrokeRounded.menu01,
              () => _showDecimalSeparatorDialog(context, ref),
            ),
            _buildSwitchTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'showCents'),
              appConfig.showCents,
              HugeIconsStrokeRounded.dollar01,
              (value) =>
                  ref.read(appConfigProvider.notifier).updateShowCents(value),
            ),
            _buildListTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'monthlyExpenseLimit'),
              appConfig.monthlyExpenseLimit > 0
                  ? AppFormatters.formatCurrency(
                      appConfig.monthlyExpenseLimit,
                      ref,
                    )
                  : SimpleLocalization.getText(ref, 'noLimitConfigured'),
              HugeIconsStrokeRounded.stopCircle,
              () => _showMonthlyLimitDialog(context, ref),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Sección Visual
        _buildSection(
          context,
          SimpleLocalization.getText(ref, 'settingsVisual'),
          [
            _buildSwitchTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'darkMode'),
              isDarkMode,
              HugeIconsStrokeRounded.moon01,
              (value) => ref.read(settingsProvider.notifier).setTheme(value),
            ),
            _buildDropdownTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'fontSize'),
              _getFontSizeDisplayName(appConfig.fontSize, ref),
              HugeIconsStrokeRounded.edit01,
              () => _showFontSizeDialog(context, ref),
            ),
            _buildListTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'weekStart'),
              appConfig.weekStartsOnMonday
                  ? SimpleLocalization.getText(ref, 'monday')
                  : SimpleLocalization.getText(ref, 'sunday'),
              HugeIconsStrokeRounded.calendar01,
              () => _showWeekStartDialog(context, ref),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Sección de Gestión
        _buildSection(context, SimpleLocalization.getText(ref, 'management'), [
          _buildListTile(
            context,
            ref,
            SimpleLocalization.getText(ref, 'manageCategories'),
            SimpleLocalization.getText(ref, 'createAndEditCustomCategories'),
            HugeIconsStrokeRounded.tag01,
            () => _navigateToCategories(context),
          ),
          _buildListTile(
            context,
            ref,
            SimpleLocalization.getText(ref, 'restoreCategories'),
            SimpleLocalization.getText(ref, 'restoreCategoriesDescription'),
            HugeIconsStrokeRounded.arrowLeft01,
            () => _showRestoreCategoriesDialog(context, ref),
          ),
        ]),

        const SizedBox(height: AppConstants.defaultPadding),

        // Sección de Privacidad
        _buildSection(
          context,
          SimpleLocalization.getText(ref, 'settingsPrivacy'),
          [
            _buildListTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'deleteAllData'),
              SimpleLocalization.getText(
                ref,
                'deleteTransactionsAndSubscriptions',
              ),
              HugeIconsStrokeRounded.delete01,
              () => _showDeleteDataDialog(context, ref),
            ),
            _buildListTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'exportData'),
              isPremium
                  ? SimpleLocalization.getText(ref, 'downloadExcelOrCsv')
                  : SimpleLocalization.getText(ref, 'requiresPremium'),
              HugeIconsStrokeRounded.download01,
              () => isPremium
                  ? _showExportDataDialog(context, ref)
                  : _showPremiumDialog(context, ref),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Sección de App
        _buildSection(context, SimpleLocalization.getText(ref, 'settingsApp'), [
          _buildDropdownTile(
            context,
            ref,
            SimpleLocalization.getText(ref, 'language'),
            _getLanguageDisplayName(appConfig.language, ref),
            HugeIconsStrokeRounded.globe,
            () => _showLanguageDialog(context, ref),
          ),
          _buildSwitchTile(
            context,
            ref,
            SimpleLocalization.getText(ref, 'vibration'),
            appConfig.vibration,
            HugeIconsStrokeRounded.moon,
            (value) =>
                ref.read(appConfigProvider.notifier).updateVibration(value),
          ),
          _buildSwitchTile(
            context,
            ref,
            SimpleLocalization.getText(ref, 'sound'),
            appConfig.sound,
            HugeIconsStrokeRounded.speaker01,
            (value) => ref.read(appConfigProvider.notifier).updateSound(value),
          ),
        ]),

        const SizedBox(height: AppConstants.defaultPadding),

        // Sección de Notificaciones
        _buildSection(
          context,
          SimpleLocalization.getText(ref, 'settingsNotifications'),
          [
            // Switch para habilitar/deshabilitar notificaciones
            _buildSwitchTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'notifications'),
              appConfig.notificationsEnabled,
              HugeIconsStrokeRounded.notification01,
              (value) async {
                if (value) {
                  // Solicitar permisos
                  final granted =
                      await NotificationService.requestPermissions();
                  if (!granted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          SimpleLocalization.getText(
                            ref,
                            'notificationsPermissionRequired',
                          ),
                        ),
                      ),
                    );
                    // Si no hay permisos, no habilitar las notificaciones
                    return;
                  }
                  // Guardar que las notificaciones están habilitadas
                  await ref
                      .read(appConfigProvider.notifier)
                      .updateNotificationsEnabled(true);
                  // Reprogramar todos los recordatorios
                  final subscriptions = ref.read(subscriptionsProvider);
                  await TimerService.scheduleAllSubscriptionReminders(
                    subscriptions,
                  );
                } else {
                  // Deshabilitar notificaciones
                  await ref
                      .read(appConfigProvider.notifier)
                      .updateNotificationsEnabled(false);
                  TimerService.cancelAllReminders();
                }
              },
            ),
            _buildDropdownTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'subscriptionReminders'),
              '${appConfig.subscriptionReminderDays} ${appConfig.subscriptionReminderDays == 1 ? SimpleLocalization.getText(ref, 'day') : SimpleLocalization.getText(ref, 'days')} ${SimpleLocalization.getText(ref, 'before')}',
              HugeIconsStrokeRounded.notification01,
              () => _showReminderDaysDialog(context, ref),
            ),
            _buildListTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'testNotification'),
              SimpleLocalization.getText(ref, 'sendTestNotification'),
              HugeIconsStrokeRounded.testTube,
              () => _testNotification(context, ref),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Sección de Cuenta
        _buildSection(
          context,
          SimpleLocalization.getText(ref, 'settingsAccount'),
          [
            _buildListTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'premiumVersion'),
              isPremium
                  ? SimpleLocalization.getText(ref, 'premiumActive')
                  : SimpleLocalization.getText(ref, 'premiumInactive'),
              HugeIconsStrokeRounded.star,
              () => _showPremiumDialog(context, ref),
            ),
            // Toggle para pruebas - Cambiar entre premium y no premium
            _buildSwitchTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'premiumModeTesting'),
              isPremium,
              HugeIconsStrokeRounded.star,
              (value) => ref.read(settingsProvider.notifier).setPremium(value),
            ),
            // Solo mostrar opción de anuncios si NO es premium
            if (!isPremium)
              _buildSwitchTile(
                context,
                ref,
                SimpleLocalization.getText(ref, 'ads'),
                !isPremium,
                HugeIconsStrokeRounded.megaphone01,
                (value) =>
                    ref.read(adMobStateProvider.notifier).setAdsEnabled(value),
                enabled: !isPremium,
              ),
          ],
        ),

        const SizedBox(height: AppConstants.largePadding),

        // Botón de reset
        Center(
          child: OutlinedButton.icon(
            onPressed: () => _showResetDialog(context, ref),
            icon: HugeIcon(icon: HugeIconsStrokeRounded.refresh, size: 20),
            label: Text(SimpleLocalization.getText(ref, 'restoreSettings')),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    WidgetRef ref,
    String title,
    bool value,
    List<List<dynamic>> icon,
    Function(bool) onChanged, {
    bool enabled = true,
  }) {
    return ListTile(
      leading: HugeIcon(icon: icon, size: 20),
      title: Text(title),
      subtitle: enabled
          ? null
          : Text(SimpleLocalization.getText(ref, 'requiresPremium')),
      trailing: Switch(value: value, onChanged: enabled ? onChanged : null),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    WidgetRef ref,
    String title,
    String subtitle,
    List<List<dynamic>> icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: HugeIcon(icon: icon, size: 20),
      trailing: HugeIcon(icon: HugeIconsStrokeRounded.arrowRight01, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile(
    BuildContext context,
    WidgetRef ref,
    String title,
    String value,
    List<List<dynamic>> icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      leading: HugeIcon(icon: icon, size: 20),
      trailing: HugeIcon(icon: HugeIconsStrokeRounded.arrowRight01, size: 20),
      onTap: onTap,
    );
  }

  // Métodos de diálogos
  void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
    final currencies = {
      'USD': '${SimpleLocalization.getText(ref, 'dollars')} (\$)',
      'EUR': '${SimpleLocalization.getText(ref, 'euros')} (€)',
      'MXN': '${SimpleLocalization.getText(ref, 'pesos')} (\$)',
      'GBP': '${SimpleLocalization.getText(ref, 'pounds')} (£)',
      'CAD': '${SimpleLocalization.getText(ref, 'canadianDollars')} (C\$)',
      'AUD': '${SimpleLocalization.getText(ref, 'australianDollars')} (A\$)',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'selectCurrency')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: ref.read(appConfigProvider).currency,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).updateCurrency(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDateFormatDialog(BuildContext context, WidgetRef ref) {
    final formats = {
      'DD/MM/YYYY': 'DD/MM/YYYY (25/12/2024)',
      'MM/DD/YYYY': 'MM/DD/YYYY (12/25/2024)',
      'YYYY-MM-DD': 'YYYY-MM-DD (2024-12-25)',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'dateFormat')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: formats.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: ref.read(appConfigProvider).dateFormat,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).updateDateFormat(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDecimalSeparatorDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'decimalSeparator')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Punto (.) - 1,234.56'),
              value: '.',
              groupValue: ref.read(appConfigProvider).decimalSeparator,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(appConfigProvider.notifier)
                      .updateDecimalSeparator(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Coma (,) - 1.234,56'),
              value: ',',
              groupValue: ref.read(appConfigProvider).decimalSeparator,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(appConfigProvider.notifier)
                      .updateDecimalSeparator(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, WidgetRef ref) {
    final sizes = {'small': 'Pequeño', 'normal': 'Normal', 'large': 'Grande'};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'fontSize')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sizes.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: ref.read(appConfigProvider).fontSize,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).updateFontSize(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final languages = {'es': 'Español', 'en': 'English'};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: ref.read(appConfigProvider).language,
              onChanged: (value) async {
                if (value != null) {
                  await ref
                      .read(appConfigProvider.notifier)
                      .updateLanguage(value);
                  // Refrescar las categorías después de cambiar idioma
                  ref.read(categoriesProvider.notifier).refresh();
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showReminderDaysDialog(BuildContext context, WidgetRef ref) {
    final days = [1, 3, 7, 14, 30];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'subscriptionReminders')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: days.map((day) {
            return RadioListTile<int>(
              title: Text(
                '$day ${day == 1 ? SimpleLocalization.getText(ref, 'day') : SimpleLocalization.getText(ref, 'days')} ${SimpleLocalization.getText(ref, 'before')}',
              ),
              value: day,
              groupValue: ref.read(appConfigProvider).subscriptionReminderDays,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(appConfigProvider.notifier)
                      .updateSubscriptionReminderDays(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'deleteAllData')),
        content: Text(SimpleLocalization.getText(ref, 'deleteDataWarning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'cancel')),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await HiveService.updateCategoriesWithNewIcons();
                ref.read(categoriesProvider.notifier).refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      SimpleLocalization.getText(ref, 'categoriesUpdated'),
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(SimpleLocalization.getText(ref, 'updateIcons')),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'exportData')),
        content: Text(SimpleLocalization.getText(ref, 'selectExportFormat')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'cancel')),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _exportToExcel(context, ref);
                },
                icon: HugeIcon(
                  icon: HugeIconsStrokeRounded.download01,
                  size: 16,
                ),
                label: const Text('Excel'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _exportToCsv(context, ref);
                },
                icon: HugeIcon(
                  icon: HugeIconsStrokeRounded.download01,
                  size: 16,
                ),
                label: const Text('CSV'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context, WidgetRef ref) {
    final isPremium = ref.read(isPremiumProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isPremium
              ? SimpleLocalization.getText(ref, 'premiumVersion')
              : SimpleLocalization.getText(ref, 'unlockPremiumFeatures'),
        ),
        content: isPremium
            ? _buildPremiumActiveContent(context, ref)
            : _buildPremiumPurchaseOptions(context, ref),
        actions: isPremium
            ? [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(SimpleLocalization.getText(ref, 'close')),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildPremiumPurchaseOptions(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SimpleLocalization.getText(ref, 'selectPlan'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Plan Mensual
        _buildPurchaseOption(
          context: context,
          ref: ref,
          title: SimpleLocalization.getText(ref, 'monthly'),
          price: '\$4.99',
          isBestValue: false,
          onTap: () => _processPurchase(context, ref, 'monthly'),
        ),
        const SizedBox(height: 12),
        // Plan Anual
        _buildPurchaseOption(
          context: context,
          ref: ref,
          title: SimpleLocalization.getText(ref, 'yearly'),
          price: '\$39.99',
          isBestValue: true,
          onTap: () => _processPurchase(context, ref, 'yearly'),
        ),
        const SizedBox(height: 16),
        Text(
          SimpleLocalization.getText(ref, 'premiumFeaturesIncluded'),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text('• ${SimpleLocalization.getText(ref, 'noAds')}'),
        Text('• ${SimpleLocalization.getText(ref, 'advancedExport')}'),
        Text('• ${SimpleLocalization.getText(ref, 'prioritySupport')}'),
        Text('• ${SimpleLocalization.getText(ref, 'unlimitedAccounts')}'),
      ],
    );
  }

  Widget _buildPremiumActiveContent(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.verified,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(SimpleLocalization.getText(ref, 'premiumActive')),
        const SizedBox(height: 8),
        Text(
          SimpleLocalization.getText(ref, 'unlockPremiumFeatures'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String price,
    required bool isBestValue,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (isBestValue)
                    Text(
                      SimpleLocalization.getText(ref, 'bestValue'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Procesa la compra (simulado por ahora)
  void _processPurchase(BuildContext context, WidgetRef ref, String plan) {
    Navigator.pop(context); // Cerrar el diálogo

    // SIMULACIÓN: Activar premium directamente
    // En producción, aquí se integraría con Google Play Billing o App Store
    ref.read(settingsProvider.notifier).setPremium(true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(SimpleLocalization.getText(ref, 'purchaseSuccessful')),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: SimpleLocalization.getText(ref, 'close'),
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'restoreSettings')),
        content: Text(
          SimpleLocalization.getText(ref, 'restoreSettingsConfirm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'cancel')),
          ),
          FilledButton(
            onPressed: () async {
              // Guardar el idioma actual antes del reset
              final currentLanguage = ref.read(appConfigProvider).language;

              // Resetear configuración de la app
              await ref.read(appConfigProvider.notifier).resetToDefaults();
              // Resetear configuración de settings
              await ref.read(settingsProvider.notifier).resetToDefaults();

              // Restaurar el idioma que tenía el usuario
              await ref
                  .read(appConfigProvider.notifier)
                  .updateLanguage(currentLanguage);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    SimpleLocalization.getText(ref, 'settingsRestored'),
                  ),
                ),
              );
            },
            child: Text(SimpleLocalization.getText(ref, 'restore')),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares para mostrar nombres
  String _getCurrencyDisplayName(String currency, WidgetRef ref) {
    final currencyNames = {
      'USD': '${SimpleLocalization.getText(ref, 'dollars')} (\$)',
      'EUR': '${SimpleLocalization.getText(ref, 'euros')} (€)',
      'MXN': '${SimpleLocalization.getText(ref, 'pesos')} (\$)',
      'GBP': '${SimpleLocalization.getText(ref, 'pounds')} (£)',
      'CAD': '${SimpleLocalization.getText(ref, 'canadianDollars')} (C\$)',
      'AUD': '${SimpleLocalization.getText(ref, 'australianDollars')} (A\$)',
    };

    return currencyNames[currency] ?? currency;
  }

  String _getDateFormatDisplayName(String format, WidgetRef ref) {
    final isEnglish = ref.read(appConfigProvider).language == 'en';
    final names = isEnglish
        ? {
            'DD/MM/YYYY': 'DD/MM/YYYY (25/12/2024)',
            'MM/DD/YYYY': 'MM/DD/YYYY (12/25/2024)',
            'YYYY-MM-DD': 'YYYY-MM-DD (2024-12-25)',
          }
        : {
            'DD/MM/YYYY': 'DD/MM/YYYY (25/12/2024)',
            'MM/DD/YYYY': 'MM/DD/YYYY (12/25/2024)',
            'YYYY-MM-DD': 'YYYY-MM-DD (2024-12-25)',
          };
    return names[format] ?? format;
  }

  String _getFontSizeDisplayName(String size, WidgetRef ref) {
    final isEnglish = ref.read(appConfigProvider).language == 'en';
    final names = isEnglish
        ? {'small': 'Small', 'normal': 'Normal', 'large': 'Large'}
        : {'small': 'Pequeño', 'normal': 'Normal', 'large': 'Grande'};
    return names[size] ?? size;
  }

  String _getLanguageDisplayName(String language, WidgetRef ref) {
    final isEnglish = ref.read(appConfigProvider).language == 'en';
    final names = isEnglish
        ? {'es': 'Español', 'en': 'English'}
        : {'es': 'Español', 'en': 'English'};
    return names[language] ?? language;
  }

  void _navigateToCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoriesScreen()),
    );
  }

  void _showRestoreCategoriesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Categorías'),
        content: const Text(
          '¿Estás seguro de que quieres restaurar las categorías por defecto?\n\n'
          'Esto eliminará todas las categorías personalizadas que hayas creado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'cancel')),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await HiveService.restoreDefaultCategories();
                ref.read(categoriesProvider.notifier).refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      SimpleLocalization.getText(
                        ref,
                        'categoriesRestoredSuccessfully',
                      ),
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${SimpleLocalization.getText(ref, 'errorRestoringCategories')}: $e',
                    ),
                  ),
                );
              }
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  /// Exporta los datos a Excel
  void _exportToExcel(BuildContext context, WidgetRef ref) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(SimpleLocalization.getText(ref, 'exportingToExcel')),
            ],
          ),
        ),
      );

      // Simular proceso de exportación
      await Future.delayed(const Duration(seconds: 2));

      // Cerrar diálogo de carga
      if (context.mounted) Navigator.pop(context);

      // Mostrar mensaje de éxito
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SimpleLocalization.getText(ref, 'exportCompleted')),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: SimpleLocalization.getText(ref, 'open'),
              textColor: Colors.white,
              onPressed: () {
                // Aquí se abriría el archivo Excel
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      SimpleLocalization.getText(ref, 'fileOpened'),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (context.mounted) Navigator.pop(context);

      // Mostrar error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${SimpleLocalization.getText(ref, 'exportError')}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Exporta los datos a CSV
  void _exportToCsv(BuildContext context, WidgetRef ref) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(SimpleLocalization.getText(ref, 'exportingToCsv')),
            ],
          ),
        ),
      );

      // Simular proceso de exportación
      await Future.delayed(const Duration(seconds: 1));

      // Cerrar diálogo de carga
      if (context.mounted) Navigator.pop(context);

      // Mostrar mensaje de éxito
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SimpleLocalization.getText(ref, 'exportCompleted')),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: SimpleLocalization.getText(ref, 'open'),
              textColor: Colors.white,
              onPressed: () {
                // Aquí se abriría el archivo CSV
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      SimpleLocalization.getText(ref, 'fileOpened'),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (context.mounted) Navigator.pop(context);

      // Mostrar error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${SimpleLocalization.getText(ref, 'exportError')}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Método para probar notificaciones
  void _testNotification(BuildContext context, WidgetRef ref) async {
    try {
      // Mostrar diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Enviando notificación de prueba...'),
            ],
          ),
        ),
      );

      // Enviar notificación de prueba
      await NotificationService.showImmediateNotification(
        title: '🧪 Notificación de Prueba',
        body: '¡Las notificaciones están funcionando correctamente!',
        payload: 'test_notification',
      );

      // Cerrar diálogo de carga
      if (context.mounted) Navigator.pop(context);

      // Mostrar mensaje de éxito
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Notificación de prueba enviada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (context.mounted) Navigator.pop(context);

      // Mostrar error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error enviando notificación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Muestra el diálogo para configurar el límite mensual de gastos
  void _showMonthlyLimitDialog(BuildContext context, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);
    final controller = TextEditingController(
      text: appConfig.monthlyExpenseLimit > 0
          ? appConfig.monthlyExpenseLimit.toStringAsFixed(2)
          : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'monthlyExpenseLimit')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(SimpleLocalization.getText(ref, 'setMonthlyExpenseLimit')),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: SimpleLocalization.getText(ref, 'weeklyLimit'),
                hintText: SimpleLocalization.getText(ref, 'exampleAmount'),
                prefixIcon: const Icon(Icons.attach_money),
                suffix: Text(
                  appConfig.currency == 'USD'
                      ? '\$'
                      : appConfig.currency == 'EUR'
                      ? '€'
                      : appConfig.currency == 'MXN'
                      ? '\$'
                      : appConfig.currency == 'GBP'
                      ? '£'
                      : appConfig.currency == 'CAD'
                      ? 'C\$'
                      : 'A\$',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.text = '';
              Navigator.pop(context);
            },
            child: Text(SimpleLocalization.getText(ref, 'removeLimit')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'cancel')),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty ||
                  text == '0' ||
                  text == '0.0' ||
                  text == '0.00') {
                // Eliminar límite
                await ref
                    .read(appConfigProvider.notifier)
                    .updateMonthlyExpenseLimit(0.0);
              } else {
                // Establecer límite
                final limit = double.tryParse(text);
                if (limit != null && limit > 0) {
                  await ref
                      .read(appConfigProvider.notifier)
                      .updateMonthlyExpenseLimit(limit);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          SimpleLocalization.getText(ref, 'enterValidValue'),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }
              }
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      text.isEmpty
                          ? 'Límite eliminado'
                          : 'Límite configurado correctamente',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(SimpleLocalization.getText(ref, 'save')),
          ),
        ],
      ),
    );
  }

  void _showWeekStartDialog(BuildContext context, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'weekStart')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: Text(SimpleLocalization.getText(ref, 'monday')),
              value: true,
              groupValue: appConfig.weekStartsOnMonday,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(context);
                  ref
                      .read(appConfigProvider.notifier)
                      .updateWeekStartsOnMonday(value);
                }
              },
              selected: appConfig.weekStartsOnMonday == true,
            ),
            RadioListTile<bool>(
              title: Text(SimpleLocalization.getText(ref, 'sunday')),
              value: false,
              groupValue: appConfig.weekStartsOnMonday,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(context);
                  ref
                      .read(appConfigProvider.notifier)
                      .updateWeekStartsOnMonday(value);
                }
              },
              selected: appConfig.weekStartsOnMonday == false,
            ),
          ],
        ),
      ),
    );
  }
}

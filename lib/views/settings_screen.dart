import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../providers/settings_provider.dart';
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
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/premium_service.dart';
import '../services/purchase_helper.dart';

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
      padding: EdgeInsets.only(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
        bottom:
            AppConstants.defaultPadding + MediaQuery.of(context).padding.bottom,
      ),
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
            HugeIconsStrokeRounded.databaseRestore,
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
          ],
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Sección de FAQ
        _buildSection(context, SimpleLocalization.getText(ref, 'faq'), [
          _buildListTile(
            context,
            ref,
            SimpleLocalization.getText(ref, 'faq'),
            SimpleLocalization.getText(ref, 'faqDescription'),
            HugeIconsStrokeRounded.helpCircle,
            () => _showFaqDialog(context, ref),
          ),
        ]),

        const SizedBox(height: AppConstants.defaultPadding),

        // Sección de Soporte
        _buildSection(context, SimpleLocalization.getText(ref, 'support'), [
          _buildListTile(
            context,
            ref,
            SimpleLocalization.getText(ref, 'contactSupport'),
            SimpleLocalization.getText(ref, 'contactSupportDescription'),
            HugeIconsStrokeRounded.mail01,
            () => _showSupportDialog(context, ref),
          ),
          _buildListTile(
            context,
            ref,
            SimpleLocalization.getText(ref, 'appVersion'),
            AppConstants.appVersion,
            HugeIconsStrokeRounded.helpCircle,
            () {},
          ),
        ]),

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
              onChanged: (value) async {
                if (value != null) {
                  await ref
                      .read(appConfigProvider.notifier)
                      .updateSubscriptionReminderDays(value);

                  // Reprogramar todos los recordatorios con la nueva configuración
                  final subscriptions = ref.read(subscriptionsProvider);
                  await TimerService.scheduleAllSubscriptionReminders(
                    subscriptions,
                  );

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
            : [
                TextButton(
                  onPressed: () async {
                    await ref.read(premiumServiceProvider).restorePurchases();
                  },
                  child: Text(SimpleLocalization.getText(ref, 'restore')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(SimpleLocalization.getText(ref, 'close')),
                ),
              ],
      ),
    );
  }

  Widget _buildPremiumPurchaseOptions(BuildContext context, WidgetRef ref) {
    return StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder<ProductDetailsResponse>(
          future: ref.read(premiumServiceProvider).getProducts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // Mostrar error si hay alguno
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar productos: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verifica que las suscripciones estén activas en Play Console',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final loading = !snapshot.hasData;
            final response = snapshot.data;
            final products = response?.productDetails ?? [];
            final notFoundIds = response?.notFoundIDs ?? [];

            String priceFor(String id, String fallback) {
              final found = products.where((p) => p.id == id).toList();
              return found.isNotEmpty ? found.first.price : fallback;
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SimpleLocalization.getText(ref, 'selectPlan'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (loading) const Center(child: CircularProgressIndicator()),
                if (!loading && products.isEmpty) ...[
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron productos',
                    style: TextStyle(color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (notFoundIds.isNotEmpty)
                    Text(
                      'IDs no encontrados: ${notFoundIds.join(", ")}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Asegúrate de que las suscripciones estén activas y publicadas en Play Console',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (!loading && products.isNotEmpty) ...[
                  _buildPurchaseOption(
                    context: context,
                    ref: ref,
                    title: SimpleLocalization.getText(ref, 'monthly'),
                    price: priceFor(PremiumProducts.monthlyPlan, '\u2014'),
                    isBestValue: false,
                    onTap: () => _processPurchase(context, ref, 'monthly'),
                  ),
                  const SizedBox(height: 12),
                  _buildPurchaseOption(
                    context: context,
                    ref: ref,
                    title: SimpleLocalization.getText(ref, 'yearly'),
                    price: priceFor(PremiumProducts.yearlyPlan, '\u2014'),
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
                  Text(
                    '• ${SimpleLocalization.getText(ref, 'prioritySupport')}',
                  ),
                  Text(
                    '• ${SimpleLocalization.getText(ref, 'unlimitedAccounts')}',
                  ),
                ],
              ],
            );
          },
        );
      },
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

  /// Procesa la compra real
  Future<void> _processPurchase(
    BuildContext context,
    WidgetRef ref,
    String plan,
  ) async {
    final productsResponse = await ref
        .read(premiumServiceProvider)
        .getProducts();
    final products = productsResponse.productDetails;
    final id = plan == 'monthly'
        ? PremiumProducts.monthlyPlan
        : PremiumProducts.yearlyPlan;
    final product = products.firstWhere(
      (p) => p.id == id,
      orElse: () =>
          products.isNotEmpty ? products.first : throw 'Producto no encontrado',
    );

    await ref.read(premiumServiceProvider).purchaseProduct(product);
    // Escuchar una vez la actualización de compra y procesarla
    late StreamSubscription<List<PurchaseDetails>> sub;
    sub = ref.read(premiumServiceProvider).purchaseUpdates.listen((
      updates,
    ) async {
      for (final purchase in updates) {
        await PurchaseHelper.processPurchase(purchase, ref);
      }
      await sub.cancel();
    });
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

  void _showFaqDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isEnglish = ref.read(appConfigProvider).language == 'en';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIconsStrokeRounded.helpCircle,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        SimpleLocalization.getText(ref, 'faq'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFaqItem(
                        context,
                        ref,
                        isEnglish
                            ? 'How do I add a transaction?'
                            : '¿Cómo agrego una transacción?',
                        isEnglish
                            ? 'Tap the + button on the dashboard screen to add a new transaction. Select the type (income or expense), enter the amount, choose a category, and save.'
                            : 'Toca el botón + en la pantalla de inicio para agregar una nueva transacción. Selecciona el tipo (ingreso o gasto), ingresa el monto, elige una categoría y guarda.',
                      ),
                      const SizedBox(height: 5),
                      _buildFaqItem(
                        context,
                        ref,
                        isEnglish
                            ? 'How do I manage categories?'
                            : '¿Cómo gestiono las categorías?',
                        isEnglish
                            ? 'Go to Settings > Management > Manage Categories. You can create, edit, and delete custom categories. Default categories can be restored at any time.'
                            : 'Ve a Configuración > Gestión > Gestionar Categorías. Puedes crear, editar y eliminar categorías personalizadas. Las categorías por defecto se pueden restaurar en cualquier momento.',
                      ),
                      const SizedBox(height: 5),
                      _buildFaqItem(
                        context,
                        ref,
                        isEnglish
                            ? 'How do subscriptions work?'
                            : '¿Cómo funcionan las suscripciones?',
                        isEnglish
                            ? 'Subscriptions allow you to track recurring payments. Set the frequency, amount, and next payment date. You\'ll receive reminders before the payment is due.'
                            : 'Las suscripciones te permiten rastrear pagos recurrentes. Establece la frecuencia, el monto y la fecha del próximo pago. Recibirás recordatorios antes de que venza el pago.',
                      ),
                      const SizedBox(height: 5),
                      _buildFaqItem(
                        context,
                        ref,
                        isEnglish
                            ? 'What is the premium version?'
                            : '¿Qué es la versión premium?',
                        isEnglish
                            ? 'The premium version removes ads, provides priority support, and allows unlimited accounts. You can purchase it monthly or annually with a discount.'
                            : 'La versión premium elimina los anuncios, proporciona soporte prioritario y permite cuentas ilimitadas. Puedes comprarla mensualmente o anualmente con descuento.',
                      ),

                      const SizedBox(height: 5),
                      _buildFaqItem(
                        context,
                        ref,
                        isEnglish
                            ? 'How do I set a monthly expense limit?'
                            : '¿Cómo establezco un límite de gastos mensual?',
                        isEnglish
                            ? 'Go to Settings > Financial Settings > Monthly Expense Limit. Enter your desired limit, and the app will track your spending against it.'
                            : 'Ve a Configuración > Configuración Financiera > Límite de Gastos Mensual. Ingresa tu límite deseado y la app rastreará tus gastos comparándolos con él.',
                      ),
                      const SizedBox(height: 5),
                      _buildFaqItem(
                        context,
                        ref,
                        isEnglish
                            ? 'Can I use multiple accounts?'
                            : '¿Puedo usar múltiples cuentas?',
                        isEnglish
                            ? 'Yes! You can create and switch between multiple accounts. Each account has its own transactions, subscriptions, and balance. Premium users can have unlimited accounts.'
                            : '¡Sí! Puedes crear y cambiar entre múltiples cuentas. Cada cuenta tiene sus propias transacciones, suscripciones y balance. Los usuarios premium pueden tener cuentas ilimitadas.',
                      ),
                      const SizedBox(height: 5),
                      _buildFaqItem(
                        context,
                        ref,
                        isEnglish
                            ? 'How do notifications work?'
                            : '¿Cómo funcionan las notificaciones?',
                        isEnglish
                            ? 'Enable notifications in Settings > Notifications. You\'ll receive reminders for subscription payments before they\'re due. You can configure how many days in advance you want to be notified.'
                            : 'Habilita las notificaciones en Configuración > Notificaciones. Recibirás recordatorios para los pagos de suscripciones antes de que venzan. Puedes configurar con cuántos días de anticipación quieres ser notificado.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context,
    WidgetRef ref,
    String question,
    String answer,
  ) {
    final theme = Theme.of(context);
    return Card(
      child: ExpansionTile(
        title: Text(
          question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isEnglish = ref.read(appConfigProvider).language == 'en';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
            maxWidth: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header mejorado con gradiente
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.borderRadius),
                    topRight: Radius.circular(AppConstants.borderRadius),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(
                        icon: HugeIconsStrokeRounded.mail01,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            SimpleLocalization.getText(ref, 'support'),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            SimpleLocalization.getText(ref, 'supportSubtitle'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email de soporte - Tarjeta mejorada
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(
                            0.3,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: HugeIcon(
                                icon: HugeIconsStrokeRounded.mail01,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    SimpleLocalization.getText(
                                      ref,
                                      'supportEmail',
                                    ),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'soporte@cuidatuplata.com',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.copy,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () async {
                                await Clipboard.setData(
                                  const ClipboardData(
                                    text: 'soporte@cuidatuplata.com',
                                  ),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        SimpleLocalization.getText(
                                          ref,
                                          'emailCopied',
                                        ),
                                      ),
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Botón para enviar email mejorado
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final email = 'soporte@cuidatuplata.com';
                              final subject = isEnglish
                                  ? 'Support Request - CuidaTuPlata'
                                  : 'Solicitud de Soporte - CuidaTuPlata';
                              final body = isEnglish
                                  ? 'Hello,\n\nI need help with:\n\n\n\nApp Version: ${AppConstants.appVersion}'
                                  : 'Hola,\n\nNecesito ayuda con:\n\n\n\nVersión de la App: ${AppConstants.appVersion}';

                              await Clipboard.setData(
                                ClipboardData(
                                  text:
                                      'Email: $email\nSubject: $subject\n\n$body',
                                ),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEnglish
                                          ? 'Email information copied. Please paste it in your email client.'
                                          : 'Información del email copiada. Por favor pégalo en tu cliente de email.',
                                    ),
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  HugeIcon(
                                    icon: HugeIconsStrokeRounded.mail01,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    SimpleLocalization.getText(
                                      ref,
                                      'sendEmail',
                                    ),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Información de respuesta
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: HugeIcon(
                                icon: HugeIconsStrokeRounded.clock01,
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
                                    SimpleLocalization.getText(
                                      ref,
                                      'supportInfo',
                                    ),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isEnglish
                                        ? 'We typically respond within 24-48 hours. For urgent matters, please mention "URGENT" in the subject line.'
                                        : 'Normalmente respondemos en 24-48 horas. Para asuntos urgentes, por favor menciona "URGENTE" en el asunto.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Información de la app mejorada
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIconsStrokeRounded.helpCircle,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  SimpleLocalization.getText(ref, 'appInfo'),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              theme,
                              SimpleLocalization.getText(ref, 'appName'),
                              AppConstants.appVersion,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              theme,
                              SimpleLocalization.getText(ref, 'platform'),
                              Theme.of(
                                context,
                              ).platform.toString().split('.').last,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

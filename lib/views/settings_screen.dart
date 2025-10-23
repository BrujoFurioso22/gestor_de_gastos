import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../providers/settings_provider.dart';
import '../providers/admob_provider.dart';
import '../providers/app_config_provider.dart';
import '../services/simple_localization.dart';
import '../constants/app_constants.dart';
import 'categories_screen.dart';
import 'manage_subscriptions_screen.dart';
import '../services/hive_service.dart';
import '../providers/category_provider.dart';

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
          ],
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Sección de Gestión
        _buildSection(context, 'Gestión', [
          _buildListTile(
            context,
            ref,
            SimpleLocalization.getText(ref, 'manageCategories'),
            'Crear y editar categorías personalizadas',
            HugeIconsStrokeRounded.tag01,
            () => _navigateToCategories(context),
          ),
          _buildListTile(
            context,
            ref,
            SimpleLocalization.getText(ref, 'manageSubscriptions'),
            'Gestionar suscripciones y pagos habituales',
            HugeIconsStrokeRounded.refresh,
            () => _navigateToSubscriptions(context),
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
              SimpleLocalization.getText(ref, 'downloadPdfOrExcel'),
              HugeIconsStrokeRounded.download01,
              () => _showExportDataDialog(context, ref),
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
            _buildDropdownTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'subscriptionReminders'),
              '${appConfig.subscriptionReminderDays} ${SimpleLocalization.getText(ref, 'daysBefore')}',
              HugeIconsStrokeRounded.notification01,
              () => _showReminderDaysDialog(context, ref),
            ),
            _buildSwitchTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'expenseNotifications'),
              appConfig.expenseNotifications,
              HugeIconsStrokeRounded.alert01,
              (value) => ref
                  .read(appConfigProvider.notifier)
                  .updateExpenseNotifications(value),
            ),
            _buildSwitchTile(
              context,
              ref,
              SimpleLocalization.getText(ref, 'weeklySummary'),
              appConfig.weeklySummary,
              HugeIconsStrokeRounded.analytics01,
              (value) => ref
                  .read(appConfigProvider.notifier)
                  .updateWeeklySummary(value),
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
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).updateLanguage(value);
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
                '$day ${day == 1 ? SimpleLocalization.getText(ref, 'day') : SimpleLocalization.getText(ref, 'days')} ${SimpleLocalization.getText(ref, 'daysBefore')}',
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
                    content: Text('Categorías actualizadas con nuevos iconos'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text('Actualizar Iconos'),
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    SimpleLocalization.getText(ref, 'exportingToPdf'),
                  ),
                ),
              );
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    SimpleLocalization.getText(ref, 'exportingToExcel'),
                  ),
                ),
              );
            },
            child: const Text('Excel'),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SimpleLocalization.getText(ref, 'premiumVersion')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(SimpleLocalization.getText(ref, 'unlockPremiumFeatures')),
            const SizedBox(height: 8),
            Text(SimpleLocalization.getText(ref, 'noAds')),
            Text(SimpleLocalization.getText(ref, 'advancedExport')),
            Text(SimpleLocalization.getText(ref, 'customThemes')),
            Text(SimpleLocalization.getText(ref, 'cloudBackup')),
            Text(SimpleLocalization.getText(ref, 'prioritySupport')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(SimpleLocalization.getText(ref, 'close')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    SimpleLocalization.getText(ref, 'functionInDevelopment'),
                  ),
                ),
              );
            },
            child: Text(SimpleLocalization.getText(ref, 'upgrade')),
          ),
        ],
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
            onPressed: () {
              ref.read(appConfigProvider.notifier).resetToDefaults();
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

  void _navigateToSubscriptions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManageSubscriptionsScreen(),
      ),
    );
  }
}

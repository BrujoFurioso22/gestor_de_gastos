import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class AppTheme {
  /// Colores del tema
  static const Color _primaryColor = Color(0xFF6750A4);

  /// Tema claro
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme, Brightness.light),
      appBarTheme: _buildAppBarTheme(colorScheme),
      cardTheme: _buildCardTheme(colorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(colorScheme),
      floatingActionButtonTheme: _buildFloatingActionButtonTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme),
      dividerTheme: _buildDividerTheme(colorScheme),
      listTileTheme: _buildListTileTheme(colorScheme),
      switchTheme: _buildSwitchTheme(colorScheme),
      checkboxTheme: _buildCheckboxTheme(colorScheme),
      radioTheme: _buildRadioTheme(colorScheme),
      sliderTheme: _buildSliderTheme(colorScheme),
      progressIndicatorTheme: _buildProgressIndicatorTheme(colorScheme),
      dialogTheme: _buildDialogTheme(colorScheme),
      snackBarTheme: _buildSnackBarTheme(colorScheme),
      bottomSheetTheme: _buildBottomSheetTheme(colorScheme),
      drawerTheme: _buildDrawerTheme(colorScheme),
      tabBarTheme: _buildTabBarTheme(colorScheme),
      dataTableTheme: _buildDataTableTheme(colorScheme),
      expansionTileTheme: _buildExpansionTileTheme(colorScheme),
      popupMenuTheme: _buildPopupMenuTheme(colorScheme),
      tooltipTheme: _buildTooltipTheme(colorScheme),
      badgeTheme: _buildBadgeTheme(colorScheme),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme),
      navigationRailTheme: _buildNavigationRailTheme(colorScheme),
    );
  }

  /// Tema oscuro
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme, Brightness.dark),
      appBarTheme: _buildAppBarTheme(colorScheme),
      cardTheme: _buildCardTheme(colorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(colorScheme),
      floatingActionButtonTheme: _buildFloatingActionButtonTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme),
      dividerTheme: _buildDividerTheme(colorScheme),
      listTileTheme: _buildListTileTheme(colorScheme),
      switchTheme: _buildSwitchTheme(colorScheme),
      checkboxTheme: _buildCheckboxTheme(colorScheme),
      radioTheme: _buildRadioTheme(colorScheme),
      sliderTheme: _buildSliderTheme(colorScheme),
      progressIndicatorTheme: _buildProgressIndicatorTheme(colorScheme),
      dialogTheme: _buildDialogTheme(colorScheme),
      snackBarTheme: _buildSnackBarTheme(colorScheme),
      bottomSheetTheme: _buildBottomSheetTheme(colorScheme),
      drawerTheme: _buildDrawerTheme(colorScheme),
      tabBarTheme: _buildTabBarTheme(colorScheme),
      dataTableTheme: _buildDataTableTheme(colorScheme),
      expansionTileTheme: _buildExpansionTileTheme(colorScheme),
      popupMenuTheme: _buildPopupMenuTheme(colorScheme),
      tooltipTheme: _buildTooltipTheme(colorScheme),
      badgeTheme: _buildBadgeTheme(colorScheme),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme),
      navigationRailTheme: _buildNavigationRailTheme(colorScheme),
    );
  }

  /// Construye el tema de texto
  static TextTheme _buildTextTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// Construye el tema del AppBar
  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );
  }

  /// Construye el tema de las tarjetas
  static CardThemeData _buildCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      margin: const EdgeInsets.all(AppConstants.smallPadding),
    );
  }

  /// Construye el tema de los botones elevados
  static ElevatedButtonThemeData _buildElevatedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Construye el tema de los botones con borde
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Construye el tema de los botones de texto
  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: AppConstants.smallPadding,
        ),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Construye el tema de los campos de entrada
  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      labelStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
      hintStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
    );
  }

  /// Construye el tema de la barra de navegación inferior
  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme(
    ColorScheme colorScheme,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400),
    );
  }

  /// Construye el tema del botón flotante
  static FloatingActionButtonThemeData _buildFloatingActionButtonTheme(
    ColorScheme colorScheme,
  ) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
    );
  }

  /// Construye el tema de los chips
  static ChipThemeData _buildChipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceVariant,
      labelStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
    );
  }

  /// Construye el tema de los divisores
  static DividerThemeData _buildDividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outline.withOpacity(0.3),
      thickness: 1,
      space: 1,
    );
  }

  /// Construye el tema de los elementos de lista
  static ListTileThemeData _buildListTileTheme(ColorScheme colorScheme) {
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      titleTextStyle: GoogleFonts.inter(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
    );
  }

  /// Construye el tema de los switches
  static SwitchThemeData _buildSwitchTheme(ColorScheme colorScheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary.withOpacity(0.5);
        }
        return colorScheme.surfaceVariant;
      }),
    );
  }

  /// Construye el tema de los checkboxes
  static CheckboxThemeData _buildCheckboxTheme(ColorScheme colorScheme) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
      side: BorderSide(color: colorScheme.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  /// Construye el tema de los radio buttons
  static RadioThemeData _buildRadioTheme(ColorScheme colorScheme) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.outline;
      }),
    );
  }

  /// Construye el tema de los sliders
  static SliderThemeData _buildSliderTheme(ColorScheme colorScheme) {
    return SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.surfaceVariant,
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withOpacity(0.1),
    );
  }

  /// Construye el tema de los indicadores de progreso
  static ProgressIndicatorThemeData _buildProgressIndicatorTheme(
    ColorScheme colorScheme,
  ) {
    return ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.surfaceVariant,
      circularTrackColor: colorScheme.surfaceVariant,
    );
  }

  /// Construye el tema de los diálogos
  static DialogThemeData _buildDialogTheme(ColorScheme colorScheme) {
    return DialogThemeData(
      backgroundColor: colorScheme.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      titleTextStyle: GoogleFonts.inter(
        color: colorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: GoogleFonts.inter(color: colorScheme.onSurface),
    );
  }

  /// Construye el tema de las snack bars
  static SnackBarThemeData _buildSnackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: GoogleFonts.inter(color: colorScheme.onInverseSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  /// Construye el tema de los bottom sheets
  static BottomSheetThemeData _buildBottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }

  /// Construye el tema de los drawers
  static DrawerThemeData _buildDrawerTheme(ColorScheme colorScheme) {
    return DrawerThemeData(
      backgroundColor: colorScheme.surface,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }

  /// Construye el tema de las pestañas
  static TabBarThemeData _buildTabBarTheme(ColorScheme colorScheme) {
    return TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400),
    );
  }

  /// Construye el tema de las tablas de datos
  static DataTableThemeData _buildDataTableTheme(ColorScheme colorScheme) {
    return DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(
        colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      dataRowColor: WidgetStateProperty.all(colorScheme.surface),
      headingTextStyle: GoogleFonts.inter(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: GoogleFonts.inter(color: colorScheme.onSurface),
      dividerThickness: 1,
      horizontalMargin: AppConstants.defaultPadding,
    );
  }

  /// Construye el tema de los expansion tiles
  static ExpansionTileThemeData _buildExpansionTileTheme(
    ColorScheme colorScheme,
  ) {
    return ExpansionTileThemeData(
      backgroundColor: colorScheme.surface,
      collapsedBackgroundColor: colorScheme.surface,
      textColor: colorScheme.onSurface,
      collapsedTextColor: colorScheme.onSurface,
      iconColor: colorScheme.primary,
      collapsedIconColor: colorScheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
    );
  }

  /// Construye el tema de los menús emergentes
  static PopupMenuThemeData _buildPopupMenuTheme(ColorScheme colorScheme) {
    return PopupMenuThemeData(
      color: colorScheme.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      textStyle: GoogleFonts.inter(color: colorScheme.onSurface),
    );
  }

  /// Construye el tema de los tooltips
  static TooltipThemeData _buildTooltipTheme(ColorScheme colorScheme) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      textStyle: GoogleFonts.inter(color: colorScheme.onInverseSurface),
    );
  }

  /// Construye el tema de las insignias
  static BadgeThemeData _buildBadgeTheme(ColorScheme colorScheme) {
    return BadgeThemeData(
      backgroundColor: colorScheme.error,
      textColor: colorScheme.onError,
      textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
    );
  }

  /// Construye el tema de la barra de navegación
  static NavigationBarThemeData _buildNavigationBarTheme(
    ColorScheme colorScheme,
  ) {
    return NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primary.withOpacity(0.1),
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Construye el tema del rail de navegación
  static NavigationRailThemeData _buildNavigationRailTheme(
    ColorScheme colorScheme,
  ) {
    return NavigationRailThemeData(
      backgroundColor: colorScheme.surface,
      selectedIconTheme: IconThemeData(color: colorScheme.primary),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      selectedLabelTextStyle: GoogleFonts.inter(
        color: colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelTextStyle: GoogleFonts.inter(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../constants/app_constants.dart';
import '../../services/simple_localization.dart';

class ColorSelectorPage extends ConsumerStatefulWidget {
  final String selectedColor;

  const ColorSelectorPage({super.key, required this.selectedColor});

  @override
  ConsumerState<ColorSelectorPage> createState() => _ColorSelectorPageState();
}

class _ColorSelectorPageState extends ConsumerState<ColorSelectorPage> {
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
  }

  /// Determinar el color de contraste para el icono de check
  Color _getContrastColor(Color color) {
    // Calcular el brillo relativo del color
    final brightness =
        (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114).round();
    // Si el color es claro, usar negro, si es oscuro, usar blanco
    return brightness > 128 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [
      // Rojos y rosas - Pasteles
      '#FFEBEE', '#FCE4EC', '#F8BBD9', '#F5B6C1', '#FFCDD2',
      '#FFB3BA', '#FFCCCB', '#FFB6C1', '#FFA0B5', '#FF8FA3',
      // Rojos - Medios
      '#EF9A9A', '#E57373', '#EF5350', '#F44336', '#E53935',
      '#D32F2F', '#C62828', '#B71C1C', '#A00E0E', '#8B0000',

      // Púrpuras y violetas - Pasteles
      '#F3E5F5', '#E1BEE7', '#D1C4E9', '#C5CAE9', '#B39DDB',
      '#CE93D8', '#BA68C8', '#AB47BC', '#9C27B0', '#8E24AA',
      // Púrpuras - Medios
      '#9575CD', '#7E57C2', '#673AB7', '#5E35B1', '#512DA8',
      '#4527A0', '#311B92', '#1A237E', '#000051',

      // Azules - Pasteles
      '#E3F2FD', '#BBDEFB', '#B3E5FC', '#90CAF9', '#81D4FA',
      '#64B5F6', '#4FC3F7', '#42A5F5', '#29B6F6', '#1E88E5',
      // Azules - Medios
      '#2196F3', '#1976D2', '#1565C0', '#0D47A1', '#0277BD',
      '#01579B', '#014377', '#004D40', '#006064', '#00838F',
      // Azules - Oscuros adicionales
      '#002171', '#001970', '#000051',

      // Verdes - Pasteles
      '#E8F5E9', '#C8E6C9', '#DCEDC8', '#C5E1A5', '#AED581',
      '#9CCC65', '#8BC34A', '#7CB342', '#689F38', '#558B2F',
      // Verdes - Medios
      '#66BB6A', '#4CAF50', '#43A047', '#388E3C', '#2E7D32',
      '#1B5E20', '#33691E', '#0D4F00',
      // Verdes - Esmeralda y turquesa
      '#B2DFDB', '#80CBC4', '#4DB6AC', '#26A69A', '#00897B',
      '#00796B', '#00695C',

      // Amarillos y naranjas - Pasteles
      '#FFF9C4', '#FFF59D', '#FFF176', '#FFEE58',
      '#FFEB3B', '#FDD835', '#FBC02D', '#F9A825', '#F57F17',
      // Naranjas - Pasteles y medios
      '#FFF3E0', '#FFE0B2', '#FFCC80', '#FFB74D', '#FFA726',
      '#FF9800', '#FB8C00', '#F57C00', '#EF6C00', '#E65100',
      // Naranjas - Oscuros
      '#FF6F00', '#BF360C', '#D84315', '#FF5722',

      // Marrones y beige - Pasteles
      '#EFEBE9', '#D7CCC8', '#BCAAA4', '#A1887F', '#8D6E63',
      '#795548', '#6D4C41', '#5D4037', '#4E342E', '#3E2723',
      // Beige y crema
      '#F5F5DC', '#FFF8DC', '#FAEBD7', '#FFEFD5', '#FDF5E6',
      '#FFFACD', '#FFFFE0', '#F0E68C', '#E6E6FA',

      // Grises
      '#FAFAFA', '#F5F5F5', '#EEEEEE', '#E0E0E0', '#BDBDBD',
      '#9E9E9E', '#757575', '#616161', '#424242', '#212121',
      // Grises azulados
      '#ECEFF1', '#CFD8DC', '#B0BEC5', '#90A4AE', '#78909C',
      '#607D8B', '#546E7A', '#455A64', '#37474F', '#263238',

      // Cian y turquesa
      '#E0F7FA', '#B2EBF2', '#80DEEA', '#4DD0E1', '#26C6DA',
      '#00BCD4', '#00ACC1', '#0097A7',

      // Rosa y magenta
      '#F48FB1', '#F06292', '#EC407A',
      '#E91E63', '#D81B60', '#C2185B', '#AD1457', '#880E4F',

      // Índigo
      '#E8EAF6', '#9FA8DA', '#7986CB', '#5C6BC0',
      '#3F51B5', '#3949AB', '#303F9F', '#283593',

      // Lima y verde lima
      '#F9FBE7', '#F0F4C3', '#E6EE9C', '#DCE775', '#D4E157',
      '#CDDC39', '#C0CA33', '#AFB42B', '#9E9D24', '#827717',

      // Ámbar
      '#FFF8E1', '#FFECB3', '#FFE082', '#FFD54F', '#FFCA28',
      '#FFC107', '#FFB300', '#FFA000', '#FF8F00',

      // Teal (verde azulado)
      '#E0F2F1', '#80CBC4', '#4DB6AC', '#26A69A',
      '#009688', '#00897B', '#00796B',

      // Deep Purple (morado oscuro)
      '#EDE7F6', '#B39DDB', '#9575CD', '#7E57C2',
      '#673AB7', '#5E35B1', '#512DA8', '#4527A0',

      // Light Blue (azul claro)
      '#E1F5FE', '#B3E5FC', '#81D4FA', '#4FC3F7', '#29B6F6',
      '#03A9F4', '#0288D1', '#013243',

      // Deep Orange (naranja oscuro)
      '#FBE9E7', '#FFCCBC', '#FFAB91', '#FF8A65', '#FF7043',
      '#FF5722', '#F4511E', '#E64A19', '#D84315',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(SimpleLocalization.getText(ref, 'selectColor')),
        leading: IconButton(
          icon: const HugeIcon(icon: HugeIconsStrokeRounded.arrowLeft01),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const itemSize = 50.0;
          const spacing = 12.0;
          // Calcular el número de columnas, asegurando mínimo 5 y máximo 6
          final calculatedCount =
              ((constraints.maxWidth -
                          (AppConstants.defaultPadding * 2) +
                          spacing) /
                      (itemSize + spacing))
                  .floor();
          final crossAxisCount = calculatedCount.clamp(5, 6);

          return GridView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 1,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              final colorValue = Color(
                int.parse(color.replaceFirst('#', '0xFF')),
              );
              final isSelected = _selectedColor == color;

              return InkWell(
                onTap: () {
                  // Seleccionar y volver automáticamente
                  Navigator.pop(context, color);
                },
                borderRadius: BorderRadius.circular(50),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: colorValue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 3.5 : 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: isSelected
                      ? Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.tick01,
                            color: _getContrastColor(colorValue),
                            size: 28,
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

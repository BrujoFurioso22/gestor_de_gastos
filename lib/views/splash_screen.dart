import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_config_provider.dart';
import '../providers/settings_provider.dart';
import 'main_navigation.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animación de respiración
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Iniciar animación de respiración infinita
    _breathingController.repeat(reverse: true);

    // Simular tiempo de carga y navegar a la app principal
    _navigateToMainApp();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  Future<void> _navigateToMainApp() async {
    // Simular tiempo de inicialización (3 segundos)
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Inicializar la configuración de la app
      ref.read(appConfigProvider.notifier).initializeConfig();

      // Navegar a la pantalla principal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo con animación de respiración
            AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breathingAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        'assets/images/CuidaTuPlataIcon.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Nombre de la app
            Text(
              'CuidaTuPlata',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            // Subtítulo
            Text(
              'Controla tus gastos',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),

            const SizedBox(height: 50),

            // Indicador de carga
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode
                      ? const Color(0xFF6750A4)
                      : const Color(0xFF6750A4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

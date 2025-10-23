import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_config_provider.dart';

class FeedbackService {
  /// Proporciona feedback háptico si está habilitado
  static void hapticFeedback(WidgetRef ref, HapticFeedbackType type) {
    final appConfig = ref.read(appConfigProvider);

    if (!appConfig.vibration) return;

    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.success:
        // Combinación de vibraciones para éxito
        HapticFeedback.lightImpact();
        Future.delayed(const Duration(milliseconds: 50), () {
          HapticFeedback.lightImpact();
        });
        break;
      case HapticFeedbackType.error:
        // Vibración más fuerte para error
        HapticFeedback.heavyImpact();
        break;
    }
  }

  /// Proporciona feedback de sonido si está habilitado
  static void soundFeedback(WidgetRef ref, SoundFeedbackType type) {
    final appConfig = ref.read(appConfigProvider);

    if (!appConfig.sound) return;

    switch (type) {
      case SoundFeedbackType.click:
        SystemSound.play(SystemSoundType.click);
        break;
      case SoundFeedbackType.alert:
        SystemSound.play(SystemSoundType.alert);
        break;
      case SoundFeedbackType.success:
        // Para éxito, podríamos usar un sonido personalizado
        // Por ahora usamos el sonido del sistema
        SystemSound.play(SystemSoundType.click);
        break;
      case SoundFeedbackType.error:
        SystemSound.play(SystemSoundType.alert);
        break;
    }
  }

  /// Proporciona feedback combinado (háptico + sonido)
  static void combinedFeedback(
    WidgetRef ref,
    HapticFeedbackType hapticType,
    SoundFeedbackType soundType,
  ) {
    hapticFeedback(ref, hapticType);
    soundFeedback(ref, soundType);
  }

  /// Feedback para acciones exitosas
  static void successFeedback(WidgetRef ref) {
    combinedFeedback(
      ref,
      HapticFeedbackType.success,
      SoundFeedbackType.success,
    );
  }

  /// Feedback para errores
  static void errorFeedback(WidgetRef ref) {
    combinedFeedback(ref, HapticFeedbackType.error, SoundFeedbackType.error);
  }

  /// Feedback para selecciones
  static void selectionFeedback(WidgetRef ref) {
    combinedFeedback(
      ref,
      HapticFeedbackType.selection,
      SoundFeedbackType.click,
    );
  }

  /// Feedback para botones
  static void buttonFeedback(WidgetRef ref) {
    combinedFeedback(ref, HapticFeedbackType.light, SoundFeedbackType.click);
  }
}

enum HapticFeedbackType { light, medium, heavy, selection, success, error }

enum SoundFeedbackType { click, alert, success, error }

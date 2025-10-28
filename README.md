# CuidaTuPlata - Gestor de Gastos

Una aplicación Flutter moderna para controlar ingresos y gastos de manera simple y visual.

## 🚀 Características

- **Dashboard intuitivo** con balance total y gráficos
- **Gestión de transacciones** con categorías predefinidas
- **Historial completo** con filtros y búsqueda
- **Tema claro/oscuro** con Material 3
- **Persistencia local** con Hive
- **Monetización** con AdMob
- **Arquitectura limpia** con Riverpod

## 📱 Pantallas

### 1. Dashboard

- Balance total (ingresos - gastos)
- Gráfico circular de distribución
- Transacciones recientes
- Botón flotante para agregar transacciones

### 2. Historial

- Lista completa de transacciones
- Filtros por tipo y categoría
- Búsqueda por texto
- Opciones de edición y eliminación

### 3. Configuración

- Toggle de tema claro/oscuro
- Configuración de anuncios
- Opciones de exportación/importación
- Información de la app

## 🛠️ Tecnologías

- **Flutter** 3.9.2+
- **Riverpod** para manejo de estado
- **Hive** para persistencia local
- **AdMob** para monetización
- **Material 3** para diseño
- **Google Fonts** para tipografía
- **FL Chart** para gráficos

## 📦 Instalación

### Prerrequisitos

- Flutter SDK 3.9.2 o superior
- Dart SDK 3.0.0 o superior
- Android Studio / VS Code
- Android SDK (para Android)
- Xcode (para iOS)

### Pasos de instalación

1. **Clona el repositorio**

   ```bash
   git clone <url-del-repositorio>
   cd mi_control
   ```

2. **Instala las dependencias**

   ```bash
   flutter pub get
   ```

3. **Genera los archivos de Hive**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configura AdMob** (opcional)

   - Crea una cuenta en [AdMob](https://admob.google.com/)
   - Obtén tu App ID y Unit IDs
   - Reemplaza los IDs de prueba en `lib/constants/app_constants.dart`

5. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

## 🔧 Configuración de AdMob

### 1. Crear cuenta de AdMob

1. Ve a [AdMob Console](https://admob.google.com/)
2. Crea una cuenta o inicia sesión
3. Crea una nueva aplicación
4. Obtén el App ID

### 2. Configurar IDs de anuncios

Edita `lib/constants/app_constants.dart`:

```dart
class AppConstants {
  // Reemplaza con tus IDs reales
  static const String adMobAppId = 'ca-app-pub-XXXXXXXX~XXXXXXXX';
  static const String adMobBannerId = 'ca-app-pub-XXXXXXXX/XXXXXXXX';
  static const String adMobInterstitialId = 'ca-app-pub-XXXXXXXX/XXXXXXXX';
}
```

### 3. Configurar Android

Edita `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
  <meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXX~XXXXXXXX"/>
</application>
```

### 4. Configurar iOS

Edita `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXX~XXXXXXXX</string>
```

## 🏗️ Estructura del proyecto

```
lib/
├── constants/          # Constantes de la aplicación
├── models/            # Modelos de datos (Hive)
├── providers/         # Providers de Riverpod
├── services/          # Servicios (Hive, AdMob)
├── utils/             # Utilidades (formatters, colores)
├── views/             # Pantallas de la aplicación
├── widgets/           # Widgets reutilizables
└── main.dart          # Punto de entrada
```

## 🎨 Personalización

### Temas

Los temas se definen en `lib/utils/theme.dart`. Puedes personalizar:

- Colores principales
- Tipografías
- Espaciados
- Bordes redondeados

### Categorías

Las categorías predefinidas están en `lib/models/category.dart`. Puedes:

- Agregar nuevas categorías
- Modificar colores e iconos
- Cambiar nombres

### Configuración

Las constantes de la app están en `lib/constants/app_constants.dart`:

- IDs de AdMob
- Configuración de anuncios
- Límites de la aplicación
- Colores del tema

## 📊 Funcionalidades

### Gestión de Transacciones

- **Agregar**: Título, monto, categoría, fecha, notas
- **Editar**: Modificar cualquier campo
- **Eliminar**: Con confirmación
- **Filtrar**: Por tipo, categoría, fecha
- **Buscar**: Por título o notas

### Categorías

- **Predefinidas**: 8 categorías de gastos, 4 de ingresos
- **Personalizables**: Colores e iconos únicos
- **Estadísticas**: Monto total por categoría

### Persistencia

- **Hive**: Base de datos local rápida
- **Cifrado**: Datos seguros en el dispositivo
- **Sincronización**: Preparado para futuras versiones

## 🚀 Compilación

### Android

```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release

# App Bundle (recomendado para Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

## 📱 Compatibilidad

- **Android**: 8.0+ (API 26+)
- **iOS**: 11.0+
- **Flutter**: 3.9.2+

## 🔒 Privacidad

- Los datos se almacenan localmente en el dispositivo
- No se recopila información personal
- Los anuncios son proporcionados por AdMob (Google)
- No se comparten datos con terceros

## 🐛 Solución de problemas

### Error de Hive

Si encuentras errores relacionados con Hive:

```bash
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Error de AdMob

Si los anuncios no se muestran:

1. Verifica que los IDs sean correctos
2. Asegúrate de que la app esté en modo release para testing
3. Revisa los logs de AdMob en la consola

### Error de compilación

Si hay errores de compilación:

```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build
```

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## 📞 Soporte

Si tienes problemas o preguntas:

1. Revisa la documentación
2. Busca en los issues existentes
3. Crea un nuevo issue con detalles

## 🎯 Roadmap

- [ ] Sincronización en la nube
- [ ] Cuentas de usuario
- [ ] Categorías personalizadas
- [ ] Exportación a Excel/PDF
- [ ] Presupuestos y metas
- [ ] Notificaciones
- [ ] Widgets de escritorio
- [ ] Modo offline mejorado

---

**CuidaTuPlata** - Controla tus finanzas de manera simple y efectiva 💰

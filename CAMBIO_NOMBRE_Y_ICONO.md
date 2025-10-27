# Guía para Cambiar el Nombre e Icono de la App

## 📝 Cambiar el Nombre de la App

### 1. Android

#### Archivo: `android/app/src/main/AndroidManifest.xml`

```xml
<application
    android:label="MiControl"  <!-- ⬅️ CAMBIAR AQUÍ -->
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

### 2. iOS

#### Archivo: `ios/Runner/Info.plist`

```xml
<key>CFBundleDisplayName</key>
<string>MiControl</string>  <!-- ⬅️ CAMBIAR AQUÍ -->
```

### 3. Web

#### Archivo: `web/manifest.json`

```json
{
  "name": "MiControl", // ⬅️ CAMBIAR
  "short_name": "MiControl" // ⬅️ CAMBIAR
}
```

### 4. macOS

#### Archivo: `macos/Runner/Configs/AppInfo.xcconfig`

```
PRODUCT_NAME = MiControl  // ⬅️ CAMBIAR
```

### 5. Windows

#### Archivo: `windows/runner/Runner.rc` (si existe)

Cambiar el campo `IDR_MAINFRAME "NAME"` a tu nombre deseado.

### 6. Linux

#### Archivo: `linux/CMakeLists.txt`

Buscar y cambiar el nombre en la configuración.

## 🎨 Cambiar el Icono de la App

### Opción 1: Usando flutter_launcher_icons (RECOMENDADO)

#### Paso 1: Instalar flutter_launcher_icons

```bash
flutter pub add --dev flutter_launcher_icons
```

#### Paso 2: Configurar en pubspec.yaml

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  web:
    generate: true
    image_path: "assets/icono_app.png"
    background_color: "#6750A4"
    theme_color: "#6750A4"
  image_path: "assets/icono_app.png" # Tu icono (1024x1024 recomendado)
  adaptive_icon_background: "#6750A4"
  adaptive_icon_foreground: "assets/icono_adaptive.png"
```

#### Paso 3: Generar iconos

```bash
flutter pub run flutter_launcher_icons
```

### Opción 2: Manual (para cada plataforma)

#### Android

1. Coloca iconos en:

   - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
   - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
   - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
   - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
   - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

2. Para iconos adaptativos:
   - `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
   - `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_foreground.xml`
   - `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_background.xml`

#### iOS

1. Agrega iconos en:

   - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

   Tamaños necesarios:

   - AppIcon-20@2x.png (40x40)
   - AppIcon-20@3x.png (60x60)
   - AppIcon-29@2x.png (58x58)
   - AppIcon-29@3x.png (87x87)
   - AppIcon-40@2x.png (80x80)
   - AppIcon-40@3x.png (120x120)
   - AppIcon-60@2x.png (120x120)
   - AppIcon-60@3x.png (180x180)
   - AppIcon-1024@1x.png (1024x1024)

#### Web

Coloca iconos en `web/icons/`:

- Icon-192.png (192x192)
- Icon-512.png (512x512)
- Icon-maskable-192.png (192x192)
- Icon-maskable-512.png (512x512)

#### macOS

Agrega iconos en:

- `macos/Runner/Assets.xcassets/AppIcon.appiconset/`

## 🛠️ Herramientas para Crear Iconos

1. **AppIconGenerator** (Android): https://romannurik.github.io/AndroidAssetStudio/
2. **QuickAppIcon** (iOS): Disponible en Mac App Store
3. **Canva**: https://www.canva.com/ (plantillas de iconos)
4. **Figma**: https://www.figma.com/ (diseño profesional)

## 📋 Checklist Final

- [ ] Cambiar nombre en AndroidManifest.xml
- [ ] Cambiar nombre en Info.plist (iOS)
- [ ] Cambiar nombre en manifest.json (Web)
- [ ] Cambiar nombre en AppInfo.xcconfig (macOS)
- [ ] Crear icono de 1024x1024 píxeles
- [ ] Generar iconos para Android
- [ ] Generar iconos para iOS
- [ ] Generar iconos para Web
- [ ] Probar la app con el nuevo nombre e icono

## ⚠️ Notas Importantes

1. **Backup**: Haz backup antes de cambiar archivos
2. **Tamaños**: Los iconos deben ser cuadrados y en los tamaños correctos
3. **Fondo**: Para Android 8+, el icono adaptativo necesita fondo
4. **Reinstalar**: Probablemente necesites desinstalar y reinstalar la app para ver los cambios
5. **Build Clean**: Ejecuta `flutter clean` antes de construir

## 🚀 Comandos Útiles

```bash
# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Generar iconos (si usas flutter_launcher_icons)
flutter pub run flutter_launcher_icons

# Build para Android
flutter build apk

# Build para iOS
flutter build ios
```

# Comandos para ver logs en Windows

## Ver logs de Flutter/Purchase en Windows

### Opción 1: Usando findstr (nativo de Windows)

```cmd
adb logcat | findstr /i "flutter purchase premium"
```

O solo Flutter:

```cmd
adb logcat | findstr /i flutter
```

### Opción 2: Usando PowerShell (más potente)

```powershell
adb logcat | Select-String -Pattern "flutter|purchase|premium" -CaseSensitive:$false
```

O solo Flutter:

```powershell
adb logcat | Select-String -Pattern "flutter" -CaseSensitive:$false
```

### Opción 3: Guardar logs en un archivo

```cmd
adb logcat > logs.txt
```

Luego puedes abrir `logs.txt` y buscar con Ctrl+F por "flutter", "purchase", etc.

### Opción 4: Filtrar y guardar en archivo

```cmd
adb logcat | findstr /i "flutter purchase premium" > filtered_logs.txt
```

## Ver logs en tiempo real

Para ver los logs en tiempo real mientras usas la app:

```cmd
adb logcat | findstr /i "flutter purchase premium error"
```

## Limpiar logs anteriores

Antes de probar, limpia los logs antiguos:

```cmd
adb logcat -c
```

Luego ejecuta tu comando de filtrado.

## Comando completo recomendado

```cmd
adb logcat -c && adb logcat | findstr /i "flutter purchase premium error"
```

Este comando:

1. Limpia los logs anteriores (`-c`)
2. Muestra solo los logs relacionados con Flutter, purchase, premium y error

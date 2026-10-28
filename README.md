# Gasta Bien

App móvil en Flutter para que estudiantes foráneos administren su presupuesto semanal.
Incluye la pantalla de bienvenida (Tarea 1.2) y el resto de las pantallas del flujo.

## Flujo de pantallas

```
Bienvenida ─┬─ Comenzar ──► Registro ──► Configuración inicial ──► Pantalla principal
            └─ Ya tengo cuenta ──► Inicio de sesión ───────────────────┘
```

Pantalla principal (barra de navegación inferior):

| Pestaña | Qué hace |
|---|---|
| Resumen | Saldo disponible, barra de avance, cuánto puedes gastar por día y gasto por categoría. Avisa si las actividades pendientes no te alcanzan. |
| Gastos | Registrar gasto (concepto, monto, categoría). Desliza a la izquierda para borrar. |
| Actividades | Planificar actividades por día con costo estimado; marcarlas como realizadas. |
| Ahorro | Meta de ahorro opcional: crear, editar, abonar o quitar. |
| Lista | Lista de control de pendientes con avance; viene con cinco pendientes de ejemplo. |

Menú ⋮ de la barra superior: cambiar presupuesto y cerrar sesión.

## Estructura del código

```
lib/
├── main.dart            Arranque y tema
├── theme.dart           Paleta, degradado y formato de pesos
├── models.dart          Gasto, Actividad, MetaAhorro, ElementoLista, Usuario
├── app_state.dart       Estado global (ChangeNotifier)
├── widgets/comunes.dart Campos, botones y tarjetas reutilizables
└── screens/
    ├── welcome_screen.dart   register_screen.dart   login_screen.dart
    ├── setup_screen.dart     home_screen.dart
    └── summary_tab.dart  expenses_tab.dart  activities_tab.dart
        savings_tab.dart  checklist_tab.dart
```

## Limitaciones actuales

- Los datos viven en memoria: al cerrar la app se pierden, y la cuenta registrada solo existe mientras la app está abierta.
- No hay servidor ni base de datos; el inicio de sesión compara contra la cuenta creada en esa misma ejecución.
- Sin dependencias externas: solo Flutter.

## Ejecutar en un teléfono

El proyecto incluye las plataformas nativas `android/` e `ios/`.

### Android

1. Instala [Android Studio](https://developer.android.com/studio) y, desde el SDK Manager, instala el Android SDK, Platform-Tools y un emulador (o conecta un teléfono Android).
2. Activa las **Opciones de desarrollador** y la **Depuración USB** en el teléfono.
3. En la raíz del proyecto ejecuta:

   ```powershell
   flutter doctor
   flutter devices
   flutter run
   ```

   Si aparecen varios dispositivos, indica el teléfono con `flutter run -d <id>`.

### iPhone

Para compilar y cargar la aplicación en un iPhone se necesita macOS con Xcode. Abre el proyecto en `ios/Runner.xcworkspace`, configura el equipo de firma de Apple y ejecuta:

```bash
flutter run -d <id-del-iphone>
```

Desde Windows se puede preparar el código iOS, pero no compilarlo ni instalarlo en un iPhone.

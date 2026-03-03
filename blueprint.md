
# Project Blueprint - MoneyBic App

## Overview
Aplicación móvil para la gestión de solicitudes de socios, integrada con un backend Laravel y diseñada con una estética moderna Dark/Lime.

## Style, Design, and Features

### v1.4 - Identidad Visual MoneyBic
- **Colores Globales:** Implementación de paleta oficial:
  - Fondo: `#212529` (Dark Grey)
  - Primario/Botones: `#8BF724` (Lime Green)
  - Texto: `#FFFFFF` (White)
- **Logo:** Integración del logo oficial de MoneyBic en la pantalla de acceso.
- **Tema:** Configuración de `ThemeData` oscuro unificado en `main.dart`.
- **UI/UX:** Rediseño de componentes de entrada (TextFields) y botones con bordes redondeados y colores de alto contraste.

### v1.3 - Autenticación Laravel (Socios)
- **Backend:** Conexión con API Laravel en `https://meta.asociacionmilitaresnuevavision.com`.
- **Endpoint:** `/login-socio` para validación de documentos y contraseñas.
- **Seguridad:** Gestión de sesiones mediante Tokens de Acceso.

### v1.2 - Flujo de Solicitudes
- **Formulario:** Captura de ubicación origen (A), destino (B) y descripción detallada.
- **Validación:** Control de campos obligatorios y feedback mediante Snackbars.

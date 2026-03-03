# Project Blueprint - MoneyBic App

## Overview
Aplicación móvil financiera para la gestión de solicitudes, con autenticación basada en SMS (México) integrada con Supabase y Vonage.

## Style, Design, and Features

### v1.5 - Autenticación SMS (México)
- **Backend:** Migración a Supabase Auth para Phone Login.
- **SMS Provider:** Integración sugerida con Vonage vía Supabase Dashboard.
- **Flujo OTP:** Pantalla de entrada de número (+52 obligatorio) y pantalla de verificación de código de 6 dígitos.
- **Seguridad:** Manejo de sesiones persistentes con Supabase SDK.

### v1.4 - Identidad Visual MoneyBic
- **Colores Globales:**
  - Fondo: `#212529`
  - Primario: `#8BF724` (Verde Lima)
  - Texto: `#FFFFFF`
- **Logo:** Uso de imagen oficial en pantalla de acceso.
- **UI:** Estilo oscuro moderno con componentes de alta visibilidad.

### v1.2 - Flujo de Solicitudes
- **Formulario:** Captura de ubicación A, ubicación B y descripción.
- **UI:** Tarjetas con bordes redondeados y dropdowns estilizados.

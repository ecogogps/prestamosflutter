
# Project Blueprint - MoneyBic App

## Overview
Aplicación móvil financiera para la gestión de solicitudes, con autenticación basada en SMS (Ecuador) integrada con Supabase y Twilio Verify.

## Style, Design, and Features

### v1.7 - Flujo OTP de 6 dígitos
- **Navegación:** Implementado flujo `Login -> OTP -> Home`.
- **OTP Screen:** Pantalla dedicada para el ingreso del código de 6 dígitos enviado por SMS.
- **Validación:** El código ingresado se verifica mediante `Supabase.auth.verifyOTP`.

### v1.6 - Autenticación SMS (Ecuador)
- **Backend:** Supabase Auth con Phone OTP.
- **SMS Provider:** Integración con **Twilio Verify** configurada en el dashboard de Supabase.
- **Flujo OTP:** 
  - Pantalla de login con prefijo de Ecuador (+593).
  - Verificación de código de 6 dígitos.
- **Región:** Operación para números de Ecuador.

### v1.4 - Identidad Visual MoneyBic
- **Colores Globales:**
  - Fondo: `#212529`
  - Primario: `#8BF724` (Verde Lima)
  - Texto: `#FFFFFF`
- **Logo:** `https://i.postimg.cc/tTDNDSfZ/MONEYBIC-SIN-FONDO.png`
- **UI:** Estilo oscuro moderno con componentes de alta visibilidad.

### v1.2 - Flujo de Solicitudes
- **Formulario:** Captura de ubicación A, ubicación B y descripción en el Home.
- **Almacenamiento:** Tabla `solicitudes` en Supabase con RLS (Row Level Security).

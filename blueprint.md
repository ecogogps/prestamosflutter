
# Project Blueprint - MoneyBic App

## Overview
Aplicación móvil financiera para la gestión de solicitudes, con autenticación basada en SMS (México) integrada con Supabase y Twilio Verify.

## Style, Design, and Features

### v1.8 - Autenticación SMS (México)
- **Configuración:** Cambiado el prefijo regional a +52.
- **Validación de Input:** Restringido a 10 dígitos numéricos para cumplir con el estándar de marcación móvil en México.
- **Flujo OTP:** Mantenimiento del flujo Login (Teléfono) -> Verificación (OTP 6 dígitos).

### v1.7 - Flujo OTP de 6 dígitos
- **Navegación:** Implementado flujo `Login -> OTP -> Home`.
- **OTP Screen:** Pantalla dedicada para el ingreso del código de 6 dígitos enviado por SMS.
- **Validación:** El código ingresado se verifica mediante `Supabase.auth.verifyOTP`.

### v1.4 - Identidad Visual MoneyBic
- **Colores Globales:**
  - Fondo: `#212529`
  - Primario: `#8BF724` (Verde Lima)
  - Texto: `#FFFFFF`
- **Logo:** `https://i.postimg.cc/tTDNDSfZ/MONEYBIC-SIN-FONDO.png`
- **UI:** Estilo oscuro moderno con componentes de alta visibilidad.

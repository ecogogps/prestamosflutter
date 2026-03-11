
# Project Blueprint - MoneyBic App

## Overview
Aplicación móvil financiera para la gestión de solicitudes, con autenticación basada en SMS (México) integrada con Supabase y Twilio Verify.

## Style, Design, and Features

### v2.1 - Cálculos en Servidor (RPC)
- **Lógica Financiera:** Los cálculos de intereses (40%), montos recibidos (60%) y penalizaciones por mora (5% diario) se han migrado a una función PostgreSQL (`get_loan_details`) en Supabase.
- **Seguridad:** El cliente ya no realiza cálculos críticos; solo muestra la información calculada por el servidor, lo que previene manipulaciones.
- **Detalles:** Visualización dinámica de estados (Vencido) y desgloses precisos de montos.

### v2.0 - UI Premium y Cámara
- **Home UI:** Efectos de resplandor radial (glow) y reflejos brillantes en tarjetas para una estética fintech premium.
- **Cámara:** Pantalla de cámara personalizada con guías visuales para capturar rostros y documentos de identidad.
- **Multiform:** Stepper horizontal para la solicitud de préstamos con selección de bancos de México.

### v1.4 - Identidad Visual MoneyBic
- **Colores Globales:**
  - Fondo: `#181B1F` (Darker)
  - Primario: `#71AF57` (Green)
  - Texto: `#FFFFFF`
- **Logo:** `https://i.postimg.cc/Jzd6XVzQ/MONEYBIC-LOGO.png`

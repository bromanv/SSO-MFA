# 🔐 Laboratorio de Demostración SSO y MFA

Un laboratorio completamente funcional para demostrar Single Sign-On (SSO) y Autenticación Multi-Factor (MFA) usando Keycloak como Identity Provider.

## 📋 Componentes

| Componente | Puerto | Descripción |
|------------|--------|-------------|
| **Keycloak** | 8080 | Identity Provider (IdP) |
| **Portal de Empleados** | 3001 | Aplicación Demo #1 |
| **Sistema de Reportes** | 3002 | Aplicación Demo #2 |
| **MailHog** | 8025 | Servidor de correo para pruebas |
| **PostgreSQL** | 5432 | Base de datos de Keycloak |

## � Tecnologías de los Portales

Las aplicaciones demo están construidas con un stack moderno de Node.js:

### Backend
- **Node.js 18+** - Runtime de JavaScript
- **Express.js 4.18** - Framework web minimalista y flexible
- **Passport.js 0.7** - Middleware de autenticación
- **passport-openidconnect 0.1** - Estrategia OIDC para Passport
- **express-session 1.17** - Manejo de sesiones
- **axios 1.6** - Cliente HTTP para llamadas a APIs
- **jsonwebtoken 9.0** - Decodificación y validación de JWT

### Frontend
- **EJS 3.1** - Motor de plantillas (Embedded JavaScript)
- **Bootstrap 5.3** - Framework CSS para UI responsive
- **Bootstrap Icons 1.11** - Librería de iconos
- **HTML5 + CSS3** - Markup y estilos modernos
- **JavaScript ES6+** - Interactividad del cliente

### Características Implementadas
- ✅ Autenticación OpenID Connect (OIDC)
- ✅ Manejo de sesiones seguras
- ✅ Integración con Keycloak
- ✅ Logout global (SSO Logout)
- ✅ Visualización de tokens JWT
- ✅ Protección de rutas
- ✅ Interfaz responsive
- ✅ Soporte multi-idioma (ES/EN preparado)

## �🚀 Inicio Rápido

### Requisitos Previos
- Docker Desktop instalado
- Docker Compose v2+
- 4GB de RAM disponible

### Pasos de Instalación

```bash
# 1. Clonar o navegar al directorio del lab
cd sso-mfa-lab

# 2. Iniciar todos los servicios
docker-compose up -d

# 3. Esperar a que Keycloak esté listo (1-2 minutos)
docker-compose logs -f keycloak
# Esperar hasta ver: "Running the server"

# 4. Verificar que todo está corriendo
docker-compose ps
```

### URLs de Acceso

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| Keycloak Admin | http://localhost:8080/admin | `admin` / `admin123` |
| Portal Empleados | http://localhost:3001 | Ver usuarios demo abajo |
| Sistema Reportes | http://localhost:3002 | Ver usuarios demo abajo |
| MailHog (emails) | http://localhost:8025 | N/A |

## 👥 Usuarios de Demostración

| Usuario | Contraseña | Roles | Notas |
|---------|------------|-------|-------|
| `demo` | `demo123` | user | Usuario estándar |
| `admin` | `admin123` | user, admin | Usuario administrador |
| `byron` | `byron123` | user, admin | Usuario personalizado |

> ⚠️ **Importante**: En el primer login, se solicitará configurar MFA (TOTP). Usa Google Authenticator, Authy, o similar.

## 🔄 Flujo de Demostración SSO

### Escenario 1: Single Sign-On en acción

1. **Abrir Portal de Empleados**: http://localhost:3001
2. **Hacer clic en "Iniciar Sesión"** → Redirige a Keycloak
3. **Ingresar credenciales**: `demo` / `demo123`
4. **Configurar MFA**: Escanear QR con tu app authenticator
5. **Ingresar código TOTP** del authenticator
6. **Acceso concedido** → Dashboard del Portal
7. **Ahora abrir Sistema de Reportes**: http://localhost:3002
8. **Observar**: ¡Acceso automático sin login! Esto es SSO.

### Escenario 2: Logout Federado

1. En cualquier aplicación, hacer clic en **"Cerrar Sesión"**
2. Esto cierra la sesión en **todas** las aplicaciones
3. Verificar accediendo a la otra app → Requerirá login nuevamente

### Escenario 3: Explorar Tokens JWT

1. Autenticarse en cualquier app
2. Ir a **Dashboard → Ver Tokens**
3. Observar:
   - Access Token (para APIs)
   - ID Token (identidad del usuario)
   - Claims incluidos (nombre, email, roles)
   - Firma del token

## 🛠️ Configuración Técnica

### Protocolo: OpenID Connect (OIDC)

```
┌─────────────┐          ┌─────────────┐          ┌─────────────┐
│   Usuario   │          │  Keycloak   │          │  Aplicación │
│  (Browser)  │          │    (IdP)    │          │   (Client)  │
└──────┬──────┘          └──────┬──────┘          └──────┬──────┘
       │                        │                        │
       │  1. Acceder a App      │                        │
       │───────────────────────────────────────────────▶│
       │                        │                        │
       │  2. Redirect a Keycloak│                        │
       │◀───────────────────────────────────────────────│
       │                        │                        │
       │  3. Login + MFA        │                        │
       │───────────────────────▶│                        │
       │                        │                        │
       │  4. Authorization Code │                        │
       │◀───────────────────────│                        │
       │                        │                        │
       │  5. Redirect con code  │                        │
       │───────────────────────────────────────────────▶│
       │                        │                        │
       │                        │  6. Exchange code      │
       │                        │◀───────────────────────│
       │                        │                        │
       │                        │  7. Access + ID Token  │
       │                        │───────────────────────▶│
       │                        │                        │
       │  8. Sesión establecida │                        │
       │◀───────────────────────────────────────────────│
```

### Estructura de Tokens JWT

```json
{
  "exp": 1699999999,
  "iat": 1699999000,
  "iss": "http://localhost:8080/realms/demo-lab",
  "sub": "user-uuid",
  "typ": "Bearer",
  "azp": "app-portal",
  "preferred_username": "demo",
  "email": "demo@example.com",
  "name": "Usuario Demo",
  "realm_access": {
    "roles": ["user"]
  }
}
```

## 🔒 Configuración MFA (TOTP)

El laboratorio está configurado para **requerir MFA** en el primer login:

1. **Tipo**: TOTP (Time-based One-Time Password)
2. **Algoritmo**: HMAC-SHA1
3. **Dígitos**: 6
4. **Periodo**: 30 segundos
5. **Apps compatibles**: 
   - Google Authenticator
   - Microsoft Authenticator
   - Authy
   - FreeOTP

## � Configuración Detallada: realm-export.json

El archivo `realm-export.json` es el corazón de la configuración de Keycloak. Este archivo define completamente el realm "demo-lab" y permite replicar la configuración en cualquier instancia.

### Estructura y Propósito

```
keycloak-config/
└── realm-export.json    # Configuración completa del realm
```

Este archivo se importa automáticamente al iniciar Keycloak gracias a:
- El comando `start-dev --import-realm` en Docker
- El volumen montado: `./keycloak-config/realm-export.json:/opt/keycloak/data/import/realm-export.json`

### Configuración del Realm

#### 1. Información Básica
```json
{
  "id": "demo-lab",
  "realm": "demo-lab",
  "displayName": "SSO/MFA Demo Lab",
  "enabled": true
}
```

- **realm**: Identificador único del tenant
- **displayName**: Nombre mostrado en la UI
- **enabled**: El realm está activo

#### 2. Configuraciones de Seguridad

**SSL y Acceso:**
```json
"sslRequired": "none",              // Permitir HTTP (solo para demo)
"registrationAllowed": true,        // Permitir auto-registro
"loginWithEmailAllowed": true,      // Login con email
"resetPasswordAllowed": true        // Recuperación de contraseña
```

**Protección contra Fuerza Bruta:**
```json
"bruteForceProtected": true,        // Activar protección
"failureFactor": 5,                 // 5 intentos fallidos
"maxFailureWaitSeconds": 900,       // 15 min de bloqueo
"minimumQuickLoginWaitSeconds": 60  // Espera mínima entre intentos
```

#### 3. Configuración de Tokens y Sesiones

**Tiempos de Vida (en segundos):**
```json
"accessTokenLifespan": 300,              // Access Token: 5 minutos
"accessTokenLifespanForImplicitFlow": 900, // Implicit Flow: 15 minutos
"ssoSessionIdleTimeout": 1800,           // Sesión idle: 30 minutos
"ssoSessionMaxLifespan": 36000,          // Sesión máxima: 10 horas
"accessCodeLifespan": 60,                // Auth Code: 1 minuto
"accessCodeLifespanLogin": 1800          // Login Code: 30 minutos
```

Estos valores controlan cuánto tiempo permanecen válidos los tokens y sesiones antes de requerir renovación.

#### 4. Política de MFA (OTP/TOTP)

```json
"otpPolicyType": "totp",           // Time-based OTP
"otpPolicyAlgorithm": "HmacSHA1",  // Algoritmo de hash
"otpPolicyDigits": 6,              // Código de 6 dígitos
"otpPolicyPeriod": 30,             // Renovación cada 30 segundos
"otpPolicyLookAheadWindow": 1      // Ventana de tolerancia
```

**Apps Compatibles:**
- Google Authenticator
- Microsoft Authenticator  
- FreeOTP

#### 5. Roles del Realm

```json
"roles": {
  "realm": [
    {
      "name": "user",
      "description": "Usuario regular",
      "composite": false,
      "clientRole": false
    },
    {
      "name": "admin",
      "description": "Administrador",
      "composite": false,
      "clientRole": false
    }
  ]
}
```

Los roles controlan permisos y accesos en las aplicaciones.

#### 6. Usuarios Pre-configurados

Cada usuario incluye:
- **Credenciales**: Contraseña predefinida (password)
- **Roles**: Asignación de roles de realm
- **Información personal**: Nombre, apellido, email
- **Required Actions**: `CONFIGURE_TOTP` fuerza MFA en primer login

**Ejemplo de usuario:**
```json
{
  "username": "demo",
  "enabled": true,
  "emailVerified": true,
  "firstName": "Usuario",
  "lastName": "Demo",
  "email": "demo@example.com",
  "credentials": [{
    "type": "password",
    "value": "demo123",
    "temporary": false
  }],
  "realmRoles": ["user"],
  "requiredActions": ["CONFIGURE_TOTP"]
}
```

#### 7. Clientes (Aplicaciones)

Dos clientes OIDC configurados:

**app-portal (Puerto 3001):**
```json
{
  "clientId": "app-portal",
  "name": "Portal de Empleados",
  "secret": "portal-secret-123",
  "redirectUris": ["http://localhost:3001/*"],
  "webOrigins": ["http://localhost:3001"],
  "standardFlowEnabled": true,          // Authorization Code Flow
  "publicClient": false,                // Cliente confidencial
  "frontchannelLogout": true,           // Soporte logout
  "protocol": "openid-connect"
}
```

**app-reportes (Puerto 3002):**
```json
{
  "clientId": "app-reportes",
  "name": "Sistema de Reportes",
  "secret": "reportes-secret-456",
  "redirectUris": ["http://localhost:3002/*"],
  "webOrigins": ["http://localhost:3002"],
  "protocol": "openid-connect"
}
```

**Configuraciones Importantes:**
- `redirectUris`: URLs permitidas para callback después de login
- `webOrigins`: URLs permitidas para CORS
- `frontchannelLogout`: Habilita logout sincronizado (SSO logout)
- `standardFlowEnabled`: Usa Authorization Code Flow (más seguro)
- `directAccessGrantsEnabled`: Permite Resource Owner Password Flow (para testing)

#### 8. Configuración de Correo (SMTP)

```json
"smtpServer": {
  "host": "mailhog",           // Contenedor de MailHog
  "port": "1025",              // Puerto SMTP de MailHog
  "from": "noreply@demo-lab.local",
  "fromDisplayName": "SSO Demo Lab"
}
```

Usado para:
- ✉️ Verificación de email
- 🔑 Recuperación de contraseña
- 📧 Notificaciones de cuenta

#### 9. Headers de Seguridad

```json
"browserSecurityHeaders": {
  "xContentTypeOptions": "nosniff",
  "xRobotsTag": "none",
  "xFrameOptions": "SAMEORIGIN",
  "contentSecurityPolicy": "frame-src 'self'; frame-ancestors 'self'; object-src 'none';",
  "xXSSProtection": "1; mode=block",
  "strictTransportSecurity": "max-age=31536000; includeSubDomains"
}
```

Protecciones contra:
- XSS (Cross-Site Scripting)
- Clickjacking
- MIME type sniffing
- Ataques de frame injection

#### 10. Acciones Requeridas (Required Actions)

```json
"requiredActions": [
  {
    "alias": "CONFIGURE_TOTP",      // Configurar MFA
    "enabled": true,
    "priority": 10
  },
  {
    "alias": "UPDATE_PASSWORD",      // Actualizar contraseña
    "enabled": true,
    "priority": 30
  },
  {
    "alias": "VERIFY_EMAIL",        // Verificar email
    "enabled": true,
    "priority": 50
  }
]
```

Estas acciones se pueden forzar a usuarios en su próximo login.

#### 11. Internacionalización

```json
"internationalizationEnabled": true,
"supportedLocales": ["en", "es"],
"defaultLocale": "es"
```

Soporte multiidioma con español como predeterminado.

### Beneficios del realm-export.json

✅ **Reproducibilidad**: Configuración idéntica en cualquier entorno  
✅ **Versionamiento**: Puede guardarse en Git para control de cambios  
✅ **Documentación**: Sirve como documentación de la configuración  
✅ **Despliegue rápido**: Import automático al iniciar Keycloak  
✅ **Migración fácil**: Mover configuración entre instancias  
✅ **Backup**: Respaldo completo de la configuración del realm

### Exportar Configuración Actualizada

Si modificas el realm en Keycloak Admin y quieres exportar los cambios:

```bash
# Opción 1: Desde el contenedor
docker-compose exec keycloak /opt/keycloak/bin/kc.sh export \
  --dir /tmp/export \
  --realm demo-lab \
  --users realm_file

# Opción 2: Desde Keycloak Admin UI
# Ir a: Realm Settings → Action → Partial Export → Exportar
```

### Importar en Otra Instancia

```bash
# Copiar archivo al contenedor
docker cp realm-export.json keycloak:/tmp/

# Importar
docker-compose exec keycloak /opt/keycloak/bin/kc.sh import \
  --file /tmp/realm-export.json
```

## �📊 Comandos Útiles

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs solo de Keycloak
docker-compose logs -f keycloak

# Reiniciar todo
docker-compose restart

# Detener todo
docker-compose down

# Detener y eliminar volúmenes (reset completo)
docker-compose down -v

# Reconstruir aplicaciones después de cambios
docker-compose up -d --build

# Ver estado de los servicios
docker-compose ps

# Ejecutar comando en contenedor
docker-compose exec keycloak /bin/bash
```

## 🔧 Personalización

### Agregar más aplicaciones

1. Copiar carpeta `apps/demo-app-1` a `apps/nueva-app`
2. Modificar `docker-compose.yml` agregando nuevo servicio
3. En Keycloak Admin, crear nuevo Client
4. Actualizar variables de entorno en docker-compose

### Modificar políticas de MFA

1. Acceder a Keycloak Admin Console
2. Ir a **Authentication → Flows**
3. Duplicar "browser" flow
4. Modificar requerimientos de OTP
5. Asignar nuevo flow al realm

### Agregar proveedores de identidad externos

1. En Keycloak Admin, ir a **Identity Providers**
2. Agregar Google, Facebook, GitHub, etc.
3. Configurar credenciales OAuth2
4. Los usuarios podrán autenticarse con su cuenta externa

## 📚 Conceptos Demostrados

| Concepto | Descripción |
|----------|-------------|
| **SSO** | Un login, acceso a múltiples apps |
| **MFA/2FA** | Segundo factor con TOTP |
| **OIDC** | Protocolo de autenticación moderno |
| **JWT** | Tokens seguros y verificables |
| **Federation** | Logout sincronizado entre apps |
| **Claims** | Atributos del usuario en tokens |
| **Scopes** | Permisos de acceso |
| **Realm** | Tenant/dominio de seguridad |

## ⚠️ Notas de Seguridad

Este es un **laboratorio de demostración**. Para producción:

- [ ] Usar HTTPS con certificados válidos
- [ ] Cambiar todas las contraseñas y secrets
- [ ] Configurar políticas de contraseñas robustas
- [ ] Habilitar auditoría y logging
- [ ] Usar base de datos externa redundante
- [ ] Configurar backup de Keycloak
- [ ] Revisar políticas de sesión
- [ ] Implementar rate limiting

## 🆘 Troubleshooting

### Keycloak no inicia
```bash
# Verificar que PostgreSQL esté listo
docker-compose logs postgres

# Reiniciar Keycloak
docker-compose restart keycloak
```

### Error de conexión en apps
```bash
# Verificar que Keycloak esté completamente iniciado
curl http://localhost:8080/realms/demo-lab/.well-known/openid-configuration
```

### Reset completo
```bash
docker-compose down -v
docker-compose up -d
```

---

## 📞 Soporte

Creado para demostración de conceptos de SSO y MFA.

**Stack Tecnológico:**
- Keycloak 23.0
- Node.js 18
- Express.js
- Passport.js (OIDC)
- Bootstrap 5
- PostgreSQL 15
- Docker & Docker Compose

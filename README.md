# 🔐 SSO and MFA Demonstration Lab

A fully functional laboratory to demonstrate Single Sign-On (SSO) and Multi-Factor Authentication (MFA) using Keycloak as Identity Provider.

## 📋 Components

| Component | Port | Description |
|-----------|------|-------------|
| **Keycloak** | 8080 | Identity Provider (IdP) |
| **Employee Portal** | 3001 | Demo Application #1 |
| **Reporting System** | 3002 | Demo Application #2 |
| **MailHog** | 8025 | Test mail server |
| **PostgreSQL** | 5432 | Keycloak database |

## 🛠 Portal Technologies

The demo applications are built with a modern Node.js stack:

### Backend
- **Node.js 18+** - JavaScript runtime
- **Express.js 4.18** - Minimalist and flexible web framework
- **Passport.js 0.7** - Authentication middleware
- **passport-openidconnect 0.1** - OIDC strategy for Passport
- **express-session 1.17** - Session management
- **axios 1.6** - HTTP client for API calls
- **jsonwebtoken 9.0** - JWT decoding and validation

### Frontend
- **EJS 3.1** - Template engine (Embedded JavaScript)
- **Bootstrap 5.3** - CSS framework for responsive UI
- **Bootstrap Icons 1.11** - Icon library
- **HTML5 + CSS3** - Modern markup and styles
- **JavaScript ES6+** - Client interactivity

### Implemented Features
- ✅ OpenID Connect (OIDC) authentication
- ✅ Secure session management
- ✅ Keycloak integration
- ✅ Global logout (SSO Logout)
- ✅ JWT token visualization
- ✅ Route protection
- ✅ Responsive interface
- ✅ Multi-language support (ES/EN ready)

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed
- Docker Compose v2+
- 4GB available RAM

### Installation Steps

```bash
# 1. Clone or navigate to the lab directory
cd sso-mfa-lab

# 2. Start all services
docker-compose up -d

# 3. Wait for Keycloak to be ready (1-2 minutes)
docker-compose logs -f keycloak
# Wait until you see: "Running the server"

# 4. Verify everything is running
docker-compose ps
```

### Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| Keycloak Admin | http://localhost:8080/admin | `admin` / `admin123` |
| Employee Portal | http://localhost:3001 | See demo users below |
| Reporting System | http://localhost:3002 | See demo users below |
| MailHog (emails) | http://localhost:8025 | N/A |

## 👥 Demo Users

| User | Password | Roles | Notes |
|------|----------|-------|-------|
| `demo` | `demo123` | user | Standard user |
| `admin` | `admin123` | user, admin | Administrator user |
| `byron` | `byron123` | user, admin | Custom user |

> ⚠️ **Important**: On first login, you will be asked to configure MFA (TOTP). Use Google Authenticator, Authy, or similar.

## 🔄 SSO Demonstration Flow

### Scenario 1: Single Sign-On in Action

1. **Open Employee Portal**: http://localhost:3001
2. **Click "Sign In"** → Redirects to Keycloak
3. **Enter credentials**: `demo` / `demo123`
4. **Configure MFA**: Scan QR with your authenticator app
5. **Enter TOTP code** from authenticator
6. **Access granted** → Portal Dashboard
7. **Now open Reporting System**: http://localhost:3002
8. **Observe**: Automatic access without login! This is SSO.

### Scenario 2: Federated Logout

1. In any application, click **"Sign Out"**
2. This closes the session in **all** applications
3. Verify by accessing the other app → Will require login again

### Scenario 3: Explore JWT Tokens

1. Authenticate in any app
2. Go to **Dashboard → View Tokens**
3. Observe:
   - Access Token (for APIs)
   - ID Token (user identity)
   - Included claims (name, email, roles)
   - Token signature

## 🛠️ Technical Configuration

### Protocol: OpenID Connect (OIDC)

```
┌─────────────┐          ┌─────────────┐          ┌─────────────┐
│   User      │          │  Keycloak   │          │  Application │
│  (Browser)  │          │    (IdP)    │          │   (Client)  │
└──────┬──────┘          └──────┬──────┘          └──────┬──────┘
       │                        │                        │
       │  1. Access App         │                        │
       │───────────────────────────────────────────────▶│
       │                        │                        │
       │  2. Redirect to Keycloak│                       │
       │◀───────────────────────────────────────────────│
       │                        │                        │
       │  3. Login + MFA        │                        │
       │───────────────────────▶│                        │
       │                        │                        │
       │  4. Authorization Code │                        │
       │◀───────────────────────│                        │
       │                        │                        │
       │  5. Redirect with code │                        │
       │───────────────────────────────────────────────▶│
       │                        │                        │
       │                        │  6. Exchange code      │
       │                        │◀───────────────────────│
       │                        │                        │
       │                        │  7. Access + ID Token  │
       │                        │───────────────────────▶│
       │                        │                        │
       │  8. Session established│                        │
       │◀───────────────────────────────────────────────│
```

### JWT Token Structure

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
  "name": "Demo User",
  "realm_access": {
    "roles": ["user"]
  }
}
```

## 🔒 MFA Configuration (TOTP)

The laboratory is configured to **require MFA** on first login:

1. **Type**: TOTP (Time-based One-Time Password)
2. **Algorithm**: HMAC-SHA1
3. **Digits**: 6
4. **Period**: 30 seconds
5. **Compatible apps**: 
   - Google Authenticator
   - Microsoft Authenticator
   - Authy
   - FreeOTP

## 📝 Detailed Configuration: realm-export.json

The `realm-export.json` file is the heart of the Keycloak configuration. This file completely defines the "demo-lab" realm and allows replicating the configuration in any instance.

### Structure and Purpose

```
keycloak-config/
└── realm-export.json    # Complete realm configuration
```

This file is automatically imported when starting Keycloak thanks to:
- The `start-dev --import-realm` command in Docker
- The mounted volume: `./keycloak-config/realm-export.json:/opt/keycloak/data/import/realm-export.json`

### Realm Configuration

#### 1. Basic Information
```json
{
  "id": "demo-lab",
  "realm": "demo-lab",
  "displayName": "SSO/MFA Demo Lab",
  "enabled": true
}
```

- **realm**: Unique tenant identifier
- **displayName**: Name shown in the UI
- **enabled**: The realm is active

#### 2. Security Settings

**SSL and Access:**
```json
"sslRequired": "none",              // Allow HTTP (demo only)
"registrationAllowed": true,        // Allow self-registration
"loginWithEmailAllowed": true,      // Login with email
"resetPasswordAllowed": true        // Password recovery
```

**Brute Force Protection:**
```json
"bruteForceProtected": true,        // Enable protection
"failureFactor": 5,                 // 5 failed attempts
"maxFailureWaitSeconds": 900,       // 15 min lockout
"minimumQuickLoginWaitSeconds": 60  // Minimum wait between attempts
```

#### 3. Token and Session Configuration

**Lifespan Times (in seconds):**
```json
"accessTokenLifespan": 300,              // Access Token: 5 minutes
"accessTokenLifespanForImplicitFlow": 900, // Implicit Flow: 15 minutes
"ssoSessionIdleTimeout": 1800,           // Idle session: 30 minutes
"ssoSessionMaxLifespan": 36000,          // Max session: 10 hours
"accessCodeLifespan": 60,                // Auth Code: 1 minute
"accessCodeLifespanLogin": 1800          // Login Code: 30 minutes
```

These values control how long tokens and sessions remain valid before renewal is required.

#### 4. MFA Policy (OTP/TOTP)

```json
"otpPolicyType": "totp",           // Time-based OTP
"otpPolicyAlgorithm": "HmacSHA1",  // Hash algorithm
"otpPolicyDigits": 6,              // 6-digit code
"otpPolicyPeriod": 30,             // Refresh every 30 seconds
"otpPolicyLookAheadWindow": 1      // Tolerance window
```

**Compatible Apps:**
- Google Authenticator
- Microsoft Authenticator  
- FreeOTP

#### 5. Realm Roles

```json
"roles": {
  "realm": [
    {
      "name": "user",
      "description": "Regular user",
      "composite": false,
      "clientRole": false
    },
    {
      "name": "admin",
      "description": "Administrator",
      "composite": false,
      "clientRole": false
    }
  ]
}
```

Roles control permissions and access in applications.

#### 6. Preconfigured Users

Each user includes:
- **Credentials**: Predefined password
- **Roles**: Realm role assignment
- **Personal information**: First name, last name, email
- **Required Actions**: `CONFIGURE_TOTP` forces MFA on first login

**User example:**
```json
{
  "username": "demo",
  "enabled": true,
  "emailVerified": true,
  "firstName": "User",
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

#### 7. Clients (Applications)

Two configured OIDC clients:

**app-portal (Port 3001):**
```json
{
  "clientId": "app-portal",
  "name": "Employee Portal",
  "secret": "portal-secret-123",
  "redirectUris": ["http://localhost:3001/*"],
  "webOrigins": ["http://localhost:3001"],
  "standardFlowEnabled": true,          // Authorization Code Flow
  "publicClient": false,                // Confidential client
  "frontchannelLogout": true,           // Logout support
  "protocol": "openid-connect"
}
```

**app-reportes (Port 3002):**
```json
{
  "clientId": "app-reportes",
  "name": "Reporting System",
  "secret": "reportes-secret-456",
  "redirectUris": ["http://localhost:3002/*"],
  "webOrigins": ["http://localhost:3002"],
  "protocol": "openid-connect"
}
```

**Important Settings:**
- `redirectUris`: Allowed URLs for callback after login
- `webOrigins`: Allowed URLs for CORS
- `frontchannelLogout`: Enables synchronized logout (SSO logout)
- `standardFlowEnabled`: Uses Authorization Code Flow (more secure)
- `directAccessGrantsEnabled`: Allows Resource Owner Password Flow (for testing)

#### 8. Email Configuration (SMTP)

```json
"smtpServer": {
  "host": "mailhog",           // MailHog container
  "port": "1025",              // MailHog SMTP port
  "from": "noreply@demo-lab.local",
  "fromDisplayName": "SSO Demo Lab"
}
```

Used for:
- ✉️ Email verification
- 🔑 Password recovery
- 📧 Account notifications

#### 9. Security Headers

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

Protections against:
- XSS (Cross-Site Scripting)
- Clickjacking
- MIME type sniffing
- Frame injection attacks

#### 10. Required Actions

```json
"requiredActions": [
  {
    "alias": "CONFIGURE_TOTP",      // Configure MFA
    "enabled": true,
    "priority": 10
  },
  {
    "alias": "UPDATE_PASSWORD",      // Update password
    "enabled": true,
    "priority": 30
  },
  {
    "alias": "VERIFY_EMAIL",        // Verify email
    "enabled": true,
    "priority": 50
  }
]
```

These actions can be forced on users at their next login.

#### 11. Internationalization

```json
"internationalizationEnabled": true,
"supportedLocales": ["en", "es"],
"defaultLocale": "es"
```

Multi-language support with Spanish as default.

### Benefits of realm-export.json

✅ **Reproducibility**: Identical configuration in any environment  
✅ **Versioning**: Can be saved in Git for change control  
✅ **Documentation**: Serves as configuration documentation  
✅ **Quick deployment**: Automatic import when starting Keycloak  
✅ **Easy migration**: Move configuration between instances  
✅ **Backup**: Complete backup of realm configuration

### Export Updated Configuration

If you modify the realm in Keycloak Admin and want to export the changes:

```bash
# Option 1: From the container
docker-compose exec keycloak /opt/keycloak/bin/kc.sh export \
  --dir /tmp/export \
  --realm demo-lab \
  --users realm_file

# Option 2: From Keycloak Admin UI
# Go to: Realm Settings → Action → Partial Export → Export
```

### Import into Another Instance

```bash
# Copy file to container
docker cp realm-export.json keycloak:/tmp/

# Import
docker-compose exec keycloak /opt/keycloak/bin/kc.sh import \
  --file /tmp/realm-export.json
```

## 📊 Useful Commands

```bash
# View logs of all services
docker-compose logs -f

# View Keycloak logs only
docker-compose logs -f keycloak

# Restart everything
docker-compose restart

# Stop everything
docker-compose down

# Stop and remove volumes (complete reset)
docker-compose down -v

# Rebuild applications after changes
docker-compose up -d --build

# View service status
docker-compose ps

# Execute command in container
docker-compose exec keycloak /bin/bash
```

## 🔧 Customization

### Add More Applications

1. Copy folder `apps/demo-app-1` to `apps/new-app`
2. Modify `docker-compose.yml` adding new service
3. In Keycloak Admin, create new Client
4. Update environment variables in docker-compose

### Modify MFA Policies

1. Access Keycloak Admin Console
2. Go to **Authentication → Flows**
3. Duplicate "browser" flow
4. Modify OTP requirements
5. Assign new flow to realm

### Add External Identity Providers

1. In Keycloak Admin, go to **Identity Providers**
2. Add Google, Facebook, GitHub, etc.
3. Configure OAuth2 credentials
4. Users will be able to authenticate with their external account

## 📚 Demonstrated Concepts

| Concept | Description |
|---------|-------------|
| **SSO** | One login, access to multiple apps |
| **MFA/2FA** | Second factor with TOTP |
| **OIDC** | Modern authentication protocol |
| **JWT** | Secure and verifiable tokens |
| **Federation** | Synchronized logout between apps |
| **Claims** | User attributes in tokens |
| **Scopes** | Access permissions |
| **Realm** | Security tenant/domain |

## ⚠️ Security Notes

This is a **demonstration laboratory**. For production:

- [ ] Use HTTPS with valid certificates
- [ ] Change all passwords and secrets
- [ ] Configure robust password policies
- [ ] Enable auditing and logging
- [ ] Use external redundant database
- [ ] Configure Keycloak backup
- [ ] Review session policies
- [ ] Implement rate limiting

## 🆘 Troubleshooting

### Keycloak won't start
```bash
# Verify PostgreSQL is ready
docker-compose logs postgres

# Restart Keycloak
docker-compose restart keycloak
```

### Connection error in apps
```bash
# Verify Keycloak is completely started
curl http://localhost:8080/realms/demo-lab/.well-known/openid-configuration
```

### Complete reset
```bash
docker-compose down -v
docker-compose up -d
```




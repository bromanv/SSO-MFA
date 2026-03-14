const express = require('express');
const session = require('express-session');
const passport = require('passport');
const OpenIDConnectStrategy = require('passport-openidconnect');
const jwt = require('jsonwebtoken');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración de la aplicación desde variables de entorno
const config = {
  appName: process.env.APP_NAME || 'Demo App',
  appColor: process.env.APP_COLOR || '#3498db',
  keycloakUrl: process.env.KEYCLOAK_URL || 'http://localhost:8080',
  keycloakInternalUrl: process.env.KEYCLOAK_INTERNAL_URL || process.env.KEYCLOAK_URL || 'http://localhost:8080',
  realm: process.env.KEYCLOAK_REALM || 'demo-lab',
  clientId: process.env.KEYCLOAK_CLIENT_ID || 'app-portal',
  clientSecret: process.env.KEYCLOAK_CLIENT_SECRET || 'portal-secret-123',
  callbackUrl: process.env.CALLBACK_URL || 'http://localhost:3001/callback'
};

// URLs de Keycloak
// authorizationURL e issuer usan la URL publica (navegador del usuario)
// tokenURL y userInfoURL usan la URL interna (llamadas server-to-server dentro de Docker)
const keycloakUrls = {
  issuer: `${config.keycloakUrl}/realms/${config.realm}`,
  authorizationURL: `${config.keycloakUrl}/realms/${config.realm}/protocol/openid-connect/auth`,
  tokenURL: `${config.keycloakInternalUrl}/realms/${config.realm}/protocol/openid-connect/token`,
  userInfoURL: `${config.keycloakInternalUrl}/realms/${config.realm}/protocol/openid-connect/userinfo`,
  logoutURL: `${config.keycloakUrl}/realms/${config.realm}/protocol/openid-connect/logout`
};

// Configurar EJS como motor de plantillas
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

// Configurar sesiones
app.use(session({
  secret: process.env.SESSION_SECRET || 'demo-secret-key',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: false, // Cambiar a true en producción con HTTPS
    maxAge: 1000 * 60 * 60 // 1 hora
  }
}));

// Inicializar Passport
app.use(passport.initialize());
app.use(passport.session());

// Serialización de usuario
passport.serializeUser((user, done) => {
  done(null, user);
});

passport.deserializeUser((user, done) => {
  done(null, user);
});

// Configurar estrategia OpenID Connect
passport.use('oidc', new OpenIDConnectStrategy({
  issuer: keycloakUrls.issuer,
  authorizationURL: keycloakUrls.authorizationURL,
  tokenURL: keycloakUrls.tokenURL,
  userInfoURL: keycloakUrls.userInfoURL,
  clientID: config.clientId,
  clientSecret: config.clientSecret,
  callbackURL: config.callbackUrl,
  scope: ['openid', 'profile', 'email']
}, (issuer, profile, context, idToken, accessToken, refreshToken, done) => {
  // Decodificar el token para obtener información adicional
  let decodedToken = null;
  try {
    decodedToken = jwt.decode(accessToken);
  } catch (e) {
    console.error('Error decodificando token:', e);
  }

  const user = {
    id: profile.id,
    displayName: profile.displayName,
    username: profile.username || profile._json?.preferred_username,
    email: profile.emails?.[0]?.value || profile._json?.email,
    firstName: profile.name?.givenName || profile._json?.given_name,
    lastName: profile.name?.familyName || profile._json?.family_name,
    idToken: idToken,
    accessToken: accessToken,
    refreshToken: refreshToken,
    decodedToken: decodedToken,
    rawProfile: profile._json
  };

  return done(null, user);
}));

// Middleware para verificar autenticación
const ensureAuthenticated = (req, res, next) => {
  if (req.isAuthenticated()) {
    return next();
  }
  res.redirect('/login');
};

// ============================================
// RUTAS
// ============================================

// Página principal (pública)
app.get('/', (req, res) => {
  res.render('index', {
    config,
    user: req.user,
    isAuthenticated: req.isAuthenticated()
  });
});

// Iniciar login
app.get('/login', passport.authenticate('oidc'));

// Callback de autenticación
app.get('/callback',
  passport.authenticate('oidc', {
    failureRedirect: '/login-error'
  }),
  (req, res) => {
    // Login exitoso
    res.redirect('/dashboard');
  }
);

// Error de login
app.get('/login-error', (req, res) => {
  res.render('error', {
    config,
    message: 'Error durante la autenticación. Por favor intenta de nuevo.',
    isAuthenticated: false
  });
});

// Dashboard (protegido)
app.get('/dashboard', ensureAuthenticated, (req, res) => {
  res.render('dashboard', {
    config,
    user: req.user,
    isAuthenticated: true
  });
});

// Ver tokens (protegido) - útil para demostración
app.get('/tokens', ensureAuthenticated, (req, res) => {
  res.render('tokens', {
    config,
    user: req.user,
    isAuthenticated: true
  });
});

// Perfil de usuario (protegido)
app.get('/profile', ensureAuthenticated, (req, res) => {
  res.render('profile', {
    config,
    user: req.user,
    isAuthenticated: true
  });
});

// Logout
app.get('/logout', (req, res) => {
  const idToken = req.user?.idToken;
  // Derivar URL publica de la app desde CALLBACK_URL (tiene el puerto externo correcto)
  const appBaseUrl = config.callbackUrl.replace('/callback', '');
  const postLogoutUri = encodeURIComponent(appBaseUrl);

  req.logout((err) => {
    if (err) console.error('Error en logout:', err);

    req.session.destroy((err) => {
      if (err) console.error('Error destruyendo sesion:', err);

      // Si hay idToken valido usarlo como hint; si no, usar client_id
      let logoutUrl;
      if (idToken) {
        logoutUrl = `${keycloakUrls.logoutURL}?id_token_hint=${idToken}&post_logout_redirect_uri=${postLogoutUri}`;
      } else {
        logoutUrl = `${keycloakUrls.logoutURL}?client_id=${config.clientId}&post_logout_redirect_uri=${postLogoutUri}`;
      }

      res.redirect(logoutUrl);
    });
  });
});

// API: Estado de sesión (para AJAX)
app.get('/api/session', (req, res) => {
  res.json({
    isAuthenticated: req.isAuthenticated(),
    user: req.user ? {
      username: req.user.username,
      email: req.user.email,
      displayName: req.user.displayName
    } : null
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', app: config.appName });
});

// Manejo de errores
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).render('error', {
    config,
    message: 'Ha ocurrido un error interno.',
    error: process.env.NODE_ENV === 'development' ? err : {},
    isAuthenticated: req.isAuthenticated()
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║    ${config.appName.padEnd(45)}                            ║
║                                                            ║
║   Servidor corriendo en: http://localhost:${PORT}          ║
║   Keycloak URL: ${config.keycloakUrl.padEnd(35)}           ║
║   Realm: ${config.realm.padEnd(43)}                        ║
║   Client ID: ${config.clientId.padEnd(39)}                 ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
  `);
});

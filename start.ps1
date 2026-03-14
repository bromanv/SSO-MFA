$ErrorActionPreference = "Stop"

Clear-Host
Write-Host ""
Write-Host "  Laboratorio SSO y MFA - Keycloak Demo" -ForegroundColor Cyan
Write-Host "  ======================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $PSScriptRoot

# 1. Verificar Docker instalado
Write-Host "  [1/4] Verificando Docker..." -ForegroundColor Yellow
$dockerOk = $false
try {
    $v = & docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "        OK: $v" -ForegroundColor Green
        $dockerOk = $true
    }
} catch {}

if (-not $dockerOk) {
    Write-Host ""
    Write-Host "  Docker no esta instalado." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Para instalarlo:" -ForegroundColor White
    Write-Host "  1. Ve a: https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    Write-Host "  2. Descarga Docker Desktop for Windows" -ForegroundColor White
    Write-Host "  3. Ejecuta el instalador y reinicia" -ForegroundColor White
    Write-Host "  4. Abre Docker Desktop y espera el icono en la barra de tareas" -ForegroundColor White
    Write-Host "  5. Vuelve a ejecutar este script" -ForegroundColor White
    Write-Host ""
    Read-Host "  Presiona Enter para cerrar"
    exit 1
}

# 2. Verificar que Docker este corriendo
Write-Host "  [2/4] Verificando que Docker este activo..." -ForegroundColor Yellow
try {
    & docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Docker no responde" }
    Write-Host "        OK: Docker esta corriendo" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "  Docker esta instalado pero no esta corriendo." -ForegroundColor Red
    Write-Host "  Abre Docker Desktop y espera el icono en la barra de tareas." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Presiona Enter para cerrar"
    exit 1
}

# 3. Levantar servicios
Write-Host "  [3/4] Iniciando servicios con Docker Compose..." -ForegroundColor Yellow
Write-Host "        (Keycloak, PostgreSQL, Apps, MailHog)" -ForegroundColor Gray
Write-Host ""

& docker compose up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  Error al iniciar los servicios." -ForegroundColor Red
    Write-Host "  Revisa los logs con: docker compose logs" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "  Presiona Enter para cerrar"
    exit 1
}

# 4. Esperar a Keycloak
Write-Host ""
Write-Host "  [4/4] Esperando a que Keycloak este listo (hasta 2 minutos)..." -ForegroundColor Yellow

$maxAttempts = 60
$attempt = 0
$ready = $false

while ($attempt -lt $maxAttempts) {
    try {
        $r = Invoke-WebRequest -Uri "http://localhost:8080/health/ready" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        if ($r.StatusCode -eq 200) {
            $ready = $true
            break
        }
    } catch {}
    $attempt++
    Write-Host -NoNewline "."
    Start-Sleep -Seconds 2
}

Write-Host ""

if (-not $ready) {
    Write-Host "  Keycloak tarda mas de lo esperado, puede seguir iniciando." -ForegroundColor Yellow
    Write-Host "  Verifica con: docker compose logs -f keycloak" -ForegroundColor Cyan
    Write-Host "  Espera hasta ver el mensaje: Running the server" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "        OK: Keycloak listo!" -ForegroundColor Green
}

# Resumen final
Write-Host ""
Write-Host "  =============================" -ForegroundColor Green
Write-Host "  Laboratorio iniciado!" -ForegroundColor Green
Write-Host "  =============================" -ForegroundColor Green
Write-Host ""
Write-Host "  Keycloak Admin   ->  http://localhost:8080/admin" -ForegroundColor Cyan
Write-Host "                       admin / admin123"
Write-Host ""
Write-Host "  Portal Empleados ->  http://localhost:3001" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Sistema Reportes ->  http://localhost:3002" -ForegroundColor Cyan
Write-Host ""
Write-Host "  MailHog (emails) ->  http://localhost:8025" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Usuarios de prueba:" -ForegroundColor White
Write-Host "    demo  / demo123   (usuario estandar)" -ForegroundColor Gray
Write-Host "    admin / admin123  (administrador)" -ForegroundColor Gray
Write-Host "    byron / byron123  (personalizado)" -ForegroundColor Gray
Write-Host ""
Write-Host "  NOTA: El primer login pedira configurar MFA." -ForegroundColor Yellow
Write-Host "  Usa Google Authenticator o Microsoft Authenticator." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Comandos utiles:" -ForegroundColor White
Write-Host "    docker compose logs -f       (ver logs en vivo)" -ForegroundColor Gray
Write-Host "    docker compose ps            (estado de servicios)" -ForegroundColor Gray
Write-Host "    docker compose down          (detener todo)" -ForegroundColor Gray
Write-Host "    docker compose down -v       (detener y borrar datos)" -ForegroundColor Gray
Write-Host ""

$openBrowser = Read-Host "  Abrir el Portal de Empleados en el navegador? (s/n)"
if ($openBrowser -eq "s" -or $openBrowser -eq "S") {
    Start-Process "http://localhost:3001"
}

Write-Host ""
Write-Host "  Listo. Puedes cerrar esta ventana." -ForegroundColor Green
Write-Host ""

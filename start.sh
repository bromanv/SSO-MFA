#!/bin/bash

# ============================================
# Script de Inicio - SSO/MFA Demo Lab
# ============================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║   🔐 Laboratorio SSO y MFA                                 ║"
echo "║   Demostración con Keycloak                                ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar Docker
echo -e "${YELLOW}Verificando Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado. Por favor instala Docker Desktop.${NC}"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker no está corriendo. Por favor inicia Docker Desktop.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker está listo${NC}"

# Verificar Docker Compose
echo -e "${YELLOW}Verificando Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose no está disponible.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker Compose está listo${NC}"

# Iniciar servicios
echo ""
echo -e "${YELLOW}Iniciando servicios...${NC}"
echo ""

docker-compose up -d --build

echo ""
echo -e "${YELLOW}Esperando a que Keycloak esté listo (puede tomar 1-2 minutos)...${NC}"

# Esperar a que Keycloak esté listo
MAX_ATTEMPTS=60
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s http://localhost:8080/health/ready > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Keycloak está listo!${NC}"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo -n "."
    sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo -e "${RED}❌ Timeout esperando a Keycloak. Revisa los logs con: docker-compose logs keycloak${NC}"
    exit 1
fi

# Mostrar estado
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ${GREEN}✓ Laboratorio iniciado correctamente!${BLUE}                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Servicios disponibles:${NC}"
echo ""
echo -e "  🔑 Keycloak Admin:      ${BLUE}http://localhost:8080/admin${NC}"
echo -e "     Usuario: admin / admin123"
echo ""
echo -e "  🏢 Portal Empleados:    ${BLUE}http://localhost:3001${NC}"
echo ""
echo -e "  📊 Sistema Reportes:    ${BLUE}http://localhost:3002${NC}"
echo ""
echo -e "  📧 MailHog (emails):    ${BLUE}http://localhost:8025${NC}"
echo ""
echo -e "${YELLOW}Usuarios de prueba:${NC}"
echo "  demo  / demo123   (usuario estándar)"
echo "  admin / admin123  (administrador)"
echo "  byron / byron123  (personalizado)"
echo ""
echo -e "${YELLOW}⚠️  En el primer login se solicitará configurar MFA (TOTP)${NC}"
echo "   Usa Google Authenticator o similar para escanear el QR"
echo ""
echo -e "${GREEN}Para detener: ${NC}docker-compose down"
echo -e "${GREEN}Para ver logs: ${NC}docker-compose logs -f"
echo ""

#!/bin/bash

# ============================================
# Script de Detención - SSO/MFA Demo Lab
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   🛑 Deteniendo Laboratorio SSO/MFA                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Preguntar si quiere eliminar datos
read -p "¿Deseas eliminar todos los datos (volúmenes)? [s/N]: " respuesta

if [[ "$respuesta" =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}Deteniendo y eliminando volúmenes...${NC}"
    docker-compose down -v
    echo -e "${GREEN}✓ Laboratorio detenido y datos eliminados${NC}"
else
    echo -e "${YELLOW}Deteniendo servicios (manteniendo datos)...${NC}"
    docker-compose down
    echo -e "${GREEN}✓ Laboratorio detenido (datos preservados)${NC}"
fi

echo ""
echo -e "Para reiniciar: ${BLUE}./start.sh${NC} o ${BLUE}docker-compose up -d${NC}"
echo ""

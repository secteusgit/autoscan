#!/bin/bash

VERSION="0.2"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
  echo -e "${BLUE}AutoScan v$VERSION${NC}"
  echo "Uso: ./autoscan.sh -t <target> [-o output] [--fast]"
  echo
  echo "Opções:"
  echo "  -t        Alvo (domínio ou IP)"
  echo "  -o        Diretório de saída (default: scans)"
  echo "  --fast    Scan rápido (pula Nuclei)"
  echo "  -h        Ajuda"
  exit 1
}

check_tool() {
  command -v "$1" >/dev/null 2>&1 || {
    echo -e "${RED}[!] Ferramenta ausente: $1${NC}"
    exit 1
  }
}

FAST=false
OUTPUT="scans"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t) TARGET="$2"; shift 2 ;;
    -o) OUTPUT="$2"; shift 2 ;;
    --fast) FAST=true; shift ;;
    -h) usage ;;
    *) usage ;;
  esac
done

[ -z "$TARGET" ] && usage

echo -e "${GREEN}[+] Iniciando AutoScan v$VERSION${NC}"
echo "[*] Alvo: $TARGET"
echo "[*] Output: $OUTPUT/$TARGET"
echo "[*] FAST mode: $FAST"

for tool in assetfinder httpx nmap nuclei; do
  check_tool "$tool"
done

OUTDIR="$OUTPUT/$TARGET"
mkdir -p "$OUTDIR"

echo -e "${BLUE}[+] Resultados em: $OUTDIR${NC}"

echo -e "${GREEN}[+] Coletando subdomínios...${NC}"
assetfinder --subs-only "$TARGET" > "$OUTDIR/subdomains.txt"

echo -e "${GREEN}[+] Verificando serviços HTTP...${NC}"
cat "$OUTDIR/subdomains.txt" | httpx -silent > "$OUTDIR/http_services.txt"

echo -e "${GREEN}[+] Executando Nmap...${NC}"
nmap -sS -T4 "$TARGET" -oN "$OUTDIR/nmap.txt"

if [ "$FAST" = false ]; then
  echo -e "${GREEN}[+] Executando Nuclei...${NC}"
  nuclei -l "$OUTDIR/http_services.txt" -o "$OUTDIR/nuclei.txt"
else
  echo -e "${BLUE}[i] FAST ativado — Nuclei pulado${NC}"
fi

echo -e "${GREEN}[✓] Scan finalizado${NC}"

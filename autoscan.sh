#!/bin/bash

VERSION="0.2"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
  echo -e "${BLUE}AutoScan v$VERSION${NC}"
  echo "Uso: autoscan -t <target> [-o output] [--fast]"
  echo
  echo "Opções:"
  echo "  -t    Alvo (domínio ou IP)"
  echo "  -o    Diretório de saída (default: scans)"
  echo "  --fast  Scan rápido (pula enumeração pesada)"
  echo "  -h    Ajuda"
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
  case $1 in
    -t) TARGET="$2"; shift ;;
    -o) OUTPUT="$2"; shift ;;
    --fast) FAST=true ;;
    -h) usage ;;
    *) usage ;;
  esac
  shift
done

[ -z "$TARGET" ] && usage

echo -e "${GREEN}[+] Iniciando AutoScan v$VERSION${NC}"

for tool in assetfinder httpx nmap nuclei; do
  check_tool $tool
done

OUTDIR="$OUTPUT/$TARGET"
mkdir -p "$OUTDIR"

echo -e "${BLUE}[*] Alvo:${NC} $TARGET"
echo -e "${BLUE}[*] Output:${NC} $OUTDIR"

if [ "$FAST" = false ]; then
  echo -e "${GREEN}[+] Coletando subdomínios...${NC}"
  assetfinder "$TARGET" | sort -u > "$OUTDIR/subdomains.txt"
else
  echo -e "${BLUE}[*] FAST mode: pulando subdomínios${NC}"
  echo "$TARGET" > "$OUTDIR/subdomains.txt"
fi

echo -e "${GREEN}[+] Verificando hosts ativos...${NC}"
cat "$OUTDIR/subdomains.txt" | httpx -silent > "$OUTDIR/httpx.txt"

echo -e "${GREEN}[+] Rodando Nmap...${NC}"
nmap -sV -T4 "$TARGET" -oN "$OUTDIR/nmap.txt" >/dev/null

echo -e "${GREEN}[+] Rodando Nuclei...${NC}"
nuclei -l "$OUTDIR/httpx.txt" -o "$OUTDIR/nuclei.txt" >/dev/null

echo -e "${GREEN}[✔] Scan finalizado!${NC}"
echo -e "${BLUE}Resultados em:${NC} $OUTDIR"

#!/bin/bash

TARGET=$1

if [ -z "$TARGET" ]; then
  echo "Uso: autoscan <dominio ou IP>"
  exit 1
fi

OUTPUT="scans/$TARGET"
mkdir -p $OUTPUT

echo "[+] Iniciando scan em $TARGET"

echo "[+] Coletando subdomínios..."
assetfinder $TARGET | tee $OUTPUT/subdomains.txt

echo "[+] Verificando hosts ativos..."
cat $OUTPUT/subdomains.txt | httpx -silent | tee $OUTPUT/httpx.txt

echo "[+] Rodando Nmap..."
nmap -sV -T4 $TARGET -oN $OUTPUT/nmap.txt

echo "[+] Rodando Nuclei..."
nuclei -l $OUTPUT/httpx.txt -o $OUTPUT/nuclei.txt

echo "[✔] Scan finalizado! Resultados em $OUTPUT"


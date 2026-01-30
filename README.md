# AutoScan 🔍

AutoScan é um script em **Bash** para automação de varreduras básicas de reconhecimento e análise inicial de segurança em ambientes Linux.

> ⚠️ **Uso educacional e autorizado apenas.**  
> Execute somente em sistemas que você possui permissão explícita para testar.

---

## 🚀 Funcionalidades

- Verificação de conectividade (ping)
- Varredura de portas com Nmap
- Enumeração de serviços
- Coleta básica de informações
- Modo rápido (`--fast`)
- Logs automáticos

---

## 📦 Requisitos

As seguintes ferramentas devem estar instaladas:

- bash
- nmap
- curl
- whois
- dnsutils

Instalação no Kali Linux:
```bash
sudo apt update && sudo apt install -y nmap curl whois dnsutils


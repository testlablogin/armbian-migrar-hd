# 🚀 Armbian - Migração para HD Externo (USB)

Este script automatiza o processo de migração do sistema Armbian (instalado em cartão SD) para um HD externo (ex: `/dev/sda1`), incluindo configuração de boot, criação de swapfile e ajustes no `fstab` e `armbianEnv.txt`.

---

## ⚠️ Aviso importante

🧨 **Todos os dados em `/dev/sda1` serão apagados**! Faça backup antes de executar o script.

---

## 🛠️ Requisitos

- Orange Pi Zero 3 (ou outro single-board compatível)
- Armbian já instalado e rodando via cartão SD
- HD externo (USB), já conectado (será formatado)
- Acesso root (via `sudo`)

---

## 💡 O que o script faz

✔️ Detecta automaticamente `/dev/sda1`  
✔️ Formata como `ext4`  
✔️ Copia todo o sistema usando `rsync`  
✔️ Atualiza UUID no `armbianEnv.txt` e `fstab`  
✔️ Cria `swapfile` de 2GB no HD  
✔️ Pronto para boot pelo HD após reiniciar  

---

## 📦 Instalação via terminal

Execute no seu Armbian:

```bash
curl -fsSL https://raw.githubusercontent.com/testlablogin/armbian-migrar-hd/main/migrar_para_hd.sh | bash

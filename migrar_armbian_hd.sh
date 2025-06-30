#!/bin/bash

# =============================
# Script: migrar_para_hd.sh
# Autor: @testlablogin
# Descricao: Migra rootfs do Armbian para HD externo (/dev/sda1)
# Uso: curl -fsSL https://raw.githubusercontent.com/testlablogin/armbian-migrar-hd/main/migrar_para_hd.sh | bash
# =============================

set -e

### ⚠️ CONFIRMAÇÃO DO USUÁRIO
read -p $'\n\e[1;33mATENÇÃO:\e[0m Isso vai FORMATAR \e[1;31m/dev/sda1\e[0m e migrar o sistema do SD para o HD.\nDeseja continuar? (s/N): ' CONFIRM
[[ "$CONFIRM" =~ ^[sS]$ ]] || exit 1

### 📦 DEPENDÊNCIAS
echo -e "\n📦 Instalando dependências..."
sudo apt update && sudo apt install -y rsync parted

### 🔍 VERIFICAÇÃO DO DISCO
if ! lsblk | grep -q "/dev/sda1"; then
  echo -e "\n❌ Disco /dev/sda1 não encontrado. Use 'lsblk' para confirmar o nome."
  exit 1
fi

### 💽 DESMONTAR CASO ESTEJA MONTADO
sudo umount -l /dev/sda1 || true

### 🧹 FORMATAR COMO EXT4
echo -e "\n🧹 Formatando /dev/sda1 como ext4..."
sudo mkfs.ext4 -F /dev/sda1

### 🔄 MONTAR HD TEMPORARIAMENTE
mkdir -p /mnt/hd
sudo mount /dev/sda1 /mnt/hd

### 📂 COPIAR ARQUIVOS
echo -e "\n📂 Copiando sistema para o HD..."
sudo rsync -aAXv /* /mnt/hd --exclude="/mnt/*" --exclude="/proc/*" --exclude="/sys/*" --exclude="/tmp/*" --exclude="/dev/*" --exclude="/run/*" --exclude="/media/*" --exclude="/lost+found"

### 🔍 UUID
UUID=$(blkid -s UUID -o value /dev/sda1)

### ⚙️ CONFIGURAR armbianEnv.txt
ENV_FILE="/boot/armbianEnv.txt"
if grep -q "rootdev=" "$ENV_FILE"; then
    sudo sed -i "s|rootdev=.*|rootdev=UUID=$UUID|" "$ENV_FILE"
else
    echo "rootdev=UUID=$UUID" | sudo tee -a "$ENV_FILE"
fi

### 📝 ATUALIZAR fstab
echo "UUID=$UUID / ext4 defaults,noatime 0 1" | sudo tee /mnt/hd/etc/fstab

### 💾 CRIAR SWAPFILE
echo -e "\n💾 Criando swapfile de 2 GB no HD..."
sudo dd if=/dev/zero of=/mnt/hd/swapfile bs=1M count=2048
sudo chmod 600 /mnt/hd/swapfile
sudo mkswap /mnt/hd/swapfile
echo "/swapfile none swap sw 0 0" | sudo tee -a /mnt/hd/etc/fstab

### ✅ FINALIZADO
echo -e "\n✅ Finalizado. Reinicie o sistema agora."
echo "Sistema vai inicializar com rootfs no HD (/dev/sda1)."
echo "Use: sudo reboot"

# EOF

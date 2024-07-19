#!/bin/bash

# Configuració
SWAPFILE="/var/swap"
BLOCKSIZE=4096
COUNT=16

# Crear el fitxer de swap
sudo dd if=/dev/zero of=$SWAPFILE bs=${BLOCKSIZE}k count=$COUNT

# Arreglar permisos i propietari
sudo chown root:root $SWAPFILE
sudo chmod 0600 $SWAPFILE

# Formatejar el fitxer com a swap
sudo mkswap $SWAPFILE

# Activar el fitxer de swap
sudo swapon $SWAPFILE

# Verificar les àrees de swap actives
sudo swapon -s

# Afegir el fitxer de swap a /etc/fstab per mantenir-lo entre arrencades
if ! grep -q "$SWAPFILE" /etc/fstab; then
    echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab
fi

echo "Swap configurat correctament i afegit a /etc/fstab"

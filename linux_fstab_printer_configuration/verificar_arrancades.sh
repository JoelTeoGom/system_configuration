#!/bin/bash

# Configuració
SWAPFILE="/var/swap"

echo "=== Verificant que el fitxer de swap està a /etc/fstab ==="
# Comprovar si el fitxer de swap està a /etc/fstab
if grep -q "$SWAPFILE" /etc/fstab; then
    echo "El fitxer de swap està present a /etc/fstab."
else
    echo "Error: El fitxer de swap no està present a /etc/fstab."
    exit 1
fi

echo "=== Desactivant i reactivant el swap per verificar ==="
# Desactivar i tornar a activar totes les entrades de swap per verificar
sudo swapoff $SWAPFILE
sudo swapon -a

# Verificar que el fitxer de swap està actiu
if sudo swapon --show | grep -q "$SWAPFILE"; then
    echo "El fitxer de swap s'ha activat correctament i es muntarà en la següent arrencada."
else
    echo "Error: El fitxer de swap no s'ha activat correctament."
    exit 1
fi

echo "Verificació del fitxer de swap completada."

sudo swapon --show
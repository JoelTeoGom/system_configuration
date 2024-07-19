#!/bin/bash

# Definir el directorio temporal dentro del directorio base del usuario
tmp="$HOME/tmp"

# Definir el tamaño del sistema de archivos tmpfs
tmpfs_size="100M"

# Verificar si el directorio temporal existe, si no, crearlo
if [ ! -d "$tmp" ]; then
    mkdir -p "$tmp"
fi

# Montar el sistema de archivos tmpfs en el directorio temporal
sudo mount -t tmpfs -o size=$tmpfs_size tmpfs "$tmp"

# Agregar una entrada al archivo /etc/fstab para montar automáticamente el tmpfs en cada inicio del sistema
echo "tmpfs $tmp tmpfs size=$tmpfs_size,rw,nodev,nosuid,noexec 0 0" | sudo tee -a /etc/fstab > /dev/null

#!/bin/bash

# Comprobar si se han proporcionado argumentos
if [ $# -eq 0 ]; then
    echo "Uso: $0 <paquete1> [<paquete2> ...]"
    exit 1
fi

# Iterar sobre cada paquete y desinstalarlos
for package in "$@"; do
    echo "Desinstalando el paquete: $package"

    # Verificar si el paquete está instalado
    if dpkg -l | grep -qw "^ii  $package"; then
        # Desinstalar el paquete conservando los archivos de configuración y las dependencias
        sudo apt-get remove $package

        # Imprimir la línea de comando para reinstalar el paquete
        echo "Para reinstalar $package, ejecuta:"
        echo "sudo apt-get install $package"
    else
        echo "El paquete $package no está instalado."
    fi

done

#!/bin/bash

# Ruta absoluta del archivo de salida
output_file="/home/joel/lab2/output.txt"
rm output.txt
# Comprobar si se han proporcionado argumentos
if [ $# -eq 0 ]; then
    echo "Uso: $0 <paquete1> [<paquete2> ...]" >> "$output_file"
    exit 1
fi

# Iteramos por cada paquete y miramos su información
for package in "$@"; do
    echo "Consultando información para el paquete: $package" >> "$output_file"

    # Verificar si el paquete está instalado
    if dpkg -l | grep -wq "^ii  $package"; then
        echo "Paquete $package instalado:" >> "$output_file"
        echo "==================================================================================" >> "$output_file"

        # Obtener la versión actualmente instalada
        version=$(dpkg -l | grep -w "^ii  $package" | awk '{print $3}')
        echo "Versión actualmente instalada: $version" >> "$output_file"

        # Obtener la fecha y hora de instalación
        install_time=$(stat -c "%y" $(which $package))
        echo "Fecha y hora de instalación: $install_time" >> "$output_file"

        # Comprobar disponibilidad de actualización
        if apt-cache show $package | grep -q "Version:"; then
            available_version=$(apt-cache show $package | grep "Version:" | head -n1 | awk '{print $2}')
            if [ "$version" != "$available_version" ]; then
                echo "Hay una nueva versión disponible: $available_version" >> "$output_file"
            else
                echo "No hay actualizaciones disponibles." >> "$output_file"
            fi
        else
            echo "No se pudo determinar la disponibilidad de actualización." >> "$output_file"
        fi

        # Obtener la lista de dependencias del paquete
        dependencies=$(apt-cache depends $package | grep "Depends:" | awk '{$1=""; print $0}')
        echo "Lista de dependencias del paquete:" >> "$output_file"
        echo "$dependencies" >> "$output_file"

        # Mostrar los archivos de configuración asociados al paquete
        echo "Archivos de configuración asociados al paquete:" >> "$output_file"
        dpkg -L $package >> "$output_file"

        echo "==================================================================================" >> "$output_file"

    else
        echo "El paquete $package no está instalado." >> "$output_file"
    fi

done





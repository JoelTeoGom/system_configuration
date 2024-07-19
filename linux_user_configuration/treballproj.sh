#!/bin/bash

# Verificar si se proporciona el nombre del proyecto como parámetro
if [ $# -ne 1 ]; then
    echo "Uso: $0 <nombre_proyecto>"
    exit 1
fi

nombre_proyecto="$1"
usuario_actual=$(whoami)
directorio_anterior=$(pwd)
grupo_anterior=$(groups | cut -d ' ' -f 3)

# Verificar si el directorio del proyecto existe
if [ ! -d "/home/empresa/project/$nombre_proyecto" ]; then
    echo "El proyecto '$nombre_proyecto' no existe."
    exit 1
fi

# Verificar si el usuario es miembro del grupo del proyecto
if ! groups "$usuario_actual" | grep -q "\b$nombre_proyecto\b"; then
    echo "El usuario '$usuario_actual' no es miembro del grupo '$nombre_proyecto'."
    exit 1
fi

# Cambiar al directorio del proyecto correspondiente al nombre del usuario
cd "/home/empresa/project/$nombre_proyecto" || exit 1

# Cambiar el grupo activo del usuario al del proyecto
newgrp "$nombre_proyecto"


# Al salir del proyecto, restaurar el grupo activo y el directorio anterior
cd "$directorio_anterior" || exit 1
newgrp "$grupo_anterior"

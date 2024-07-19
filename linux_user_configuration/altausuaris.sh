#!/bin/bash

# Función para comprobar y crear los directorios y el grupo necesarios
comprovar_directoris() {
    local path="$1"
    local group_name="$2"

    # Comprobar si el directorio 'empresa' ya existe
    if [ -d "$path" ]; then
        echo "El directorio 'empresa' ya existe."
    else
        # Crear el directorio 'empresa'
        mkdir $path
        mkdir $path/bin
        mkdir $path/usuaris
        mkdir $path/project
        
    fi

    # Comprobar si el grupo 'empresa' ya existe
    if grep -q "^$group_name:" /etc/group; then
        echo "El grupo '$group_name' ya existe."
    else
        # Crear el grupo 'empresa'
        groupadd "$group_name"
    fi 

    chmod 750 "$path"
    chown :empresa -R "$path"

    chmod 1770 $path/bin          
    chown :empresa $path/bin

    echo 'export PATH="/home/empresa/bin:$PATH"' >> ~/.bashrc

}

# Función para crear usuarios
crear_usuarios() {
    local archivo_usuarios="$1"
    local path="/home/empresa"
    local group_name="empresa"
    primera_linia=true
    # Iterar sobre cada línea restante del archivo de usuarios
    while IFS=':' read -r dni nom num proj; do
        if [ "$primera_linia" = true ]; then
                primera_linia=false
                continue  # Salta a la següent iteració
        fi
        nomUser=$(echo "$nom" | cut -d ',' -f2 | tr -d '[:space:]')  # Extreu el nom de la cadena de nom i cognoms
        cognomsUser=$(echo "$nom" | cut -d ',' -f1 | tr -d '[:space:]')  # Extreu els cognoms de la cadena de nom i cognoms
        inicialsCognoms=$(echo "$cognomsUser" | grep -o '[A-Z]' | tr -d '\n')
        # Concatenar el nom i les inicials dels cognoms
        nombre_usuario="${nomUser}${inicialsCognoms}"
        echo $nombre_usuario
        # Comprobar si el nombre de usuario ya existe
        if id "$nombre_usuario" &>/dev/null; then
            # Si el nombre de usuario ya existe, añadir un número al final
            contador=1
            while id "${nombre_usuario}${contador}" &>/dev/null; do
                ((contador++))
            done
            nombre_usuario="${nombre_usuario}${contador}"
        fi
        
        # Crear el nuevo usuario
        if ! id "$nombre_usuario" &>/dev/null; then
            if useradd -m -d "/home/empresa/usuaris/$nombre_usuario" -s "/bin/bash" -c "$dni, $nom" "$nombre_usuario"; then
                passwd -d -q "$nombre_usuario"
                echo "Usuario creado: $nombre_usuario"
                chown -R "$nombre_usuario":"$nombre_usuario" /home/empresa/usuaris/"$nombre_usuario"
                chmod -R 4700 /home/empresa/usuaris/"$nombre_usuario"
                # Añadir el usuario al grupo 'empresa'
                if usermod -aG "$group_name" "$nombre_usuario"; then
                    echo "Usuario $nombre_usuario añadido al grupo $group_name."
                else
                    echo "Error al añadir el usuario $nombre_usuario al grupo $group_name."
                fi
                # Crear el directorio 'bin' dentro del directorio del usuario
                if mkdir -p "/home/empresa/usuaris/$nombre_usuario/bin"; then
                    echo "Se ha creado el directorio 'bin' para el usuario: $nombre_usuario"
                    chown -R "$nombre_usuario":"$nombre_usuario" /home/empresa/usuaris/"$nombre_usuario"

                    # Establecer los permisos del directorio 'bin' para el usuario
                    chmod 700 "/home/empresa/usuaris/$nombre_usuario/bin"
                    # Agregar el directorio 'bin' del usuario al final de la variable PATH
                    echo "export PATH=\"\$PATH:/home/empresa/usuaris/$nombre_usuario/bin\"" >> "/home/empresa/usuaris/$nombre_usuario/.bashrc"

                else
                    echo "Error al crear el directorio 'bin' para el usuario: $nombre_usuario"
                fi
            else
                echo "Error al crear el usuario: $nombre_usuario"
            fi
        else
            echo "El usuario $nombre_usuario ya existe."
        fi

        # Crear o agregar al usuario al grupo del proyecto y crear la carpeta del proyecto si es necesario
        IFS=',' read -ra proyectos <<< "$proj"
        for proyecto in "${proyectos[@]}"; do
            # Comprobar si el grupo del proyecto ya existe
            if ! grep -q "^$proyecto:" /etc/group; then
                groupadd "$proyecto"
            fi

            # Agregar al usuario al grupo del proyecto
            if ! groups "$nombre_usuario" | grep -q "\b$proyecto\b"; then
                    usermod -aG "$proyecto" "$nombre_usuario"
                    echo "Usuario $nombre_usuario añadido al grupo $proyecto."
            fi

            # Comprobar si la carpeta del proyecto existe
            if [ ! -d "/home/empresa/project/$proyecto" ]; then
                mkdir "/home/empresa/project/$proyecto"
            fi
        done
    done < "$archivo_usuarios"  # Redirigir la entrada del bucle desde el archivo de usuarios
}

crear_carpetas_proyectos() {
    local archivo_proyectos="$1"
    local path="/home/empresa"
    primera_linia=true
    # Iterar sobre cada línea del archivo de proyectos
    while IFS=':' read -r nom_projecte cap_projecte descripcio_projecte; do

        if [ "$primera_linia" = true ]; then
            primera_linia=false
            continue  # Salta a la siguiente iteración
        fi
        # Eliminar espacios al inicio y al final de los nombres de proyecto y capitán de proyecto
        nom_projecte=$(echo "$nom_projecte" | tr -d ' ')
        cap_projecte=$(echo "$cap_projecte" | tr -d ' ')

        # Crear la carpeta del proyecto si no existe
        if [ ! -d "$path/project/$nom_projecte" ]; then
            mkdir -p "$path/project/$nom_projecte"
            echo "Carpeta del proyecto '$nom_projecte' creada."
        else
            echo "La carpeta del proyecto '$nom_projecte' ya existe."
        fi

        # Buscar el usuario cuyo UID coincide con el DNI proporcionado
        usuario_dni=$(grep -m 1 "$cap_projecte" /etc/passwd | awk -F: '{print $1}')

        echo "Usuario del proyecto '$nom_projecte' es '$usuario_dni'"

        # Establecer al usuario encontrado como propietario del proyecto
        if [ -n "$usuario_dni" ]; then
            chown "$usuario_dni:$nom_projecte" "$path/project/$nom_projecte"
            echo "El capitán del proyecto '$nom_projecte' es '$usuario_dni'."
        else
            echo "No se encontró ningún usuario con el nombre '$cap_projecte'."
        fi

        # Establecer los permisos en la carpeta del proyecto
        chmod 770 "$path/project/$nom_projecte"
        echo "Permisos establecidos en la carpeta del proyecto '$nom_projecte'."
        echo "Todos los miembros del grupo '$nom_projecte' pueden crear y borrar archivos en la carpeta."
        echo "Solo el propietario del archivo puede borrarlo."

        # Establecer el bit setgid para que los nuevos archivos hereden el grupo del proyecto
        chmod g+s "$path/project/$nom_projecte"
        echo "Se estableció el bit setgid para los archivos nuevos en '$nom_projecte'."

        # Establecer el bit sticky para que solo el propietario pueda eliminar los archivos
        chmod +t "$path/project/$nom_projecte"
        echo "Se estableció el bit sticky para los archivos nuevos en '$nom_projecte'."


    done < "$archivo_proyectos"  # Redirigir la entrada del bucle desde el archivo de proyectos
}




# Verificar si se proporcionan los archivos como parámetros
if [ $# -ne 2 ]; then
    echo "Uso: $0 <archivo_usuarios> <archivo_proyectos>"
    exit 1
fi

# Verificar si los archivos de usuarios y proyectos existen
if [ ! -f "$1" ] || [ ! -f "$2" ]; then
    echo "Los archivos proporcionados no existen."
    exit 1
fi

# Llamar a las funciones con el archivo de usuarios como parámetro
comprovar_directoris "/home/empresa" "empresa"
crear_usuarios "$1"
crear_carpetas_proyectos "$2"
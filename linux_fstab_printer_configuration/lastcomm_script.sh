#!/bin/bash

# Funció per mostrar l'ús de l'script
usage() {
    echo "Ús: $0 [comanda] [login d'usuari]"
    exit 1
}

# Comprovar si s'han proporcionat suficients paràmetres
if [ "$#" -lt 1 ]; then
    usage
fi

# Comprovar si la comanda 'lastcomm' està disponible
if ! command -v lastcomm &> /dev/null; then
    echo "Error: La comanda 'lastcomm' no està instal·lada o no està en el PATH."
    exit 1
fi

# Assignar paràmetres a variables
command=$1
user=$2

# Si es proporciona tant la comanda com l'usuari
if [ ! -z "$user" ]; then
    result=$(lastcomm --command "$command" | grep -w "$user" | cut -c 54-70)
    if [ -z "$result" ]; then
        echo "L'usuari $user no ha executat la comanda $command."
    else
        echo "L'usuari $user ha executat la comanda $command els dies següents:"
        echo "$result"
    fi
else
    # Si només es proporciona la comanda
    echo "Mostrant els usuaris que han executat la comanda $command i el número de vegades:"
    
    # Utilitzar cut per extreure els noms d'usuari
    users=$(lastcomm --command "$command" | cut -c 23-30 | sort | uniq -c | sort -nr)

    if [ -z "$users" ]; then
        echo "Cap usuari ha executat la comanda $command."
    else
        echo "$users"
    fi
fi
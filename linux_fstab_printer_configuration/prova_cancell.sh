#!/bin/bash

# Fitxers a imprimir
fitxer1="fitxer1.txt"
fitxer2="fitxer2.txt"
fitxer3="fitxer3.txt"

# Contingut dels fitxers (només per a fins de prova)
echo "Contingut del fitxer 1" > "$fitxer1"
echo "Contingut del fitxer 2" > "$fitxer2"
echo "Contingut del fitxer 3" > "$fitxer3"



# Enviar els fitxers a imprimir
/usr/bin/lp "$fitxer1"
/usr/bin/lp "$fitxer2"
/usr/bin/lp "$fitxer3"

# Mostrar els treballs d'impressió en curs
echo "Treballs d'impressió en curs:"
lpstat -o


# Cancel·lar automàticament un dels treballs d'impressió
cancel -a

# Mostrar els treballs d'impressió actualitzats després de la cancel·lació
echo "Treballs d'impressió després de la cancel·lació:"
lpstat -o

echo "ls per comprobar el directori"
ls /home/milax/DocsPDF


echo "Prova completada."

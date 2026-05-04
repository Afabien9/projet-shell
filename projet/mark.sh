#!/bin/bash

limit_height=0
note=2
facto=(1 1 2 6 24 120 720 5040 40320 362880 3628800)
check1=0
header_original_missing=0 

indentation() {
    local ligne=$1
    local space=$2
    local good_space=$3

    if [[ -z "$ligne" ]]; then
        echo "$good_space $space"
        return
    fi

    prefix="${ligne%%[^ ]*}" 
                         
    height_space=${#prefix}

    if [[ "$ligne" == *"}"* ]]; then
        space=$(( space - 2 ))
    fi

    if [[ $space -ne $height_space ]]; then
        good_space=0
    fi

    if [[ "$ligne" == *"{"* ]]; then
        space=$(( space + 2 ))
    fi
    echo "$good_space $space"
}

if [ ! -f "header.h" ]; then
    touch header.h
    header_original_missing=1
fi

make

for fichier in ./*; do
    if [ -f "$fichier" ]; then
        if [[ "$fichier" == *.txt ]]; then
            read -r ligne < "$fichier"
            prenom=$(echo "$ligne" | cut -d' ' -f1)
            nom=$(echo "$ligne" | cut -d' ' -f2)
            echo "$prenom"
            echo "$nom"

        elif [[ "$fichier" == *.c ]]; then
            facto_here=0
            space=0
            good_space=1

            while IFS= read -r ligne; do
                ligne="${ligne%$'\r'}" 
                if [[ "$ligne" == *"int factorielle"* && $facto_here -eq 0 ]]; then
                    note=$((note + 2))
                    echo "fonction facto bonne  BONUS +2"
                    facto_here=1
                fi

                if [[ "$good_space" -eq 1 ]]; then
                    read good_space space <<< "$(indentation "$ligne" "$space" "$good_space")"
                fi

                if [[ "$good_space" -eq 0 ]]; then
                    note=$(( note - 2 ))
                    good_space=2
                    echo "Erreur indentation"
                    echo "$ligne"
                fi

                height=${#ligne}
                if [[ $limit_height -eq 0 && $height -gt 80 ]]; then
                    limit_height=1
                    note=$(( note - 2 ))
                    echo "Ligne +80 charac -2"
                fi
            done < "$fichier"
        fi
    fi
done

if [[ $header_original_missing -eq 1 ]]; then
    note=$(( note - 2 ))
    echo "Pas de header -2"
    rm -f header.h 
fi

for ((i=0; i<11; i++)); do
    res=$(./factorielle "$i")
    if [ "$i" -eq 0 ]; then
        if [ "$res" -eq 1 ]; then
            echo "Facto 0 good : +3"
            note=$(( note + 3 ))
        fi
    else
        if [ "$res" -eq "${facto[$i]}" ]; then
            check1=$(( check1 + 1 ))
        fi
    fi
done

if [ "$check1" -eq 10 ]; then
    note=$(( note + 5 ))
    echo "10 Facto good BONUS +5"
fi

bad_res=$(./factorielle)
if [ "$bad_res" = "Erreur: Mauvais nombre de parametres" ]; then
    note=$(( note + 4 ))
    echo "Erreur nb de paramètres good : +4"
fi

bad_res=$(./factorielle -1)
if [ "$bad_res" = "Erreur: nombre negatif" ]; then
    note=$(( note + 4 ))
    echo "Erreur nb négatif good : +4"
fi

if ! make clean; then
    note=$(( note - 2 ))
    echo "make clean mauvais : -2"
elif [ -f factorielle ]; then
    note=$((note - 2))
    echo "make clean ne supprime pas factorielle"
fi

note=$note
csv_file="note.csv"

if [ -f "readme.txt" ]; then
    contenu=$(cat "readme.txt")

    nom=$(echo "$contenu" | awk '{print $2}')
    prenom=$(echo "$contenu" | awk '{print $1}')
else
    echo "Erreur : le fichier readme.txt est manquant."
    exit 1
fi

if [ ! -f "$csv_file" ]; then
    echo "Nom,Prénom,Note" > "$csv_file"
fi

if [[ "$note" -lt 0 ]]; then
    note=0
fi

echo "'$nom','$prenom',$note" >> "$csv_file"

echo "Note finale : $note"
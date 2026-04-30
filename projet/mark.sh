limit_height=0
note=2
facto=(1 1 2 6 24 120 720 5040 40320 362880 )
check1=0
header=0
make
for fichier in ./*; do
    if [ -f "$fichier" ]; then
        if [[ "$fichier" == *.txt ]]; then
            read -r ligne < "$fichier"
            prenom=$(echo "$ligne" | cut -d' ' -f1)
            nom=$(echo "$ligne" | cut -d' ' -f2)
            echo $prenom
            echo $nom
            
        elif [[ "$fichier" == *.c ]]; then
            facto_here=0
            while IFS= read -r ligne; do
                if [[ "$ligne" == *"int factorielle"* && $facto_here -eq 0 ]]; then
                    note=$((note + 2))
                    facto_here=1
                fi

                height=${#ligne}
                if [[ $limit_height -eq 0 ]]; then
                    if [[ "$height" -gt 80 ]]; then
                        limit_height=1
                        note=$((note - 2))
                    fi
                fi
            done < "$fichier"
        elif [[ "$fichier" == *.h ]]; then
            header=1
        fi
    fi
done

if [[ $header -eq 0 ]]; then
    note=$((note - 2))
fi


for ((i=0; i<10; i++)); do
    res=$(./factorielle "$i")
    if [ "$i" -eq 0 ]; then
        if [ "$res" -eq 1 ]; then
        note=$((note + 3))
        check1=$((check1 + 1))
        fi

    else
        if [ "$res" -eq "${facto[$i]}" ]; then
        check1=$((check1 + 1))
        fi
    fi
done

if [ "$check1" -eq 10 ]; then
    note=$(( note + 5))
fi

bad_res=$( ./factorielle )
if [ "$bad_res" = "Erreur: Mauvais nombre de parametres" ]; then
    note=$((note + 4))
fi

bad_res=$(./factorielle -1 )
if [ "$bad_res" = "Erreur: nombre negatif" ]; then
    note=$(( note + 4 ))
fi

if ! make clean; then
note=$(( note - 2 ))
fi
echo $note
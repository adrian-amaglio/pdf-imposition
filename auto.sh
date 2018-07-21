source='/home/py/git/lgs-info/bruts/perso/Nouveau dossier/Samedi.pdf'
destination='/home/py/git/lgs-info/bruts/perso/Nouveau\ dossier/planches.pdf'
while true ; do
  if [ -f "$source" ] ; then
    echo 'On lance l’imposition'
    rm "$destination"
    ./imposition.sh "$source" "$destination"
    rm "$source"
  else
    echo "Pas de fichier source ($source)"
  fi
  sleep 1
done

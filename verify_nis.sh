#!/bin/bash
. param
. functions

# On récupére le nom de machine
hostname=$(hostname)

# Partie exécuté si la machine est serveur
if [ $hostname = $SERVEUR_NIS ]
then
    echo "Vérification: serveur"
    echo ""

    # Ping vers toutes les autres machine si serveur
    echo "Vérification machines"
    echo ""
    while IFS= read -r line
    do
      nomActuel=$(echo $line | cut -d ' ' -f 2)
      ping -c1  $nomActuel 1>/dev/null
      if [ "$?" = 0 ]
      then
        echo -e "Ping vers $nomActuel : \033[32m réussi \033[0m"
      else
        echo -e "Ping vers $nomActuel : \033[31m échoué \033[0m"
      fi
    done < "$MACHINE_LISTE"
    echo ""

    # On vérifie si le firewall est actif
    isActive=$(systemctl is-active firewalld.service)
    if [ $isActive = "active" ]
    then
        echo -e "--- firewalld.service -- \033[31m actif \033[0m"
    else
        echo -e "--- firewalld.service -- \033[32m stop \033[0m"
    fi

    # On vérifie si ypserv est actif
    isActive=$(systemctl is-active ypserv.service)
    if [ $isActive = "active" ]
    then
        echo -e "--- ypserv.service -- \033[32m actif \033[0m"
    else
        echo -e "--- ypserv.service -- \033[31m stop \033[0m"
    fi


    # Vérification du nom de domaine nis
    if [ $(nisdomainname) = $DOMAIN_NIS ]
    then
        echo -e "--- nom de domaine nis = $DOMAIN_NIS -- \033[32m nom correct \033[0m"
    else
        echo -e "--- nom de domaine nis = $(nisdomainname) -- \033[31m nom incorrect \033[0m"
    fi

    # Vérification du démarrage auto
    cible="/etc/sysconfig/network"
    ligne1="NISDOMAIN=$DOMAIN_NIS"
    echo ""
    echo "- Vérificaton $cible"
    if  grep -q "$ligne1" $cible
    then
      echo -e "--- ligne: $ligne1 -- \033[32m trouvé \033[0m"
    else
      echo -e "--- ligne: $ligne1 -- \033[31m introuvable \033[0m"
    fi

else
    echo "Vérification: client"
    echo ""

    # Ping vers le serveur
    echo "- Ping vers le serveur"
    ping -c1  $SERVEUR_NIS 1>/dev/null
    if [ "$?" = 0 ]
    then
        echo -e "--- Ping vers $SERVEUR_NIS : \033[32m réussi \033[0m"
    else
        echo -e "--- Ping vers $SERVEUR_NIS : \033[31m échoué \033[0m"
    fi

    # Vérification du nom de domaine nis
    if [ $(nisdomainname) = $DOMAIN_NIS ]
    then
        echo -e "--- nom de domaine nis = $DOMAIN_NIS -- \033[32m nom correct \033[0m"
    else
        echo -e "--- nom de domaine nis = $(nisdomainname) -- \033[31m nom incorrect \033[0m"
    fi

    # Vérification du démarrage auto
    cible="/etc/sysconfig/network"
    ligne1="NISDOMAIN=$DOMAIN_NIS"
    echo ""
    echo "- Vérificaton $cible"
    if  grep -q "$ligne1" $cible
    then
      echo -e "--- ligne: $ligne1 -- \033[32m trouvé \033[0m"
    else
      echo -e "--- ligne: $ligne1 -- \033[31m introuvable \033[0m"
    fi

    # Vérification du bon serveur
    cible="/etc/yp.conf"
    ligne1="domain $DOMAIN_NIS server $SERVEUR_NIS"
    echo ""
    echo "- Vérificaton $cible"
    if  grep -q "$ligne1" $cible
    then
      echo -e "--- ligne: $ligne1 -- \033[32m trouvé \033[0m"
    else
      echo -e "--- ligne: $ligne1 -- \033[31m introuvable \033[0m"
    fi

     # On vérifie si ypbind est actif
    isActive=$(systemctl is-active ypbind.service)
    if [ $isActive = "active" ]
    then
        echo -e "--- ypbind.service -- \033[32m actif \033[0m"
    else
        echo -e "--- ypbind.service -- \033[31m stop \033[0m"
    fi

    # Vérification de nsswitch.conf
    cible="/etc/nsswitch.conf"
    ligne1="passwd: files nis"
    ligne2="group: files nis"
    ligne3="shadow: files nis"

    echo ""
    echo "- Vérificaton $cible"
    if  grep -q "$ligne1" $cible
    then
      echo -e "--- ligne: $ligne1 -- \033[32m trouvé \033[0m"
    else
      echo -e "--- ligne: $ligne1 -- \033[31m introuvable \033[0m"
    fi
    if  grep -q "$ligne2" $cible
    then
      echo -e "--- ligne: $ligne2 -- \033[32m trouvé \033[0m"
    else
      echo -e "--- ligne: $ligne2 -- \033[31m introuvable \033[0m"
    fi
    if  grep -q "$ligne3" $cible
    then
      echo -e "--- ligne: $ligne3 -- \033[32m trouvé \033[0m"
    else
      echo -e "--- ligne: $ligne3 -- \033[31m introuvable \033[0m"
    fi

fi
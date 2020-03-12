#!/bin/bash
. param
. functions 

# Le nombre d'argument n'est pas valide
if [ "$#" -ne 1 ]; then
 echo "Le nombre d'arguments est invalide"
fi

# Verification dans le fichier des machines 
if grep "$1" $MACHINE_LISTE
then

    # Récupération de l'interface réseau
    ip="$(grep $1 machines | cut -d ' ' -f 1)"
    # Configuration de l'adresse IP
    ifconfig $IF $ip  
    
    # Mise à jour de la configuration réseau   
    remove_line /etc/sysconfig/network-scripts/ifcfg-enp0s3 BOOTPROTO=
    remove_line /etc/sysconfig/network-scripts/ifcfg-enp0s3 IPADDR=
    remove_line /etc/sysconfig/network-scripts/ifcfg-enp0s3 GATEWAY=
    remove_line /etc/sysconfig/network-scripts/ifcfg-enp0s3 PREFIX=
    add_line /etc/sysconfig/network-scripts/ifcfg-enp0s3 BOOTPROTO=none 
    add_line /etc/sysconfig/network-scripts/ifcfg-enp0s3 IPADDR=$ip
    add_line /etc/sysconfig/network-scripts/ifcfg-enp0s3 GATEWAY=192.168.56.100
    add_line /etc/sysconfig/network-scripts/ifcfg-enp0s3 PREFIX=24

    # Configuration du DNS local
    while IFS= read -r line
    do
      ipActuel=$(echo $line | cut -d ' ' -f 1)
      nomActuel=$(echo $line | cut -d ' ' -f 2)
      remove_line /etc/hosts $ipActuel
      add_line /etc/hosts "$ipActuel  $nomActuel.$DOMAINE_IP   $nomActuel"
    done < "$MACHINE_LISTE"

    # Configuration du nom d'hôte 
    hostname $1
    ip="$(grep $1 $MACHINE_LISTE | cut -d ' ' -f 1)"   
    remove_line /etc/hosts $ip
    add_line /etc/hosts "$ip  $1.$DOMAINE_IP    $1"

else
    echo "Le nom de machine est invalide"
fi



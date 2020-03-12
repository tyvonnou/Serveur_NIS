#!/bin/bash
. param
. functions

echo ""
# Le nombre d'argument n'est pas valide
if [ "$#" -ne 1 ]; then
 echo "Usage: ./verify_network.sh <ping cible>"
 echo "Le nombre d'arguments est invalide"
fi

# Ping vers toutes les autres machine si serveur
if [ "$1" = "serveur" ]
then
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

# Sinon ping vers le serveur
else
  ping -c1  serveur 1>/dev/null
  if [ "$?" = 0 ]
  then
    echo -e "Ping vers serveur : \033[32m réussi \033[0m"
  else
    echo -e "Ping vers serveur : \033[31m échoué \033[0m"
  fi
fi

# Vérification de la configuration réseau
 echo ""
 echo "Vérification des variables réseau :"
varBOOTPROTO=$(grep BOOTPROTO /etc/sysconfig/network-scripts/ifcfg-enp0s3 | cut -d = -f 2)
if [ "$varBOOTPROTO" = "none" ]
then
  echo "Variable BOOTPROTO -> ok"
else
  echo "Variable BOOTPROTO -> pas bien configuré ($varBOOTPROTO au lieu de \"none\")"
fi

varGATEWAY=$(grep GATEWAY /etc/sysconfig/network-scripts/ifcfg-enp0s3 | cut -d = -f 2)
if [ "$varGATEWAY" = 192.168.56.100 ]
then
  echo "Variable GATEWAY -> ok"
else
  echo "Variable GATEWAY -> pas bien configuré ($varGATEWAY au lieu de \"192.168.56.100\")"
fi

varIPADDR=$(grep IPADDR /etc/sysconfig/network-scripts/ifcfg-enp0s3 | cut -d = -f 2)
if [ -z "$varPREFIX" ]
then
  echo "Variable IPADDR -> ok"
else
  echo "Variable IPADDR -> pas bien configuré ($varIPADDR ne peut pas être vide)"
fi

varPREFIX=$(grep PREFIX /etc/sysconfig/network-scripts/ifcfg-enp0s3 | cut -d = -f 2)
if [ "$varPREFIX" = 24 ]
then
  echo "Variable PREFIX -> ok"
else
  echo "Variable PREFIX -> pas bien configuré ($varPREFIX au lieu de \"24\")"
fi

echo ""

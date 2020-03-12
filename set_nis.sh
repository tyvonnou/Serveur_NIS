#!/bin/bash
. param
. functions
source "$(pwd)/spinner.sh"
# On récupére le nom de machine
hostname=$(hostname)

#############
# fonctions spécifiques au programe
#############

# Parametrage du domaine nis au démarrage
function startAutoNIS () {
	local cible="/etc/sysconfig/network"
 	# Suppression puis ajout
  	remove_line $cible "NISDOMAIN="
  	add_line $cible "NISDOMAIN=$DOMAIN_NIS"
}
# Mise à jour du domaine nis
function updateNIS () {
	nisdomainname $DOMAIN_NIS
}
# Activation d'un service
function startService () {
	# Lancement de la roulette de chargement
	start_spinner "Lancement de $1..."
 	# réupération de l'état du service donné en paramètre
	local isActive=$(systemctl is-active $1.service)
	case $isActive in
	  # Si le service est inconnue
		"unknown")
			 # On le démarre
			systemctl enable $1.service
			systemctl start $1.service
			;;
		# sinon si inactif ou mauvais démarrage
		"inactive" | "failed")
			# On active le service
			systemctl start $1.service
			;;
		"active")
	  	# Restart pour être à jour
			systemctl restart $1.service
			;;
	esac
	# Fin de la roulette de chargement
  stop_spinner $?
}

#############
# Programme
#############

# Partie exécuté si la machine est serveur
if [ $hostname = $SERVEUR_NIS ]
then
	# Arrêt du firewall
	systemctl stop firewalld.service
	# Démarrage de ypserv
	startService ypserv
  	# Mise à jour du domaine nis
  	updateNIS
  	# Parametrage du domaine nis au démarrage
  	startAutoNIS
  	# Initialisation de la base
	cd /var/yp
	echo "" | /usr/lib64/yp/ypinit -m
# Partie exécuté si la machine est non serveur
else
	# Mise à jour du domaine nis
  	updateNIS
	# Parametrage du domaine nis au démarrage
  	startAutoNIS
	# On donne le nom du serveur nis
	cibleYp="/etc/yp.conf"
	remove_line $cibleYp "domain $DOMAIN_NIS server $SERVEUR_NIS"
	add_line $cibleYp "domain $DOMAIN_NIS server $SERVEUR_NIS"
	# Start le service ypbind
	startService ypbind
    # Mise à jour de nsswitch.conf
	cibleNs="/etc/nsswitch.conf"
	# Suppression 2 fois car 2 fois dans le fichier 
	remove_line $cibleNs "passwd: "
	remove_line $cibleNs "group: "
	remove_line $cibleNs "shadow: "
	remove_line $cibleNs "passwd: "
	remove_line $cibleNs "group: "
	remove_line $cibleNs "shadow: "
	add_line $cibleNs "passwd: files nis"
	add_line $cibleNs "group: files nis"
	add_line $cibleNs "shadow: files nis"
	
fi

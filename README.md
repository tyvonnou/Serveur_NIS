# Serveur_NIS

Il s'agit ici de la réalisation d'un tp d'administration système.

## Configuration : set_nis.sh

Ce script sert à configurer les paramètres nis d'une machine.

### Prérequis

Avant d'executer le script il faut créer les fichiers **machines** et **param** contenant les éléments suivant :

```
$cat machines

192.168.56.101 serveur
192.168.56.102 client
192.168.56.103 esclave

```
Le fichier machines comprends le nom des machines et leur adresse IP associée.

```
$cat param

MACHINE_LISTE=machines
IF=enp0s3
DOMAINE_IP="ubo.local"

SERVEUR_NFS=serveur
EXPORT_HOME=/export/home
EXPORT_HOME_OPT=rw,no_root_squash
MOUNT_HOME=/home/serveur
MOUNT_HOME_OPT=hard,rw

EXPORT_APP=/export/opt
EXPORT_APP_OPT=ro
MOUNT_APP=/opt
MOUNT_APP_OPT=soft,ro

DOMAIN_NIS=dodo
SERVEUR_NIS=serveur
```
Le fichier param contient le chemin du fichier précédent, l'interface réseau à configurer et le nom de domaine.
Il contient également tout les paramètres nécéssaires à la mise en place des client/serveur NIS.

Il faut également une machine client et une machine serveur, mis en place grâce aux scripts du TP précédent.

***Serveur :***

```
sudo ./before/set_network.sh serveur
sudo ./before/verify_network.sh serveur
```

***Client :***

```
sudo ./before/set_network.sh client
sudo ./before/verify_network.sh client
```

## Utilisation
Le script doit être utilisé avec un utilisateur ayant les droit nécéssaires pour modifier les fichiers de configuration réseau de la machine.

***Serveur et Client :***
```
sudo ./set_nis
```

***Serveur et Client :***
```
sudo ./verify_nis
```

## Auteurs

* **Yvonnou Théo** - *Réalisation des scripts* - Master I TIIL-A

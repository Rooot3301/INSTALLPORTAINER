# Créer par ROOT3301 le 12/07/2024
# Script d'installation de portainer en bash sur un AlmaLinux


#!/bin/bash

# Fonction pour afficher les messages d'erreur
function error_message {
  echo "Erreur : $1"
  exit 1
}

# Mettre à jour le système
echo "Mise à jour du système..."
sudo dnf update -y || error_message "Échec de la mise à jour du système"

# Installer les paquets nécessaires
echo "Installation des paquets nécessaires..."
sudo dnf install -y yum-utils || error_message "Échec de l'installation de yum-utils"

# Ajouter le dépôt Docker
echo "Ajout du dépôt Docker..."
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo || error_message "Échec de l'ajout du dépôt Docker"

# Installer Docker
echo "Installation de Docker..."
sudo dnf install -y docker-ce docker-ce-cli containerd.io || error_message "Échec de l'installation de Docker"

# Démarrer et activer Docker
echo "Démarrage et activation de Docker..."
sudo systemctl start docker || error_message "Échec du démarrage de Docker"
sudo systemctl enable docker || error_message "Échec de l'activation de Docker au démarrage"

# Ajouter l'utilisateur actuel au groupe docker (optionnel)
echo "Ajout de l'utilisateur au groupe docker..."
sudo usermod -aG docker $USER || error_message "Échec de l'ajout de l'utilisateur au groupe docker"
newgrp docker

# Télécharger et exécuter le conteneur Portainer
echo "Création du volume Docker pour Portainer..."
sudo docker volume create portainer_data || error_message "Échec de la création du volume Docker pour Portainer"

echo "Téléchargement et exécution de Portainer..."
sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce || error_message "Échec du téléchargement et de l'exécution de Portainer"

# Afficher l'URL d'accès à Portainer
IP=$(hostname -I | awk '{print $1}')
if [ -z "$IP" ]; then
  error_message "Impossible de déterminer l'adresse IP du serveur"
else
  echo "Portainer est installé et fonctionne sur http://$IP:9000"
fi

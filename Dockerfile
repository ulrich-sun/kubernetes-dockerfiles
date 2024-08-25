# Utiliser une image de base qui supporte systemd
FROM ubuntu:20.04

# Copier les fichiers nécessaires
COPY kubelet.service /etc/systemd/system/kubelet.service
COPY kubernetes.repo /etc/yum.repos.d/kubernetes.repo
COPY daemon.json /etc/docker/daemon.json
COPY kubelet.env /etc/default/kubelet
COPY motd /etc/motd
COPY resolv.conf.override /etc/resolv.conf.override
COPY tokens.csv /etc/kubernetes/tokens.csv
COPY wrapkubeadm.sh /usr/local/bin/wrapkubeadm.sh

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

# Créer le répertoire pour les clés GPG
RUN mkdir -p -m 755 /etc/apt/keyrings

# Télécharger la clé GPG de Kubernetes
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Ajouter le dépôt Kubernetes
RUN echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

# Mettre à jour les dépôts et installer Docker et Kubernetes
RUN apt-get update && apt-get install -y \
    docker-ce-19.03.15 git \
    kubelet \
    kubeadm \
    kubectl \
    && apt-mark hold kubelet kubeadm kubectl

# Rendre le script wrapkubeadm.sh exécutable
RUN chmod +x /usr/local/bin/wrapkubeadm.sh

# Activer et démarrer Kubelet
CMD ["/usr/sbin/init"]

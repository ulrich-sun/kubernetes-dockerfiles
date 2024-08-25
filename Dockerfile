# Utiliser une image de base qui supporte systemd
FROM ubuntu:20.04

COPY kubelet.service /etc/systemd/system/kubelet.service
COPY kubernetes.repo /etc/yum.repos.d/kubernetes.repo
# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce \
    && apt-get install -y \
    kubelet=1.30.0-00 \
    kubeadm=1.30.0-00 \
    kubectl=1.30.0-00 \
    && apt-mark hold kubelet kubeadm kubectl

# Copier les fichiers de configuration
COPY daemon.json /etc/docker/daemon.json
COPY kubelet.env /etc/default/kubelet

COPY motd /etc/motd
COPY resolv.conf.override /etc/resolv.conf.override
COPY tokens.csv /etc/kubernetes/tokens.csv
COPY wrapkubeadm.sh /usr/local/bin/wrapkubeadm.sh

# Rendre le script exécutable
RUN chmod +x /usr/local/bin/wrapkubeadm.sh

# Activer et démarrer Kubelet
CMD ["/usr/sbin/init"]

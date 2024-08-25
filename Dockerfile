FROM centos:7

# Mettre à jour les dépôts
RUN sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
RUN sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
RUN sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo
RUN yum -y update

# Ajouter le dépôt Kubernetes
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yumrepos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg" > /etc/yum.repos.d/kubernetes.repo

# Installer les paquets nécessaires
RUN yum install -y kubectl kubeadm kubelet \
    && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
    && yum install -y docker-ce git bash-completion \
    && sed -i -e '4d;5d;8d' /lib/systemd/system/docker.service \
    && yum clean all

# Installer jq et docker-compose
RUN curl -Lf -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 \
    && curl -Lf -o /usr/bin/docker-compose https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) \
    && chmod +x /usr/bin/jq /usr/bin/docker-compose

VOLUME ["/var/lib/kubelet"]

# Copier les fichiers nécessaires
COPY ./kube* /etc/systemd/system/
COPY ./wrapkubeadm.sh /usr/local/bin/kubeadm
COPY ./tokens.csv /etc/pki/tokens.csv
COPY ./daemon.json /etc/docker/
COPY ./resolv.conf.override /etc/
COPY ./docker.service /usr/lib/systemd/system/
COPY ./.bashrc /root/
COPY motd /etc/motd

# Configuration de l'auto-complétion pour kubectl
RUN echo 'source <(kubectl completion bash)' >>~/.bashrc \
    && kubectl completion bash >> /etc/bash_completion.d/kubectl

# Configuration de kubelet
RUN mkdir -p /root/.kube && ln -s /etc/kubernetes/admin.conf /root/.kube/config \
    && rm -f /etc/machine-id

WORKDIR /root

CMD mount --make-shared / \
    && systemctl start docker \
    && systemctl start kubelet \
    && while true; do script -q -c "/bin/bash -l" /dev/null; done

FROM jenkins/jenkins:lts

MAINTAINER Alex Gonzalez <alex@lindusembedded.com>

USER root

# Non-interactive debconf package configuration
ARG DEBIAN_FRONTEND=noninteractive

# Add Debian repositories for docker and npm
RUN apt-get update && apt-get install -y lsb-release software-properties-common apt-transport-https ca-certificates gnupg2  && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && curl -sL https://deb.nodesource.com/setup_12.x | bash -

# Update Debian and Install Yocto Proyect Quick Start and Balena dependencies
RUN apt-get update && apt-get install -y locales gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm cpio curl python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa pylint3 xterm dos2unix vim sudo chrpath gawk docker-ce docker-ce-cli containerd.io nodejs npm jq && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && apt-get install -y file

# Set the locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.utf8 \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8

ARG DIND_COMMIT=52379fa76dee07ca038624d639d9e14f4fb719ff
ENV DOCKER_EXTRA_OPTS '--storage-driver=overlay'
RUN curl -fL -o /usr/local/bin/dind "https://raw.githubusercontent.com/moby/moby/${DIND_COMMIT}/hack/dind" && \
    chmod +x /usr/local/bin/dind
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

VOLUME /var/lib/docker
EXPOSE 2375

# Allow the jenkins user to run docker
RUN usermod -a -G docker jenkins

# Give the jenkins user sudo privileges
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set bash as default shell
RUN echo "dash dash/sh boolean false" | debconf-set-selections - && dpkg-reconfigure dash

# Install repo
RUN curl -o /usr/local/bin/repo http://commondatastorage.googleapis.com/git-repo-downloads/repo && chmod a+x /usr/local/bin/repo

USER jenkins

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

ENTRYPOINT ["/sbin/tini", "--", "entrypoint.sh"]

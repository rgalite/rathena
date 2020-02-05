FROM ubuntu:18.04

# Setup user
RUN apt update && apt -y install sudo
RUN useradd -m -s /bin/bash rathena
RUN usermod -aG sudo rathena
RUN echo "rathena ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER rathena

# Install binaries for compilation
RUN sudo apt update -y && sudo apt upgrade -y && \
    sudo apt install -y build-essential zlib1g-dev libpcre3-dev

# Install mariaDB
RUN sudo apt-get install -y software-properties-common && \
    sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc' && \
    sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.jaleco.com/mariadb/repo/10.4/ubuntu bionic main' && \
    sudo apt update -y && \
    sudo apt install -y mariadb-server && \
    sudo apt install -y libmariadb-dev libmariadb-dev-compat

# Building servers
RUN mkdir -p /home/rathena/rathena-server
WORKDIR /home/rathena/rathena-server
COPY --chown=rathena src ./src
COPY --chown=rathena 3rdparty ./3rdparty
COPY --chown=rathena configure Makefile.in ./
RUN ./configure --enable-packetver=20180620 && \
    make clean && \
    make server

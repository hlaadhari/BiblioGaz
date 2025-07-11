# Dockerfile pour Koha (exemple de base)
FROM debian:bullseye-slim

# Variables d'environnement
ENV KOHA_HOME=/app \
    PERL_CARTON_PATH=/app/local \
    KOHA_CONF=/app/etc/koha-conf.xml

# Installer les dépendances système
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        perl \
        carton \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        libgd-dev \
        libmagickwand-dev \
        libgraphicsmagick1-dev \
        libssl-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        libmariadb-dev-compat \
        libmariadb-dev \
        libdbd-mysql-perl \
        libyaz-dev \
        yaz \
        libfribidi-dev \
        git \
        curl \
        ca-certificates \
        make \
        gcc \
        && rm -rf /var/lib/apt/lists/*

# Créer le dossier de l'application
WORKDIR /app

# Copier le code source
COPY . /app

# Installer les modules Perl via carton si cpanfile existe
RUN if [ -f cpanfile ]; then carton install; fi

# Exposer le port de l'application
EXPOSE 5000

# Commande de démarrage (Plack via Starman)
CMD ["carton", "exec", "starman", "--workers", "2", "--listen", "0.0.0.0:5000", "app.psgi"] 
# Dockerfile pour Koha (exemple de base)
# Utiliser une image de base avec Perl pré-installé pour gagner du temps
FROM perl:5.34-bullseye

# Variables d'environnement
ENV KOHA_HOME=/app \
    PERL_CARTON_PATH=/app/local \
    KOHA_CONF=/app/etc/koha-conf.xml \
    DEBIAN_FRONTEND=noninteractive \
    CPAN_MIRROR=http://cpan.metacpan.org/ \
    PERL_MM_USE_DEFAULT=1

# Installer les dépendances système en une seule couche optimisée
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
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
        wget \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get clean

# Optimiser cpanm et installer Carton en parallèle
RUN cpanm --mirror $CPAN_MIRROR --notest --force \
        Path::Tiny \
        Module::CPANfile \
        CPAN::Meta::Check \
        File::pushd \
        App::Carton \
    && rm -rf /root/.cpanm

# Créer le dossier de l'application
WORKDIR /app

# Copier SEULEMENT le cpanfile pour optimiser le cache Docker
COPY cpanfile ./

# Installer les dépendances Perl (cette couche sera mise en cache)
RUN carton install --deployment --cached \
    && rm -rf /root/.cpanm \
    && find /app/local -name "*.pod" -delete \
    && find /app/local -name "*.3pm" -delete

# Copier le reste du code source (séparé pour optimiser le cache)
COPY . /app

# Exposer le port de l'application
EXPOSE 5000

# Commande de démarrage optimisée
CMD ["carton", "exec", "starman", "--workers", "2", "--listen", "0.0.0.0:5000", "app.psgi"] 
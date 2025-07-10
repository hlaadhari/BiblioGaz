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
        libdbi-perl \
        libdbd-mysql-perl \
        libxml-libxml-perl \
        libxml-simple-perl \
        libxml-sax-perl \
        libxml-sax-writer-perl \
        libdatetime-perl \
        libdatetime-format-mysql-perl \
        libyaml-libyaml-perl \
        libjson-xs-perl \
        libplack-perl \
        libapache2-mod-perl2 \
        libmojolicious-perl \
        libcache-memcached-perl \
        libgd-perl \
        libfont-ttf-perl \
        libtest-simple-perl \
        libtry-tiny-perl \
        libemail-sender-perl \
        libemail-stuffer-perl \
        libtest-nowarnings-perl \
        libtest-warn-perl \
        libtest-www-mechanize-perl \
        libtest-yaml-valid-perl \
        libtext-csv-xs-perl \
        libtext-iconv-perl \
        libtext-unidecode-perl \
        libuuid-perl \
        libwww-perl \
        libxml-libxslt-perl \
        libxml-rss-perl \
        libxml-writer-perl \
        libdigest-sha-perl \
        libclone-perl \
        libbusiness-isbn-perl \
        libbusiness-issn-perl \
        libauthen-cas-client-perl \
        libauth-googleauth-perl \
        libhtml-parser-perl \
        libhtml-scrubber-perl \
        libhtml-format-perl \
        libgd-barcode-perl \
        libgraphics-magick-perl \
        libgravatar-url-perl \
        libemail-address-perl \
        libemail-date-perl \
        libemail-messageid-perl \
        libemail-sender-perl \
        libemail-stuffer-perl \
        libexception-class-perl \
        libfile-slurp-perl \
        libfont-ttf-perl \
        libgd-barcode-perl \
        libgd-perl \
        libgit-wrapper-perl \
        libgraphics-magick-perl \
        libgravatar-url-perl \
        libhtml-format-perl \
        libhtml-parser-perl \
        libhtml-scrubber-perl \
        libtest-strict-perl \
        libtest-warn-perl \
        libtest-www-mechanize-perl \
        libtest-yaml-valid-perl \
        libtext-bidi-perl \
        libtext-csv-encoded-perl \
        libtext-csv-perl \
        libtext-csv-xs-perl \
        libtext-iconv-perl \
        libtext-pdf-perl \
        libtext-unidecode-perl \
        libtime-fake-perl \
        libtry-tiny-perl \
        libuniversal-can-perl \
        libuniversal-require-perl \
        liburi-perl \
        libuuid-perl \
        libwebservice-ils-perl \
        libwww-csrf-perl \
        libwww-perl \
        libxml-dumper-perl \
        libxml-libxml-perl \
        libxml-libxslt-perl \
        libxml-rss-perl \
        libxml-sax-perl \
        libxml-sax-writer-perl \
        libxml-simple-perl \
        libxml-writer-perl \
        libyaml-libyaml-perl \
        git \
        curl \
        ca-certificates \
        make \
        gcc \
        libssl-dev \
        libexpat1-dev \
        libz-dev \
        libbz2-dev \
        liblzma-dev \
        libpq-dev \
        libmariadb-dev-compat \
        libmariadb-dev \
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
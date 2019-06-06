FROM ubuntu:18.04

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y apache2 libapache2-mod-wsgi-py3 --no-install-recommends \
    && a2enmod wsgi \
    && cd /usr/local/bin ; ln -s /usr/bin/python3 python

# Need to get up to date pip
RUN apt-get install -y wget python3-pip python3-setuptools  libcurl4-openssl-dev  libssl-dev python3-dev gcc --no-install-recommends \
    && wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py' \
    && python get-pip.py --disable-pip-version-check --no-cache-dir \
    && pip --version \
    && rm -f get-pip.py

COPY 000-internal.conf /etc/apache2/sites-available/000-internal.conf
RUN a2ensite 000-internal \
    && rm -rf /etc/apache2/sites-available/000-default.conf \
    && rm -rf /etc/apache2/sites-enabled/000-default.conf \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 80

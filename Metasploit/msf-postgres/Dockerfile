FROM ruby:2.4

ENV REFRESHED_AT "2017-07-26 00:00:00"
ENV MSF_DIR /metasploit-framework/

RUN set -ex \
    && apt-get -qq update \
    && apt-get -y install \
        autoconf \
        bison \
        build-essential \
        curl \
        git-core \
        libapr1 \
        libaprutil1 \
        libcurl4-openssl-dev \
        libgmp3-dev \
        libpcap-dev \
        libpq-dev \
        libreadline6-dev \
        libsqlite3-dev \
        libssl-dev \
        libsvn1 \
        libtool \
        libxml2 \
        libxml2-dev \
        libxslt-dev \
        libyaml-dev \
        locate \
        ncurses-dev \
        openssl \
        wget \
        xsel \
        zlib1g \
        zlib1g-dev \

    && mkdir "$MSF_DIR"


## Start of postgres installing (Copy from the official Dockerfile)

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -ex \
    && groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres \
    && apt-get -qq update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apt-get purge -y --auto-remove wget \
    && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && key='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" \
    && gpg --export "$key" > /etc/apt/trusted.gpg.d/postgres.gpg \
    && rm -rf "$GNUPGHOME"

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
ENV LANG en_US.utf8

ENV PG_MAJOR 9.6
ENV PG_VERSION 9.6.3-1.pgdg80+1
ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data

RUN set -ex \
    && echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list \
    && apt-get -qq update \
    && apt-get install -y postgresql-common \
    && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
    && apt-get install -y \
		postgresql-$PG_MAJOR=$PG_VERSION \
		postgresql-contrib-$PG_MAJOR=$PG_VERSION \
    && rm -rf /var/lib/apt/lists/* \
    && mv -v /usr/share/postgresql/$PG_MAJOR/postgresql.conf.sample /usr/share/postgresql/ \
    && ln -sv ../postgresql.conf.sample /usr/share/postgresql/$PG_MAJOR/ \
    && sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/postgresql.conf.sample \
    && mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql \
    && mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA" # this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)

VOLUME /var/lib/postgresql/data
## End of postgres installing


WORKDIR $MSF_DIR
VOLUME /root/.msf4
VOLUME /root/.msf5
ENV PATH $PATH:$MSF_DIR

RUN set -ex \
    && git clone --depth=1 https://github.com/rapid7/metasploit-framework.git $MSF_DIR \
    && cd $MSF_DIR \
    && git remote add upstream https://github.com/rapid7/metasploit-framework.git \
    && git config --global user.name "msf" \
    && git config --global user.email "msf@example.com" \
    && bundle install


COPY docker-msf-entrypoint.sh /usr/local/bin/
RUN set -ex \
    && chmod a+x /usr/local/bin/docker-msf-entrypoint.sh \
    && ln -s /usr/local/bin/docker-msf-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-msf-entrypoint.sh"]

EXPOSE 80 8080 443 4444

CMD ["msfconsole"]

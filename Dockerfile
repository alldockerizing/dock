FROM ubuntu:latest

ENV TZ 'Europe/Kiev'
ENV PGVERSION 10
ENV PGDATA /opt/db/
ENV NODEVERSION 10

#--------------------- Installs Reis, PostgreSQL, Node.js and Updates the system-------------------------------
SHELL ["/bin/bash", "-c"]
RUN set -o pipefail && apt-get update && apt-get -y upgrade &&\
    apt-get install -y git curl jq software-properties-common wget &&\
    curl -sL https://deb.nodesource.com/setup_$NODEVERSION.x | bash - &&\
    add-apt-repository -y -u ppa:chris-lea/redis-server &&\
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release --codename --short)-pgdg main" > /etc/apt/sources.list.d/pgdg.list &&\
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone &&\
    apt-get update && apt-get install --yes nodejs redis-server postgresql{,-client,-contrib}-$PGVERSION &&\
    sed -i 's/peer/password/g' /etc/postgresql/10/main/pg_hba.conf && sed -i 's/md5/password/g' /etc/postgresql/10/main/pg_hba.conf &&\
    mkdir /opt/db/ && chown postgres:postgres /opt/db/ &&\
    npm i npm@latest -g && npm i jest -g

#---------------------- Initializes PostgreSQL DB, Creates the User, DB and grants access -------------------------------
USER postgres
RUN /usr/lib/postgresql/$PGVERSION/bin/pg_ctl initdb &&\
    /usr/lib/postgresql/$PGVERSION/bin/pg_ctl start &&\ 
    /usr/bin/psql -h 127.0.0.1 --command "CREATE USER tera WITH SUPERUSER PASSWORD 'tera';" \
                               --command "CREATE DATABASE tera_id OWNER tera;" \
                               --command "GRANT ALL PRIVILEGES ON DATABASE tera_id to tera;"


USER root
WORKDIR /opt/app
RUN git clone https://github.com/taniarascia/node-api-postgres.git . &&\ 
    npm install --no-optional && npm cache clean --force


CMD redis-server &  su postgres -c "/usr/lib/postgresql/$PGVERSION/bin/pg_ctl start" &&  node ./index.js & sleep 50 && exit 0

#RUN redis-server --version
#RUN /usr/bin/psql --version
#RUN node --version && npm --version && jest --version
#RUN cat /etc/postgresql/10/main/pg_hba.conf && ls -l /opt



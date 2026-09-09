FROM ruby:3.4.9

ENV LANG=C.UTF-8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y ca-certificates curl gnupg

RUN set -ex \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    export NODE_MAJOR=22; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -qq && apt-get install -y -qq --no-install-recommends nodejs

# Install postgresql-client
# https://www.postgresql.org/download/linux/ubuntu/
RUN set -ex \
    && apt-get install -y postgresql-common \
    && /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y \
    && apt-get install postgresql-client-18 -y

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v '2.3.26' && \
    gem install rerun

COPY . /app

RUN cd /app && bundle install

RUN rm -rf /app

ENTRYPOINT bash -c 'cd /app && bundle exec rake'

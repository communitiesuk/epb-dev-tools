FROM ruby:3.4.9

ENV LANG=C.UTF-8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y ca-certificates curl gnupg

# Install postgresql-client
# https://www.postgresql.org/download/linux/ubuntu/
RUN set -ex \
    && apt-get install -y postgresql-common \
    && /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y \
    && apt-get install postgresql-client-18 -y

# Install node
# https://nodesource.com/products/distributions
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v '2.3.26' && \
    gem install rerun

COPY . /app

RUN cd /app && bundle install

RUN rm -rf /app

ENTRYPOINT bash -c 'cd /app && bundle exec rake'

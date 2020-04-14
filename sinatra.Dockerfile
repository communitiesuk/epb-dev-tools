FROM ruby:2.6.5-stretch

ENV LANG=en_GB.UTF-8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -; \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list; \
    apt-get update -qq && apt-get install -qq --no-install-recommends nodejs yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v '2.1.4' && \
    gem install rerun

COPY . /app

RUN cd /app && bundle install

RUN rm -rf /app

EXPOSE 80

ENTRYPOINT bash -c 'cd /app && bundle exec rackup -p 80 -o 0.0.0.0'

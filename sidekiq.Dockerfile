FROM ruby:3.1.2

ENV LANG=en_GB.UTF-8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -; \
    apt-get update -qq && apt-get install -qq --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v '2.3.22' && \
    gem install rerun

COPY . /app

RUN cd /app && bundle install

RUN rm -rf /app

ENTRYPOINT bash -c 'cd /app && bundle exec sidekiq -r ./sidekiq/config.rb'

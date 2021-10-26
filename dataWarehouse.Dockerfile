FROM ruby:2.7.3

ENV LANG=en_GB.UTF-8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -; \
    apt-get update -qq && apt-get install -qq --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v '2.2.21' && \
    gem install rerun

COPY . /app

RUN cd /app && bundle install

RUN rm -rf /app

ENTRYPOINT bash -c 'cd /app && bundle exec ruby app.rb'
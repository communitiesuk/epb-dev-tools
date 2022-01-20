FROM ruby:2.7.5

ENV LANG=en_GB.UTF-8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -; \
    apt-get update -qq && apt-get install -qq --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v '2.2.32' && \
    gem install rerun

COPY . /app

RUN cd /app && bundle install

RUN rm -rf /app

EXPOSE 80

ENTRYPOINT bash -c 'cd /app && bundle exec rackup -p 80 -o 0.0.0.0'

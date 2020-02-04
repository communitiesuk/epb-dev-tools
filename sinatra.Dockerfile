FROM ruby:2.6-stretch

ENV LANG=en_GB.UTF-8

RUN gem install bundler -v '2.1.4' && \
    gem install rerun

COPY . /app

RUN cd /app && bundle install

RUN rm -rf /app

EXPOSE 80

ENTRYPOINT bash -c 'cd /app && bundle exec rackup -p 80 -o 0.0.0.0'

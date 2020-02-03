FROM ruby:2.6-stretch

ENV LANG=C.UTF-8

RUN gem install bundler -v '2.1.4'

COPY . /app

RUN cd /app && bundle install

RUN rm -rf /app

EXPOSE 80

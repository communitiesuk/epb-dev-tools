FROM ruby:4.0-slim

WORKDIR /app

RUN gem install sinatra -v 3.1.0
RUN gem install webrick

COPY kms_mock.rb .

EXPOSE 4567

CMD ["ruby", "kms_mock.rb"]

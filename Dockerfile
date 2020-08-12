FROM ruby:2.6.5

# RUN apt-get update && apt-get install -y \
#       bash \
#       ca-certificates \
#       wget \
#       unzip

WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install --jobs 5

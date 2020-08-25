FROM ruby:2.6.5

# RUN apt-get update && apt-get install -y \
#       bash \
#       ca-certificates \
#       wget \
#       unzip
RUN apt-get update -qq && apt-get install -y locales -qq && locale-gen en_US.UTF-8 en_us && locale-gen C.UTF-8 && /usr/sbin/update-locale LANG=C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install --jobs 5

COPY . .
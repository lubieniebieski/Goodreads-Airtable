FROM ruby:2.7-alpine

RUN apk update && apk add build-base

RUN mkdir /app

WORKDIR /app

COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock

RUN bundle install


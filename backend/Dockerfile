FROM ruby:3.2.0-slim

RUN apt-get update && apt-get install -y \
	build-essential \
	libpq-dev \
	netcat-openbsd \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install bundler

COPY Gemfile* ./

RUN bundle install

COPY . .

EXPOSE 4567

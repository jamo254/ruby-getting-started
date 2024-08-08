FROM ruby:3.2.4-slim-bullseye

RUN apt-get update -qq \
    && apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    cron \
    git \
    && rm -rf /var/lib/apt/lists/*

ARG BUILD_TYPE=development
ENV BUILD_TYPE ${BUILD_TYPE}

WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN gem install bundler -v 2.5.9

ADD docker/bundle-install.sh /usr/local/bin/bundle-install
RUN chmod +x /usr/local/bin/bundle-install
RUN bundle-install

ENV WEB_PORT 3000

COPY . /app

#Symlink the cron log to our main PID output devices
RUN ln -sf /proc/1/fd/1 /var/log/stdout \
    && ln -sf /proc/1/fd/1 /var/log/stderr

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

EXPOSE $WEB_PORT

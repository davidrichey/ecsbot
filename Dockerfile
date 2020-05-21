FROM bitwalker/alpine-elixir:1.8.2 as builder

ADD . /app

WORKDIR /app

ENV MIX_ENV=prod REPLACE_OS_VARS=true

RUN mix do deps.get, deps.compile, release

###############################################
FROM alpine:3.9.3

RUN apk add --no-cache bash

RUN apk add --no-cache \
      ca-certificates \
      openssl \
      ncurses-libs \
      zlib

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/ecsbot/releases/0.1.0/ecsbot.tar.gz /app

ENV MIX_ENV=prod REPLACE_OS_VARS=true

RUN tar -xzf ecsbot.tar.gz; rm ecsbot.tar.gz

CMD bin/ecsbot foreground

################## BASE ##################
FROM elixir:1.10.4-alpine as base

# Set working directory
WORKDIR /opt/app

# Install build tools
RUN apk --no-cache add \
  build-base

# Install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

################## DEV ##################
FROM base as dev

# Install development-only system dependencies
RUN apk --no-cache add \
  inotify-tools \
  npm

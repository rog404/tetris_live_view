# Base image
FROM elixir:1.14-alpine

# Creating directory
WORKDIR /app

# Installing package manager
RUN mix local.hex --force && \
    mix local.rebar --force

# Copying everything
COPY . .

# Installing dependencies
RUN mix do deps.get, deps.compile

# Executing server
CMD ["mix", "phx.server"]

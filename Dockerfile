FROM bitwalker/alpine-elixir:1.8.1 as builder
ENV MIX_ENV test
RUN apk upgrade && \
    apk --no-cache --update upgrade alpine-sdk && \
    apk --no-cache add alpine-sdk && \
    rm -rf /var/cache/**/*
COPY . /app
WORKDIR /app
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get
RUN MIX_ENV=prod mix distillery.release

FROM alpine:3.9
ENV REPLACE_OS_VARS=true
RUN apk upgrade && \
    apk add --no-cache bash openssl && \
    rm -rf /var/cache/**/*
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/push_gateway_generator/ .
ENV PORT=4000
EXPOSE ${PORT}
CMD ["bin/push_gateway_generator", "foreground"]

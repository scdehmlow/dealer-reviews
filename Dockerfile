FROM elixir:1.12 as build-env
COPY . ./app
WORKDIR /app

# set build ENV
ENV MIX_ENV=prod

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix escript.build

# use a smaller image for running the executable
FROM elixir:1.12-slim
WORKDIR /app
COPY --from=build-env /app/dealer_reviews .
ENTRYPOINT [ "./app/dealer_reviews" ]

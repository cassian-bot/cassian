# Stage to build the correct version of dependecies:

# * Elixir
# * Erlang

FROM alpine:3.19.0 AS builder

RUN apk update && \
    apk upgrade && \
    apk add curl git unzip \
    gcc autoconf automake ncurses-dev \
    bash make g++ openssl-dev

RUN adduser -gD cassian --disabled-password

# Building Erlang/Elixir

WORKDIR /build

COPY .tool-versions .

RUN chown -R cassian:cassian /build

USER cassian

RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1;

RUN /bin/bash -c 'echo -e "\n\n## Configure ASDF \n. $HOME/.asdf/asdf.sh" >> ~/.bashrc'

RUN /bin/bash -c 'echo -e "\n\n## ASDF Bash Completion: \n. $HOME/.asdf/completions/asdf.bash" >> ~/.bashrc';

ENV PATH="$PATH:/home/cassian/.asdf/bin:/home/cassian/.asdf/shims"

RUN asdf plugin add elixir

RUN asdf plugin add erlang

RUN asdf install

# Building the application

RUN mix local.hex --force

COPY mix.exs        .

COPY mix.lock       .

COPY config         ./config

COPY lib            ./lib

COPY .formatter.exs .

RUN mix deps.get

RUN mix deps.compile

RUN mix release

# Actual app stage

FROM alpine:3.19.0 AS cassian-app

RUN adduser -D cassian --disabled-password

RUN apk update

RUN apk upgrade

RUN apk add ffmpeg youtube-dl

USER cassian

WORKDIR /app

COPY --from=builder /build/_build/dev/rel/cassian /app/cassian

CMD ["/app/cassian/bin/cassian", "start"]
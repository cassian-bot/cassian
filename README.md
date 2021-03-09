# Artificer

![Artificer Banner](https://i.imgur.com/yuFUI9F.jpg)
A Magical Bot for Discord Music

![Server count](https://img.shields.io/endpoint?url=https%3A%2F%2Fartificer.gigalixirapp.com%2Fapi%2Fshields%2Fguilds) ![Elixir version](https://img.shields.io/endpoint?url=https%3A%2F%2Fartificer.gigalixirapp.com%2Fapi%2Fshields%2Fsystem)

Note: The main image for the bot is from [here](https://www.artstation.com/artwork/v10g8x) and belongs to [Otto Metzger](https://ottometzger.artstation.com/) so do support their art!

## Table of contents

- [About](##about)
- [Note regarding Nostrum](##note-regarding-nostrm)
- [Note regarding the web part](##note-regarding-the-web-part)
- [System requirements](##system-requirements)
- [Configuration](##configuration)
- [Up 'n' runnin'](##up-'n'-runnin')
- [Deploy to Gigalixir](##deploy-to-gigalixir)

## About

The bot is written in Elixir, a functional programming language based upon Erlang. It has great performance and maintainability in live environments.

The Discord library is [Nostrum](https://github.com/Kraigie/nostrum), written in Elixir and supporting everything from events to voice channels.

## Note regarding Nostrum

As of now the Hex release of Nostrum `v0.4.6` is a bit buggy so the current version of this bot uses the nightly version of Nostrum.

## Note regarding the web part

This is deprecated. It will be removed once a web app has been created because I don't want to add web functionality to the bot.

## System requirements

### Voice requirements

This bot needs `youtube-dl` and `ffmpeg` in order to play music. The path of them can be set with `FFMPEG_PATH` and `YTDL_PATH` accordingly. If they are not set they will fallback to `/usr/bin/ffmpeg/` and `/usr/bin/youtube-dl` accordingly. So if your `whereis <name>` returns those two, you don't need to worry about them.

### General bot requirements

Of course as this is written in Elixir, you will need Elixir installed. This can be easily done on Debian-based distros:

```bash
sudo apt-get install elixir
```

After installing Elixir you should be able to see the version:

```bash
Erlang/OTP 23 [erts-11.1.7] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Elixir 1.11.2 (compiled with Erlang/OTP 23)
```

Try to keep the Elixir version `1.11.2` and up.

## Configuration

To set the bot up-and-running you will need to set a couple of variables.

Here's the basic configuration:

```elixir
use Mix.Config
config :porcelain,
  driver: Porcelain.Driver.Basic

config :nostrum,
  ffmpeg: System.get_env("FFMPEG_PATH") || "/usr/bin/ffmpeg",
  youtubedl: System.get_env("YTDL_PATH") || "/usr/bin/youtube-dl",
  token: System.get_env("DISCORD_BOT_TOKEN"),
  num_shards: :auto

config :artificer,
  prefix: System.get_env("DEFAULT_BOT_PREFIX"),
  web_enabled: System.get_env("WEB_ENABLED"),
  port: System.get_env("PORT") || "4000",
  force_ssl: System.get_env("FORCE_SSL")
```

Two required configs are `DISCORD_BOT_TOKEN` and `DEFAULT_BOT_PREFIX`.

**[Depracation warning](##note-regarding-the-web-part)**

You can start a small `plug_cowboy` server via `web_enabled`. This is used for shields.io. If `web_enabled` is set to false you don't have to worry about anything below it else just set the port or use the standard `4000` one. `force_ssl` is there to, well, enforce SSL on request. This is meant more for services which give you certs like Heroku or [Gigalixir](##deploy-to-gigalixir).

## Up 'n' runnin'

To start the app, once you have done everything you can just run:

Interactive console for debugging:

```bash
iex -S mix
```

Standard start without a console:

```bash
mix --no-halt
```

## Deploy to Gigalixir

**Note**: As Heroku as the same config of buildpacks as Gigalixir, this could theoretically be deployed on Heroku the same way.

Gigalixir uses buildpacks just like Heroku. Currently the bot has buildpacks set and it is almost ready to be deployed. You'll just have to set a couple of variables. It's easy to set them. You can either set them via the the panel on Gigalixir or:

```bash
gigalixir config:set FFMPEG_PATH=/app/vendor/ffmpeg/ffmpeg
gigalixir config:set YTDL_PATH=/app/vendor/youtube-dl/bin/youtube-dl
gigalixir config:set DEFAULT_BOT_PREFIX=${YOUR BOT PREFIX}
gigalixir config:set DISCORD_BOT_TOKEN=${YOUR BOT TOKEN}
gigalixir config:set WEB_ENABLED=${WEB ENABLED} # If you want to use the endpoints...
gigalixir config:set FORCE_SSL=${FORCE SSL} # Make all Gigalixir request use HTTPS/SSL
```

After that just do:

```bash
git push gigalixir
```

And you should be up 'n' runnin'!

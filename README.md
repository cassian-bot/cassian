# Artificer

![Artificer Banner](https://raw.githubusercontent.com/zastrixarundell/artificer-bot/master/static_files/artificer-big-banner.jpg)
A Magical Bot for Discord Music

Note: The main image for the bot is from [here](https://www.artstation.com/artwork/v10g8x) and belongs to [Otto Metzger](https://ottometzger.artstation.com/) so do support their art!

## About

The bot is written in Elixir, a functional programming language based upon Erlang. It has great performance and maintainability in live environments.

The Discord library is [Nostrum](https://github.com/Kraigie/nostrum), written in Elixir and supporting everything from events to voice channels.

## Note regarding Nostrum

As of now the Hex release of Nostrum `v0.4.6` is a bit buggy so the current version of this bot uses the nightly version of Nostrum.

## Note regarding the web part

This is deprecated. It will be removed once a webb app has been created because I don't want to add web functionality to the bot.

## System requirements

### Voice requirements

This bot needs `youtube-dl` and `ffmpeg` in order to play music. The path of them can be set with `FFMPEG_PATH` and `YTDL_PATH` accordingly. If they are not set they will back to `/usr/bin/ffmpeg/` and `/usr/bin/youtube-dl` accordingly. So if your `whereis <name>` returns those two, you don't need to worry about them.

### General bot requirements

Of course as this is written in Elixir, you will need Elixir and the BEAM systme installed. This can be easyly done on Debian-based distros:

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
  web_enabled: System.get_env("WEB_ENABLED") == "true",
  port: System.get_env("BOT_PORT") || 4000,
  force_https: System.get_env("FORCE_HTTPS") == "true",
  cert_key: System.get_env("CERTFILE_KEY"),
  cert: System.get_env("CERTFILE")
```

Two required configs are `DISCORD_BOT_TOKEN` and `DEFAULT_BOT_PREFIX`.

**[Depracation warning](##note-regarding-the-web-part)**

You can enable or disable `web_enabled`. They are used for some endpoints and the reason can be found [here](###https-certs). If `web_enabled` is set to false you don't have to worry about anything below it. Everything under `port` is regarding SSL/HTTPS.

## HTTPS certs

**[Depracation warning](##note-regarding-the-web-part)**

Currently the bot has endpoints for `shields.io` using `:plug_cowboy`. Shields.io requires you to use HTTPs, for that reason you should have a cert file. TO generate a cert file you can do:

```bash
mix x509.gen.selfsigned
```

And you will generate a selfcert files under `/priv/cert`. You can use them to start the endpoints in https.

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

defmodule Cassian.Managers.QueueManager do
  @moduledoc """
  Manager for queues.
  """

  alias Cassian.Servers.{Queue, VoiceState}
  alias Cassian.Utils.Voice

  def insert!(guild_id, channel_id, metadata) do
    Queue.insert!(guild_id, metadata)

    VoiceState.get!(guild_id)
    |> Map.put(:channel_id, channel_id)
    |> notify_enqueued(metadata)
    |> VoiceState.put()
  end

  def clear!(guild_id) do
    Queue.delete(guild_id)
  end

  def play_if_needed(guild_id) do
    state = VoiceState.get!(guild_id)

    if state.status == :noop and Queue.exists?(guild_id) do
      unless Queue.show(guild_id) == [] do
        metadata = Queue.pop!(guild_id)
        Voice.play_when_ready!(metadata.youtube_link, guild_id)

        notifiy_playing(state.channel_id, metadata)

        state
        |> Map.put(:metadata, metadata)
        |> Map.put(:status, :playing)
        |> VoiceState.put()
      else
        Queue.delete(guild_id)
      end
    end
  end

  def notify_enqueued(state, metadata) do
    unless state.status == :noop do
      alias Cassian.Utils.Embed, as: EmbedUtils
      alias Nostrum.Struct.Embed

      embed =
        EmbedUtils.create_empty_embed!()
        |> EmbedUtils.put_color_on_embed(metadata.provider_color)
        |> Embed.put_url(metadata.youtube_link)
        |> Embed.put_title("Enqueued: #{metadata.title}")

      Nostrum.Api.create_message(state.channel_id, embed: embed)
    end

    state
  end

  def notifiy_playing(channel_id, metadata) do
    alias Cassian.Utils.Embed, as: EmbedUtils
    alias Nostrum.Struct.Embed

    embed =
      EmbedUtils.create_empty_embed!()
      |> EmbedUtils.put_color_on_embed(metadata.provider_color)
      |> Embed.put_url(metadata.youtube_link)
      |> Embed.put_title("Now playing: #{metadata.title}")

    Nostrum.Api.create_message(channel_id, embed: embed)
  end
end

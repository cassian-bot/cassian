defmodule Cassian.Managers.QueueManager do
  @moduledoc """
  Manager for queues.
  """

  alias Cassian.Servers.{Queue, VoiceState}
  alias Cassian.Utils.Voice
  alias Cassian.Managers.MessageManager

  @doc """
  Insert metadata into the queue.
  """
  def insert!(guild_id, channel_id, metadata) do
    Queue.insert!(guild_id, metadata)

    VoiceState.get!(guild_id)
    |> Map.put(:channel_id, channel_id)
    |> notify_enqueued(metadata)
    |> VoiceState.put()
  end

  @doc """
  Clear/delete the queue for a guild_id.
  """
  def clear!(guild_id) do
    Queue.delete(guild_id)
  end

  @doc """
  Play a song if needed. Deletes the queue if it determines
  it should.
  """
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

  @doc """
  Notify state a song is enqueued. Will be moved.
  """
  def notify_enqueued(state, metadata) do
    unless state.status == :noop do
      alias Cassian.Utils.Embed, as: EmbedUtils
      alias Nostrum.Struct.Embed

      embed =
        EmbedUtils.create_empty_embed!()
        |> EmbedUtils.put_color_on_embed(metadata.provider_color)
        |> Embed.put_url(metadata.youtube_link)
        |> Embed.put_title("Enqueued: #{metadata.title}")

      MessageManager.send_dissapearing_embed(embed, state.channel_id)
    end

    state
  end

  @doc """
  Notify that a song is currently playing. Will be moved.
  """
  def notifiy_playing(channel_id, metadata) do
    alias Cassian.Utils.Embed, as: EmbedUtils
    alias Nostrum.Struct.Embed

    embed =
      EmbedUtils.create_empty_embed!()
      |> EmbedUtils.put_color_on_embed(metadata.provider_color)
      |> Embed.put_url(metadata.youtube_link)
      |> Embed.put_title("Now playing: #{metadata.title}")

    MessageManager.send_dissapearing_embed(embed, channel_id)
  end
end

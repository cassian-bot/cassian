defmodule Cassian.Managers.PlayManager do
  @moduledoc """
  Manager for queues.
  """

  alias Cassian.Structs.{VoiceState, Playlist}
  alias Cassian.Utils.Voice
  alias Cassian.Utils.Embed, as: EmbedUtils
  alias Cassian.Managers.MessageManager
  alias Nostrum.Struct.{Message, Embed}

  @doc """
  Add a song to the playlist.
  """
  def insert!(guild_id, channel_id, metadata) do
    Playlist.insert!(guild_id, metadata)

    VoiceState.get!(guild_id)
    |> Map.put(:channel_id, channel_id)
    |> notify_enqueued(metadata)
    |> VoiceState.put()
  end

  @doc """
  """
  def alter_index(guild_id) do
    case Playlist.show(guild_id) do
      {:ok, playlist} ->
        index = playlist.index + if playlist.reverse, do: -1, else: 1

        playlist
        |> Map.put(:index, index)
        |> Playlist.put()
      {:error, :noop} ->
        nil
    end
  end

  # Keep the index in bounds, loops around.
  defp keep_in_bounds(index, ordered) do
    size = length(ordered)
    index = if index >= size, do: 0, else: index
    if index < 0, do: size - 1, else: index
  end

  @doc """
  Clear/delete the queue for a guild_id.
  """
  def clear!(guild_id) do
    Playlist.delete(guild_id)
  end

  @doc """
  Play a song if needed. Deletes the queue if it determines
  it should.
  """
  def play_if_needed(guild_id) do
    state = VoiceState.get!(guild_id)

    if state.status == :noop and Playlist.exists?(guild_id) do
      case Playlist.show(guild_id) do
        {:ok, playlist} ->
          {index, ordered} = Playlist.order_playlist(playlist)

          index = keep_in_bounds(index, ordered)

          metadata = Enum.at(ordered, index)

          Voice.play_when_ready!(metadata.youtube_link, guild_id)

          notifiy_playing(state.channel_id, metadata)

          state
          |> Map.put(:status, :playing)
          |> VoiceState.put()

        _ ->
          nil
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
  Notify that a song is currently playing.
  """
  def notifiy_playing(channel_id, metadata) do
    alias Cassian.Utils.Embed, as: EmbedUtils
    alias Nostrum.Struct.Embed

    embed =
      EmbedUtils.create_empty_embed!()
      |> EmbedUtils.put_color_on_embed(metadata.provider_color)
      |> Embed.put_url(metadata.youtube_link)
      |> Embed.put_title("Now playing: #{metadata.title}")

    case MessageManager.send_embed(embed, channel_id) do
      {:ok, message} ->
        MessageManager.add_control_reactions(message)
      _ ->
        nil
    end
  end

  #

  @doc """
  Change the direction of the playlist. Safely return if this is done.
  """
  @spec change_direction(guild_id :: Snowflake.t(), reverse :: boolean()) :: :ok | :noop
  def change_direction(guild_id, reverse) do
    case Playlist.show(guild_id) do
      {:ok, playlist} ->
        playlist
        |> Map.put(:reverse, reverse)
        |> Playlist.put()
        :ok

      {:error, :noop} ->
        :noop
    end
  end

  @doc """
  Chaange the direction of the playlist and send a notification.
  """
  @spec change_direction_with_notification(message :: %Message{}, reverse :: boolean()) :: :ok | :noop
  def change_direction_with_notification(message, reverse) do
    title_part = if reverse, do: "in reverse", else: "normally"

    case change_direction(message.guild_id, reverse) do
      :ok ->
        EmbedUtils.create_empty_embed!()
        |> Embed.put_title("Playing #{title_part}.")
        |> Embed.put_description("The current playlist will play #{title_part}")

      :noop ->
        EmbedUtils.generate_error_embed(
          "There is no playlist.",
          "I can't change the direction of the playlist if it doesn't exist."
        )
    end
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end
end

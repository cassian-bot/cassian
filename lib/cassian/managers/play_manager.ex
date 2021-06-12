defmodule Cassian.Managers.PlayManager do
  @moduledoc """
  Manager for playing and stopping music.
  """

  alias Cassian.Structs.{VoiceState, Playlist}
  alias Cassian.Utils.Voice
  alias Cassian.Utils.Embed, as: EmbedUtils
  alias Cassian.Managers.{MessageManager, PlaylistManager}
  alias Nostrum.Struct.{Message, Embed}

  defdelegate in_bound?(index, ordered), to: PlaylistManager
  defdelegate keep_in_bounds(index, ordered), to: PlaylistManager

  @doc """
  Play a song if needed. Deletes the queue if it determines
  it should.
  """
  def play_if_needed(guild_id) do
    state = VoiceState.get!(guild_id)

    if state.status == :noop and Playlist.exists?(guild_id) do
      case Playlist.show(guild_id) do
        {:ok, playlist} ->
          {old_index, ordered} = Playlist.order_playlist(playlist)

          index =
            if playlist.shuffle do
              Enum.at(playlist.shuffle_indexes, old_index)
            else
              old_index
            end

          should_play? = !(playlist.repeat == :none and !in_bound?(index, ordered))

          index = old_index

          if should_play? do
            index = keep_in_bounds(index, ordered)

            metadata = Enum.at(ordered, index)

            Voice.play_when_ready!(metadata, guild_id)

            notifiy_playing(state.channel_id, metadata)

            state
            |> Map.put(:status, :playing)
            |> VoiceState.put()
          end

        _ ->
          nil
      end
    end
  end

  @doc """
  Notify that a song is currently playing.
  """
  def notifiy_playing(channel_id, metadata) do
    alias Cassian.Utils.Embed, as: EmbedUtils
    alias Nostrum.Struct.Embed

    embed =
      EmbedUtils.create_empty_embed!()
      |> EmbedUtils.put_color_on_embed(metadata.color)
      |> Embed.put_url(metadata.link)
      |> Embed.put_title("Now playing: #{metadata.title}")

    MessageManager.send_embed(embed, channel_id)
  end

  @doc """
  Switch to the next or previous song.
  """
  @spec switch_song(guild_id :: Snowflake.t(), next :: boolean()) :: :ok | :noop
  def switch_song(guild_id, next) do
    case Playlist.show(guild_id) do
      {:ok, playlist} ->
        # Next song is automatically handled when the bot stops playing music
        # so we only have to worry about going to the previous song.
        unless next do
          # So in normal mode to play the previous song you have to decrement
          # by two to play the previous one. I guess in in reverse mode you then
          # have to do the negative, i.e. increment it by two?
          new_index = playlist.index + if playlist.reverse, do: 2, else: -2

          # Edit: I was right, mostly... In cases where index > 1 then it works. When index is
          # 0 or 1 in normal mode this bugs...
          new_index =
            if playlist.reverse do
              # I honestly have no clue if this works. I'll have to test it first.
              new_index
            else
              # ... This will set the index to be minimaly -1, it iwll be later incremented to zero.
              max(-1, new_index)
            end

          playlist
          |> Map.put(:index, new_index)
          |> Playlist.put()
        end

        if Nostrum.Voice.playing?(guild_id),
          do: Nostrum.Voice.stop(guild_id)

      {:error, :noop} ->
        :error
    end
  end

  @doc """
  Switch to the next or previous song. Also send notification to the channel.
  """
  @spec switch_song_with_notification(message :: %Message{}, next :: boolean()) :: :ok | :noop
  def switch_song_with_notification(message, next) do
    title_part = if next, do: "next", else: "previous"

    case switch_song(message.guild_id, next) do
      :ok ->
        EmbedUtils.create_empty_embed!()
        |> Embed.put_title("Playing #{title_part} song.")

      :noop ->
        EmbedUtils.generate_error_embed(
          "There is no playlist.",
          "You can't change songs if there is no playlist."
        )
    end
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end

  @doc """
  Stop the playlist. Deletes the playlist and then stops the audio on the bot.
  """
  @spec stop(guild_id :: Snowflake.t()) :: :ok | :error
  def stop(guild_id) do
    case Playlist.show(guild_id) do
      {:ok, _} ->
        Playlist.delete(guild_id)
        Nostrum.Voice.stop(guild_id)
        :ok

      {:error, :noop} ->
        :error
    end
  end

  @doc """
  Stop the playlist. Deletes the playlist and then stops the audio on the bot.
  Also sends an embed notification.
  """
  @spec stop_and_notify(message :: %Message{}) :: :ok | :noop
  def stop_and_notify(message) do
    case stop(message.guild_id) do
      :ok ->
        EmbedUtils.create_empty_embed!()
        |> Embed.put_title("Stopped the music.")

      :error ->
        EmbedUtils.generate_error_embed(
          "There is no playlist.",
          "You can't stop the playlist if none exists."
        )
    end
    |> MessageManager.send_dissapearing_embed(message.channel_id)
  end
end
